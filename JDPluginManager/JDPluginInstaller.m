//
//  JDPluginInstaller.m
//  JDPluginManager
//
//  Created by Markus Emrich on 04.02.13.
//
//

#import "global.h"
#import "NSTaskWithProgress.h"
#import "JDInstallProgressWindow.h"

#import "JDPluginInstaller.h"


@interface JDPluginInstaller () <NSWindowDelegate>
@property (nonatomic, strong) NSTask *activeTask;
@property (nonatomic, strong) NSMutableArray *pathsToBuild;
@property (nonatomic, strong) JDInstallProgressWindow *progressWindow;
+ (BOOL)toolsAreAvailable;
- (void)showInstallPrompt;
- (void)showProgressPanel;
- (void)startXcodeBuild;
- (void)emptyTempDirectory;
@end


NSString *const tmpClonePath   = @"/tmp/JDPluginManager/";
NSString *const xcodeBuildPath = @"/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild";
NSString *const gitPath        = @"/usr/bin/git";

@implementation JDPluginInstaller

+ (BOOL)toolsAreAvailable;
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

+ (void)installPlugin;
{
    if (![self toolsAreAvailable]) {
        return;
    }
    
    [[[[self alloc] init] autorelease] showInstallPrompt];
}

- (void)showInstallPrompt;
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
    [self beginInstallWithRepositoryUrl:input.stringValue searchInSubdirectories:searchSubdirectories];
}

- (void)beginInstallWithRepositoryUrl:(NSString*)repositoryURL searchInSubdirectories:(BOOL)searchSubdirectories;
{
    if (![JDPluginInstaller toolsAreAvailable]) {
        return;
    }
    
    // show progress panel
    [self showProgressPanel];
    
    // move checked out project to trash
    [self emptyTempDirectory];
    
    @try {
        // clone project
        [self.progressWindow appendLine:[NSString stringWithFormat:JDLocalize(@"keyInstallCloneMessageFormat"), repositoryURL]];
        
        NSString *clonePath = [tmpClonePath stringByAppendingPathComponent:[[repositoryURL lastPathComponent] stringByReplacingOccurrencesOfString:@".git" withString:@""]];
        NSArray *gitArgs = @[@"clone", repositoryURL, clonePath];
        self.activeTask = [NSTaskWithProgress launchedTaskWithLaunchPath:gitPath arguments:gitArgs progress:^(NSTask *task, NSString *output) {
            [self.progressWindow appendLine:output];
        } completion:^(NSTask *task, NSString *output) {
            
            [self.progressWindow appendLine:output];
            
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
            [self.progressWindow appendLine:JDLocalize(@"keyInstallBuildMessage")];
            [self startXcodeBuild];
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

- (void)startXcodeBuild;
{
    // run xcodebuild for each path given
    if (self.pathsToBuild.count > 0) {
        NSString *path = self.pathsToBuild.lastObject;
        [self.pathsToBuild removeObject:path];
        
        self.activeTask = [NSTaskWithProgress launchedTaskWithLaunchPath:xcodeBuildPath arguments:nil currentDirectoryPath:path progress:^(NSTask *task, NSString *output) {
            [self.progressWindow appendLine:output];
        }  completion:^(NSTask *task, NSString *output) {
            [self.progressWindow appendLine:output];
            
            // build next path, or finish
            [self startXcodeBuild];
        }];
    }
    
    // completion
    else {
        [self.progressWindow appendLine:JDLocalize(@"keyInstallRestartXCodeMessage")];
        
        // move checked out project to trash
        [self emptyTempDirectory];
        
        // release task
        self.activeTask = nil;
        
        // close panel
        self.progressWindow.styleMask = self.progressWindow.styleMask | NSClosableWindowMask;
    }
}

- (void)showProgressPanel;
{
    self.progressWindow = [[[JDInstallProgressWindow alloc] initWithContentRect:NSMakeRect(0, 0, 568, 320)] autorelease];
    
    // show window
    [self.progressWindow makeKeyAndOrderFront:self];
    [self.progressWindow center];
}

- (void)emptyTempDirectory;
{
    // move tmp dir to trash
    [[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
                                                 source:[tmpClonePath stringByDeletingLastPathComponent]
                                            destination:@""
                                                  files:[NSArray arrayWithObject:[tmpClonePath lastPathComponent]]
                                                    tag:nil];
}


@end





