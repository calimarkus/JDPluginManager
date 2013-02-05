//
//  JDPluginInstaller.m
//  JDListInstalledPlugins
//
//  Created by Markus Emrich on 04.02.13.
//
//

#import "JDPluginInstaller.h"
#import "global.h"


@interface JDPluginInstaller () <NSWindowDelegate>
+ (BOOL)toolsAreAvailable;
- (void)showInstallPrompt;
- (NSPanel*)showProgressPanel;
- (void)emptyTempDirectory;
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
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 400, 24)];
    [input setStringValue:JDLocalize(@"keyInstallAlertExampleText")];
    [input setBezeled:YES];
    [input setBezelStyle:NSTextFieldRoundedBezel];
    [alert setAccessoryView:input];
    
    // show prompt
    NSInteger selectedButtonIndex = [alert runModal];
    if (selectedButtonIndex == 0) {
        return;
    }
    
    // install
    [self beginInstallWithRepositoryUrl:input.stringValue];
}

- (void)beginInstallWithRepositoryUrl:(NSString*)repositoryURL;
{
    if (![JDPluginInstaller toolsAreAvailable]) {
        return;
    }
    
    // show progress panel
    NSPanel *panel = [self showProgressPanel];
    
    // move checked out project to trash
    [self emptyTempDirectory];
    
    @try {
        // checkout project
        NSArray *gitArgs = @[@"clone", repositoryURL, tmpClonePath];
        NSTask *gitTask = [[[NSTask alloc] init] autorelease];
        [gitTask setLaunchPath:gitPath];
        [gitTask setArguments:gitArgs];
        [gitTask launch];
        [gitTask waitUntilExit];

        // run xcodebuild
        NSTask *xcbTask = [[[NSTask alloc] init] autorelease];
        [xcbTask setCurrentDirectoryPath:tmpClonePath];
        [xcbTask setLaunchPath:xcodeBuildPath];
        [xcbTask launch];
        [xcbTask waitUntilExit];
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
    
    // move checked out project to trash
    [self emptyTempDirectory];
    
    // make panel closable
    [panel close];
}

- (NSPanel*)showProgressPanel;
{
    NSPanel *panel = [[NSPanel alloc] initWithContentRect:NSMakeRect(0, 0, 300, 160)
                                                styleMask:NSTitledWindowMask | NSMiniaturizableWindowMask
                                                  backing:0 defer:NO];
    panel.styleMask = NSHUDWindowMask | NSUtilityWindowMask | NSTitledWindowMask;
    panel.title = JDLocalize(@"keyInstallProgressTitle");
    panel.delegate = self;
    [panel center];
    
    // add text panel
    NSView *contentView = panel.contentView;
    NSTextView *textView = [[[NSTextView alloc] initWithFrame:NSInsetRect(contentView.bounds, 10, 10)] autorelease];
    textView.backgroundColor = [NSColor clearColor];
    textView.textColor = [NSColor whiteColor];
    textView.selectable = NO;
    textView.editable = NO;
    textView.font = [NSFont systemFontOfSize:13];
    textView.alignment = NSCenterTextAlignment;
    textView.string = JDLocalize(@"keyInstallProgressMessage");
    [contentView addSubview:textView];
    
    // show window
    [panel makeKeyAndOrderFront:self];
    
    return panel;
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





