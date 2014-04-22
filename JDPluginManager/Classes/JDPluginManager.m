//
//  JDPluginManager.m
//  JDPluginManager
//
//  Created by Markus Emrich on 03.02.2013.
//
//

#import "JDPluginManager.h"
#import "JDPluginInstaller.h"
#import "NSURL+JDPluginManager.h"
#import "NSFileManager+JDPluginManager.h"
#import "JDPluginMetaData.h"
#import "global.h"


@interface JDPluginManager () <NSAlertDelegate>
- (void)readAndAddPluginsToMenu:(NSMenu*)menu;
- (void)addPluginNamed:(NSString*)name toMenu:(NSMenu*)menu;

- (void)showPlugin:(NSMenuItem*)sender;
- (void)updatePlugin:(NSMenuItem*)sender;
- (void)showReadme:(NSMenuItem*)sender;
- (void)showOnGithub:(NSMenuItem*)sender;
- (void)deletePlugin:(NSMenuItem*)sender;
@end


@implementation JDPluginManager

+ (void)pluginDidLoad:(NSBundle*)plugin
{
	static id sharedPlugin = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedPlugin = [[self alloc] init];
	});
}

- (id)init
{
    self = [super init];
    if (self) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:)
                                                     name:NSApplicationDidFinishLaunchingNotification object:nil];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [self extendXcodeMenu];
}

#pragma mark build menu

- (void)extendXcodeMenu
{
    NSMenuItem *pluginsMenuItem = [[NSApp mainMenu] itemWithTitle:JDLocalize(@"keyManagePluginsMenuItemTitle")];
    if (!pluginsMenuItem) {
        // find window menu item
        NSInteger menuIndex = [[NSApp mainMenu] indexOfItemWithTitle:@"Window"];
        if (menuIndex < 0) {
            menuIndex = [[NSApp mainMenu] numberOfItems];
        }
        
        // insert plugins item
        pluginsMenuItem = [[NSApp mainMenu] insertItemWithTitle:JDLocalize(@"keyManagePluginsMenuItemTitle") action:nil keyEquivalent:@"" atIndex:menuIndex];
        pluginsMenuItem.submenu = [[NSMenu alloc] initWithTitle:JDLocalize(@"keyManagePluginsMenuItemTitle")];
    }
    
    // add menu entries
	if (pluginsMenuItem) {
        // directory item
        NSMenuItem *showDirectoryItem = [[NSMenuItem alloc] initWithTitle:JDLocalize(@"keyShowDirectoryMenuItemTitle") action:@selector(showPluginsDirectory:) keyEquivalent:@""];
        [showDirectoryItem setTarget:self];
        [[pluginsMenuItem submenu] insertItem:showDirectoryItem atIndex:0];
		
        // separator
        [[pluginsMenuItem submenu] insertItem:[NSMenuItem separatorItem] atIndex:1];
        
        // each plugin as subitem
        [self readAndAddPluginsToMenu:[pluginsMenuItem submenu]];
		
        // separator
		[[pluginsMenuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        // install item
        NSMenuItem *installItem = [[NSMenuItem alloc] initWithTitle:JDLocalize(@"keyInstallMenuItemTitle") action:@selector(installPlugin:) keyEquivalent:@""];
        [installItem setTarget:self];
        [[pluginsMenuItem submenu] addItem:installItem];
    }
}

- (void)readAndAddPluginsToMenu:(NSMenu*)menu
{
    NSArray *contents = [NSFileManager allPluginsWithModifiedDate:NO];
    if (!contents || contents.count == 0) {
        // empty item
        NSMenuItem *emptyItem = [[NSMenuItem alloc] initWithTitle:JDLocalize(@"keyEmptyMenuItemTitle") action:nil keyEquivalent:@""];
        [emptyItem setEnabled:NO];
        [menu addItem:emptyItem];
    } else {
        [contents enumerateObjectsUsingBlock:^(NSString *file, NSUInteger idx, BOOL *stop) {
            if ([file hasSuffix:xcodePluginSuffix]) {
                // remove suffix
                file = [file stringByReplacingOccurrencesOfString:xcodePluginSuffix withString:@""];
                
                // plugin item
                [self addPluginNamed:file toMenu:menu];
            }
        }];
    }
}

- (void)addPluginNamed:(NSString*)name toMenu:(NSMenu*)menu
{
    // plugin item
    NSMenuItem *pluginItem = [menu itemWithTitle:name];
    if (!pluginItem) {
        pluginItem = [menu addItemWithTitle:name action:@selector(showPlugin:) keyEquivalent:@""];
        pluginItem.submenu = [[NSMenu alloc] init];
        pluginItem.target = self;
    }
    
    // delete item
    NSMenuItem *deleteItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat: @"%@…", JDLocalize(@"keyUninstall")] action:@selector(deletePlugin:) keyEquivalent:@""];
    [deleteItem setTarget:self];
    [[pluginItem submenu] addItem:deleteItem];
    
    // read meta data
    JDPluginMetaData *metaData = [JDPluginMetaData metaDataForPluginAtPath:[[NSURL pluginURLForPluginNamed:name] path]];
    NSString *repositoryPath = [metaData objectForKey:JDPluginManagerMetaDataRepositoryKey];
    NSString *readmePath     = [metaData objectForKey:JDPluginManagerMetaDataReadmePathKey];
    
    // update item
    if (repositoryPath) {
        NSMenuItem *updateItem = [[NSMenuItem alloc] initWithTitle:JDLocalize(@"keyUpdateMenuItemTitle") action:@selector(updatePlugin:) keyEquivalent:@""];
        [updateItem setTarget:self];
        [[pluginItem submenu] addItem:updateItem];
    }
    
    // add separator
    [[pluginItem submenu] addItem:[NSMenuItem separatorItem]];
    
    // show readme item
    if (readmePath && [[NSFileManager defaultManager] fileExistsAtPath:readmePath]) {
        NSMenuItem *readmeItem = [[NSMenuItem alloc] initWithTitle:JDLocalize(@"keyShowReadmeMenuItemTitle") action:@selector(showReadme:) keyEquivalent:@""];
        [readmeItem setTarget:self];
        [[pluginItem submenu] addItem:readmeItem];
    }
    
    // reveal in finder item
    NSMenuItem *revealInFinderItem = [[NSMenuItem alloc] initWithTitle:JDLocalize(@"keyRevealInFinderMenuItemTitle") action:@selector(showPlugin:) keyEquivalent:@""];
    [revealInFinderItem setTarget:self];
    [[pluginItem submenu] addItem:revealInFinderItem];
    
    // show on github item
    if (repositoryPath && [repositoryPath rangeOfString:@"github.com"].length != 0) {
        NSMenuItem *githubItem = [[NSMenuItem alloc] initWithTitle:JDLocalize(@"keyShowOnGithubMenuItemTitle") action:@selector(showOnGithub:) keyEquivalent:@""];
        [githubItem setTarget:self];
        [[pluginItem submenu] addItem:githubItem];
    }
}

