//
//  JDPluginInstaller.m
//  JDListInstalledPlugins
//
//  Created by Markus Emrich on 04.02.13.
//
//

#import "JDPluginInstaller.h"
#import "global.h"


@interface JDPluginInstaller ()
+ (BOOL)toolsAreAvailable;
+ (void)beginInstallWithRepositoryUrl:(NSString*)repositoryURL;
@end


NSString *const tmpClonePath   = @"/tmp/JDListInstalledPlugins/";
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
    
    // setup input alert
    NSAlert *alert = [NSAlert alertWithMessageText:JDLocalize(@"keyInstallAlertTitleFormat")
                                     defaultButton:JDLocalize(@"keyInstall")
                                   alternateButton:JDLocalize(@"keyCancel")
                                       otherButton:nil
                         informativeTextWithFormat:JDLocalize(@"keyInstallAlertMessage")];
    alert.alertStyle = NSInformationalAlertStyle;
    
    // add text field
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 400, 24)];
    [input setStringValue:JDLocalize(@"keyInstallAlertExampleText")];
    [input setBezeled:YES];
    [input setBezelStyle:NSTextFieldRoundedBezel];
    [alert setAccessoryView:input];
    
    // show alert
    NSInteger selectedButtonIndex = [alert runModal];
    if (selectedButtonIndex == 0) {
        return;
    }
    
    // install
    [self beginInstallWithRepositoryUrl:input.stringValue];
}

+ (void)beginInstallWithRepositoryUrl:(NSString*)repositoryURL;
{
    NSLog(@"will install %@", repositoryURL);
    
    // show progress panel
    NSPanel *panel = [[[NSPanel alloc] initWithContentRect:NSMakeRect(0, 0, 300, 60)
                                                styleMask:NSTitledWindowMask | NSMiniaturizableWindowMask
                                                  backing:0 defer:NO] autorelease];
    panel.title = JDLocalize(@"keyInstallProgressTitle");
    panel.backgroundColor = [NSColor colorWithCalibratedWhite:0 alpha:0.5];
    panel.opaque = NO;
    [panel center];
    [panel makeKeyAndOrderFront:self];
    
    // add text panel
    NSTextView *textView = [[[NSTextView alloc] initWithFrame:panel.frame] autorelease];
    textView.backgroundColor = [NSColor clearColor];
    textView.textColor = [NSColor whiteColor];
    textView.string = JDLocalize(@"keyInstallProgressMessage");
    [panel.contentView addSubview:textView];
    
    // prepare stdout
//    NSPipe *pipe = [NSPipe pipe];
    
    // checkout project
    NSArray *gitArgs = @[@"clone", repositoryURL, tmpClonePath];
    NSTask *gitTask = [[[NSTask alloc] init] autorelease];
//    [gitTask setStandardOutput:pipe];
    [gitTask setLaunchPath:gitPath];
    [gitTask setArguments:gitArgs];
    [gitTask launch];
    [gitTask waitUntilExit];
    
    // run xcodebuild
    NSTask *xcbTask = [[[NSTask alloc] init] autorelease];
//    [xcbTask setStandardOutput:pipe];
    [xcbTask setCurrentDirectoryPath:tmpClonePath];
    [xcbTask setLaunchPath:xcodeBuildPath];
    [xcbTask launch];
    [xcbTask waitUntilExit];
    
    // move checked out project to trash
    [[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
                                                 source:[tmpClonePath stringByDeletingLastPathComponent]
                                            destination:@""
                                                  files:[NSArray arrayWithObject:[tmpClonePath lastPathComponent]]
                                                    tag:nil];
    
    // show results
//    NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
//    NSString *results = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    [textView setString:results];
    
    // make panel closable
    [panel close];
}


@end





