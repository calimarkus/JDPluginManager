//
//  JDPluginInstaller.m
//  JDPluginManager
//
//  Created by Markus Emrich on 04.02.13.
//
//

#import "global.h"
#import "JDGitCloneTask.h"
#import "JDXcodeBuildTask.h"
#import "JDInstallProgressWindow.h"
#import "NSFileManager+JDPluginManager.h"
#import "NSURL+JDPluginManager.h"
#import "JDPluginMetaData.h"

#import "JDPluginInstaller.h"


@interface JDPluginInstaller () <NSWindowDelegate>
@property (nonatomic, strong) NSTaskWithProgress *activeTask;
@property (nonatomic, copy) NSString *repositoryPath;
@property (nonatomic, strong) NSMutableArray *pathsToBuild;
@property (nonatomic, strong) JDInstallProgressWindow *progressWindow;
+ (BOOL)toolsAreAvailable;
- (void)showInstallPrompt;
- (void)showProgressPanel;
- (void)startXcodeBuildWithCompletion:(void(^)(void))completion;
- (void)emptyTempDirectory;
@end

@implementation JDPluginInstaller

@synthesize activeTask = _activeTask;
@synthesize repositoryPath = _repositoryPath;
@synthesize pathsToBuild = _pathsToBuild;
@synthesize progressWindow = _progressWindow;

+ (BOOL)toolsAreAvailable
{
    NSString *errorTitle = nil, *errorMessage = nil;
    
    // check for xcodebuild
    BOOL xcodeBuildFound = [[NSFileManager defaultManager] fileExistsAtPath:xcodeBuildPath];
    if (!xcodeBuildFound) {
        errorTitle   = JDLocalize(@"keyErrorXcodeToolsMissingTitle");
        errorMessage = JDLocalize(@"keyErrorXcodeToolsMissingMessage");
    }
    
    // check for git
    BOOL gitFound = [[NSFileManager defaultManager] fileExistsAtPath:gitPath];
    if (!gitFound) {
        errorTitle   = JDLocalize(@"keyErrorGitMissingTitle");
        errorMessage = JDLocalize(@"keyErrorGitMissingMessage");
    }
    
    // display error message
    if (errorTitle != nil) {
        NSAlert *alert = [NSAlert alertWithMessageText:errorTitle
                                         defaultButton:JDLocalize(@"keyOK")
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:@"%@", errorMessage];
        alert.alertStyle = NSCriticalAlertStyle;
        [alert runModal];
        return NO;
    }
    
    return YES;
}

+ (void)installPlugin
{
    if (![self toolsAreAvailable]) {
        return;
    }
    
    [[[self alloc] init] showInstallPrompt];
}

- (void)showInstallPrompt
{
    // setup input alert
    NSAlert *alert = [NSAlert alertWithMessageText:JDLocalize(@"keyInstallAlertTitleFormat")
                                     defaultButton:JDLocalize(@"keyInstall")
                                   alternateButton:JDLocalize(@"keyCancel")
                                       otherButton:nil
                         informativeTextWithFormat:JDLocalize(@"keyInstallAlertMessage")];
    alert.alertStyle = NSInformationalAlertStyle;
    
    // add text field
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 30, 460, 24)];
    [input setStringValue:JDLocalize(@"keyInstallAlertExampleText")];
    [input setBezeled:YES];
    [input setBezelStyle:NSTextFieldRoundedBezel];
    
    // add checkbox
    NSButton *checkbox = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
    [checkbox setButtonType:NSSwitchButton];
    [checkbox setTitle:JDLocalize(@"keyInstallAlertCheckboxText")];
    [checkbox sizeToFit];
    
    // build accessory view
    NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 460, 50)];
    [view addSubview:input];
    [view addSubview:checkbox];
    [alert setAccessoryView:view];
    
    // show prompt
    NSInteger selectedButtonIndex = [alert runModal];
    if (selectedButtonIndex == 0) {
        return;
    }
    
    // install
    BOOL searchSubdirectories = (checkbox.state == NSOnState);
    [self beginInstallWithRepositoryPath:input.stringValue searchInSubdirectories:searchSubdirectories];
}

