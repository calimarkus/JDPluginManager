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
#import "JDPluginsRepository.h"

NSInteger const JDRevealPluginInFinderTag = 1337;


@interface JDPluginManager () <NSAlertDelegate>
- (void)readAndAddPluginsToMenu:(NSMenu*)menu;

- (void)showPlugin:(NSMenuItem*)sender;
- (void)updatePlugin:(NSMenuItem*)sender;
- (void)showReadme:(NSMenuItem*)sender;
- (void)showOnGithub:(NSMenuItem*)sender;
- (void)deletePlugin:(NSMenuItem*)sender;
@end


@implementation JDPluginManager

@synthesize jdpm = _jdpm;

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
        [JDPluginsRepository sharedInstance];
        self.jdpm = [[JDPluginsWindowController alloc] init];
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

-(void)openPluginManager:(NSMenuItem*)sender
{
    [self.jdpm showWindow:[NSApp mainWindow]];
}

- (void)extendXcodeMenu
{
    // find window menu item
	NSInteger menuIndex=[[NSApp mainMenu] indexOfItemWithTitle:@"Window"];
	if(menuIndex<0) {
		menuIndex=[[NSApp mainMenu] numberOfItems];
    }
    
    // insert plugins item
	NSMenuItem *pluginsMenuItem=[[NSApp mainMenu] insertItemWithTitle:@"" action:nil keyEquivalent:@"" atIndex:menuIndex];
    NSMenu *subMenu = [[[NSMenu alloc] initWithTitle:JDLocalize(@"keyManagePluginsMenuItemTitle")] autorelease];
	[pluginsMenuItem setSubmenu:subMenu];
    
    // add menu entries
	if (pluginsMenuItem) {
        // directory item
        NSMenuItem *showDirectoryItem = [[[NSMenuItem alloc] initWithTitle:JDLocalize(@"keyShowDirectoryMenuItemTitle") action:@selector(showPlugin:) keyEquivalent:@""] autorelease];
        [showDirectoryItem setTarget:self];
        [[pluginsMenuItem submenu] addItem:showDirectoryItem];
		
        // separator
		[[pluginsMenuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        // each plugin as subitem
        [self readAndAddPluginsToMenu:[pluginsMenuItem submenu]];
		
        // separator
		[[pluginsMenuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        // install item
        NSMenuItem *installItem = [[[NSMenuItem alloc] initWithTitle:JDLocalize(@"keyInstallMenuItemTitle") action:@selector(installPlugin:) keyEquivalent:@""] autorelease];
        [installItem setTarget:self];
        [[pluginsMenuItem submenu] addItem:installItem];
        
        //insert plugin manager item
        NSMenuItem *pluginsManagerMenuItem = [[[NSMenuItem alloc] initWithTitle:@"Plugin Manager" action:@selector(openPluginManager:) keyEquivalent:@""] autorelease];
        [pluginsManagerMenuItem setTarget:self];
        [[pluginsMenuItem submenu] addItem:pluginsManagerMenuItem];
    }
}

- (void)readAndAddPluginsToMenu:(NSMenu*)menu;
{
    NSArray *plugins = [JDPluginsRepository sharedInstance].installedPlugins;
    if (!plugins || plugins.count == 0)
    {
        NSMenuItem *emptyItem = [[[NSMenuItem alloc] initWithTitle:JDLocalize(@"keyEmptyMenuItemTitle") action:nil keyEquivalent:@""] autorelease];
        [emptyItem setEnabled:NO];
        [menu addItem:emptyItem];
        return;
    }
    
    for (JDPluginMetaData *plugin in plugins) {
        [self addPlugin:plugin toMenu:menu];
    }
}

-(void)addPlugin:(JDPluginMetaData *)plugin toMenu:(NSMenu*)menu
{
    NSMenuItem *pluginItem = [[[NSMenuItem alloc] initWithTitle:plugin.name action:@selector(showPlugin:) keyEquivalent:@""] autorelease];
    [pluginItem setSubmenu:[[[NSMenu alloc] init] autorelease]];
    [pluginItem setTag:JDRevealPluginInFinderTag];
    [pluginItem setTarget:self];
    [menu addItem:pluginItem];
    
    // delete item
    NSMenuItem *deleteItem = [[[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat: @"%@…", JDLocalize(@"keyUninstall")] action:@selector(deletePlugin:) keyEquivalent:@""] autorelease];
    [deleteItem setTarget:self];
    [[pluginItem submenu] addItem:deleteItem];
    
    // read meta data
    NSString *repositoryPath = [plugin objectForKey:JDPluginManagerMetaDataRepositoryKey];
    NSString *readmePath     = [plugin objectForKey:JDPluginManagerMetaDataReadmePathKey];
    
    // update item
    if (repositoryPath) {
        NSMenuItem *updateItem = [[[NSMenuItem alloc] initWithTitle:JDLocalize(@"keyUpdateMenuItemTitle") action:@selector(updatePlugin:) keyEquivalent:@""] autorelease];
        [updateItem setTarget:self];
        [[pluginItem submenu] addItem:updateItem];
    }
    
    // add separator
    [[pluginItem submenu] addItem:[NSMenuItem separatorItem]];
    
    // show readme item
    if (readmePath && [[NSFileManager defaultManager] fileExistsAtPath:readmePath]) {
        NSMenuItem *readmeItem = [[[NSMenuItem alloc] initWithTitle:JDLocalize(@"keyShowReadmeMenuItemTitle") action:@selector(showReadme:) keyEquivalent:@""] autorelease];
        [readmeItem setTarget:self];
        [[pluginItem submenu] addItem:readmeItem];
    }
    
    // reveal in finder item
    NSMenuItem *revealInFinderItem = [[[NSMenuItem alloc] initWithTitle:JDLocalize(@"keyRevealInFinderMenuItemTitle") action:@selector(showPlugin:) keyEquivalent:@""] autorelease];
    [revealInFinderItem setTag:JDRevealPluginInFinderTag];
    [revealInFinderItem setTarget:self];
    [[pluginItem submenu] addItem:revealInFinderItem];
    
    // show on github item
    if (repositoryPath && [repositoryPath rangeOfString:@"github.com"].length != 0) {
        NSMenuItem *githubItem = [[[NSMenuItem alloc] initWithTitle:JDLocalize(@"keyShowOnGithubMenuItemTitle") action:@selector(showOnGithub:) keyEquivalent:@""] autorelease];
        [githubItem setTarget:self];
        [[pluginItem submenu] addItem:githubItem];
    }

}

#pragma mark actions

- (void)showPlugin:(NSMenuItem*)sender;
{
    NSURL *url = [NSURL pluginsDirectoryURL];
    if (sender.tag == JDRevealPluginInFinderTag) {
        if ([sender.title isEqualToString:JDLocalize(@"keyRevealInFinderMenuItemTitle")]) {
            url = [NSURL pluginURLForPluginNamed:[sender parentItem].title];
        } else {
            url = [NSURL pluginURLForPluginNamed:sender.title];
        }
    }
    
    // open finder
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[url]];
}

- (void)updatePlugin:(NSMenuItem*)sender;
{
    NSString *pluginName = [sender parentItem].title;
    JDPluginMetaData *metaData = [JDPluginMetaData metaDataForPluginAtPath:[[NSURL pluginURLForPluginNamed:pluginName] path]];
    
    NSString *gitURL = [metaData objectForKey:JDPluginManagerMetaDataRepositoryKey];
    [[[[JDPluginInstaller alloc] init] autorelease] beginInstallWithRepositoryPath:gitURL searchInSubdirectories:NO];
}

- (void)showReadme:(NSMenuItem*)sender;
{
    NSString *pluginName = [sender parentItem].title;
    JDPluginMetaData *metaData = [JDPluginMetaData metaDataForPluginAtPath:[[NSURL pluginURLForPluginNamed:pluginName] path]];
    
    NSString *readmePath = [metaData objectForKey:JDPluginManagerMetaDataReadmePathKey];
    [[NSWorkspace sharedWorkspace] openFile:readmePath];
}

- (void)showOnGithub:(NSMenuItem*)sender;
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

- (void)deletePlugin:(NSMenuItem*)sender;
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

- (void)installPlugin:(NSMenuItem*)sender;
{
    [JDPluginInstaller installPlugin];
}

@end