#pragma mark actions

- (void)showPluginsDirectory:(id)sender
{
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[[NSURL pluginsDirectoryURL]]];
}

- (void)showPlugin:(NSMenuItem*)sender
{
    NSURL *url;
    if ([sender.title isEqualToString:JDLocalize(@"keyRevealInFinderMenuItemTitle")]) {
        url = [NSURL pluginURLForPluginNamed:[sender parentItem].title];
    } else {
        url = [NSURL pluginURLForPluginNamed:sender.title];
    }
    
    // open finder
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[url]];
}

- (void)updatePlugin:(NSMenuItem*)sender
{
    NSString *pluginName = [sender parentItem].title;
    JDPluginMetaData *metaData = [JDPluginMetaData metaDataForPluginAtPath:[[NSURL pluginURLForPluginNamed:pluginName] path]];
    
    NSString *gitURL = [metaData objectForKey:JDPluginManagerMetaDataRepositoryKey];
    [[[JDPluginInstaller alloc] init] beginInstallWithRepositoryPath:gitURL searchInSubdirectories:NO];
}

- (void)showReadme:(NSMenuItem*)sender
{
    NSString *pluginName = [sender parentItem].title;
    JDPluginMetaData *metaData = [JDPluginMetaData metaDataForPluginAtPath:[[NSURL pluginURLForPluginNamed:pluginName] path]];
    
    NSString *readmePath = [metaData objectForKey:JDPluginManagerMetaDataReadmePathKey];
    [[NSWorkspace sharedWorkspace] openFile:readmePath];
}

- (void)showOnGithub:(NSMenuItem*)sender
{
    NSString *pluginName = [sender parentItem].title;
    JDPluginMetaData *metaData = [JDPluginMetaData metaDataForPluginAtPath:[[NSURL pluginURLForPluginNamed:pluginName] path]];

    NSString *gitURL = [metaData objectForKey:JDPluginManagerMetaDataRepositoryKey];
    gitURL = [gitURL stringByReplacingOccurrencesOfString:@"git@github.com:" withString:@"github.com/"];
    gitURL = [gitURL stringByReplacingOccurrencesOfString:@".git" withString:@""];
    if (![gitURL hasPrefix:@"HTTP"] || ![gitURL hasPrefix:@"http"]) {
        gitURL = [NSString stringWithFormat: @"http://%@", gitURL];
    }
    NSURL *url = [NSURL URLWithString:gitURL];
    if (url) {
        [[NSWorkspace sharedWorkspace] openURL:url];
    }
}

- (void)deletePlugin:(NSMenuItem*)sender
{
    NSString *pluginName = [sender parentItem].title;
    
    // construct alert
    NSAlert *alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:JDLocalize(@"keyUninstallAlertTitleFormat"), pluginName]
                                     defaultButton:JDLocalize(@"keyUninstall")
                                   alternateButton:JDLocalize(@"keyCancel")
                                       otherButton:nil
                         informativeTextWithFormat:JDLocalize(@"keyUninstallAlertMessageFormat"), pluginName];
    alert.alertStyle = NSCriticalAlertStyle;
    
    // show alert
    NSInteger selectedButtonIndex = [alert runModal];
    if (selectedButtonIndex == 0) {
        return;
    }
    
    // move plugin folder to trash
    NSString *pluginPath = [[NSURL pluginURLForPluginNamed:pluginName] path];
    BOOL deleted = [[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
                                                                source:[pluginPath stringByDeletingLastPathComponent]
                                                           destination:@""
                                                                 files:[NSArray arrayWithObject:[pluginPath lastPathComponent]]
                                                                   tag:nil];
    if (deleted) {
        [[sender.parentItem.parentItem submenu] removeItem:sender.parentItem];
    }
}

- (void)installPlugin:(NSMenuItem*)sender
{
    [JDPluginInstaller installPlugin];
}

@end