- (void)beginInstallWithRepositoryPath:(NSString*)repositoryPath searchInSubdirectories:(BOOL)searchSubdirectories
{
    if (![JDPluginInstaller toolsAreAvailable]) {
        return;
    }
    
    // save repo URL
    self.repositoryPath = repositoryPath;
    
    // show progress panel
    [self showProgressPanel];
    
    // move checked out project to trash
    [self emptyTempDirectory];
    
    @try {
        // clone project
        self.activeTask = [JDGitCloneTask launchedTaskWithRepositoryPath:repositoryPath
                                                         progressWindow:self.progressWindow
                                                             completion:^(NSString *clonePath)
        {
            // use top level folder for install
            NSArray *pathsToCheck = @[clonePath];
            
            // use subdirectories, if enabled
            if (searchSubdirectories) {
                NSMutableArray *array = [NSMutableArray array];
                
                // search for actual directories
                NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:clonePath error:nil];
                [contents enumerateObjectsUsingBlock:^(NSString *contentPath, NSUInteger idx, BOOL *stop) {
                    BOOL isDirectory = NO;
                    [[NSFileManager defaultManager] fileExistsAtPath:[clonePath stringByAppendingPathComponent:contentPath] isDirectory:&isDirectory];
                    if (isDirectory && ![contentPath hasPrefix:@"."] && ![contentPath hasSuffix:@".xcworkspace"]) {
                        [array addObject:[clonePath stringByAppendingPathComponent:contentPath]];
                    }
                }];
                // use subdirectories, if found
                if (array.count > 0) {
                    pathsToCheck = array;
                }
            }
            
            // save paths
            self.pathsToBuild = [pathsToCheck mutableCopy];
                                                                 
            // start xcode build
            [self startXcodeBuildWithCompletion:^{
                // move checked out project(s) to trash
                [self.progressWindow appendLine:JDLocalize(@"keyInstallTrashingTmpDirectory")];
                [self emptyTempDirectory];
                
                // release task
                self.activeTask = nil;
                
                // close panel
                self.progressWindow.styleMask = self.progressWindow.styleMask | NSClosableWindowMask;
            }];
        }];        
    }
    @catch (NSException *exception) {
        NSAlert *alert = [NSAlert alertWithMessageText:JDLocalize(@"keyInstallErrorTitle")
                                         defaultButton:JDLocalize(@"keyOK")
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:JDLocalize(@"keyInstallErrorMessage")];
        alert.alertStyle = NSCriticalAlertStyle;
        [alert runModal];
    }
}

- (void)startXcodeBuildWithCompletion:(void(^)(void))completion
{
    // run xcodebuild for each path given
    if (self.pathsToBuild.count > 0) {
        NSString *path = [self.pathsToBuild.lastObject copy];
        [self.pathsToBuild removeObject:path];
        
        // directoryContentsBefore
        NSArray *directoryContentsBefore = [NSFileManager allPluginsWithModifiedDate:YES];
        
        completion = [completion copy];
        
        self.activeTask = [JDXcodeBuildTask launchedTaskWithCurrentDirectoryPath:path
                                                                  progressWindow:self.progressWindow
                                                                      completion:^{
            // directory contents after
            NSArray *directoryContentsAfter = [NSFileManager allPluginsWithModifiedDate:YES];
            [self checkSuccessAndUpdateMetaDataWithContentsBefore:directoryContentsBefore
                                                         andAfter:directoryContentsAfter
                                                    withBuildPath:path];
            
            // build next path, or finish
            [self startXcodeBuildWithCompletion:completion];
        }];
    }
    else {
        if (completion) {
            completion();
        }
    }
}

- (void)checkSuccessAndUpdateMetaDataWithContentsBefore:(NSArray*)directoryContentsBefore
                                               andAfter:(NSArray*)directoryContentsAfter
                                          withBuildPath:(NSString*)buildPath
{
    __block NSString *changedPlugin = nil;
    
    [directoryContentsBefore enumerateObjectsUsingBlock:^(NSDictionary *before, NSUInteger idx, BOOL *stop) {
        NSDictionary *after = [directoryContentsAfter objectAtIndex:idx];
        NSString *beforeString = [NSString stringWithFormat: @"%@-%@", [before objectForKey:JDPluginNameKey], [before objectForKey:JDPluginModifiedDate]];
        NSString *afterString = [NSString stringWithFormat: @"%@-%@", [after objectForKey:JDPluginNameKey], [after objectForKey:JDPluginModifiedDate]];
        if (![beforeString isEqualToString:afterString]) {
            *stop = YES;
            changedPlugin = [after objectForKey:JDPluginNameKey];
        }
    }];
    
    if (changedPlugin == nil) {
        // inform user
        [self.progressWindow appendTitle:JDLocalize(@"keyInstallFailureMessage")];
    } else {
        // save meta data
        NSString *pluginPath = [[NSURL pluginURLForPluginNamed:changedPlugin] path];
        JDPluginMetaData *metaData = [[JDPluginMetaData alloc] initWithPluginPath:pluginPath];
        [metaData findAndSetReadmeAtBuildPath:buildPath];
        [metaData setObject:self.repositoryPath forKey:JDPluginManagerMetaDataRepositoryKey];
        [metaData save];
        
        // inform user
        [self.progressWindow appendTitle:[NSString stringWithFormat:JDLocalize(@"keyInstallSuccessMessageFormat"), changedPlugin]];
    }
}

- (void)showProgressPanel
{
    self.progressWindow = [[JDInstallProgressWindow alloc] initWithContentRect:NSMakeRect(0, 0, 568, 320)];
    
    // show window
    [self.progressWindow makeKeyAndOrderFront:self];
    [self.progressWindow center];
}

- (void)emptyTempDirectory
{
    // read contents of tmp dir
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tmpClonePath error:nil];
    
    // move tmp dirs to trash
    [[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
                                                 source:tmpClonePath destination:@""
                                                  files:files tag:nil];

}


@end





