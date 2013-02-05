//
//  JDListInstalledPlugins.m
//  JDListInstalledPlugins
//
//  Created by Markus Emrich on 03.02.2013.
//
//

#import "JDListInstalledPlugins.h"
#import "JDPluginInstaller.h"
#import "NSURL+JDListPlugins.h"
#import "global.h"

@interface JDListInstalledPlugins () <NSAlertDelegate>
- (void)readAndAddPluginsToMenu:(NSMenu*)menu;
- (void)addPluginNamed:(NSString*)name toMenu:(NSMenu*)menu;

- (void)showPlugin:(NSMenuItem*)sender;
- (void)deletePlugin:(NSMenuItem*)sender;
@end


@implementation JDListInstalledPlugins

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
    NSMenuItem *editMenuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
	if (editMenuItem) {
        // separator
		[[editMenuItem submenu] addItem:[NSMenuItem separatorItem]];
		
        // installed plugins item
		NSMenuItem *installedPluginsItem = [[[NSMenuItem alloc] initWithTitle:JDLocalize(@"keyPluginsMenuItemTitle") action:@selector(showPlugin:) keyEquivalent:@""] autorelease];
        [installedPluginsItem setSubmenu:[[[NSMenu alloc] init] autorelease]];
		[installedPluginsItem setTarget:self];
		[[editMenuItem submenu] addItem:installedPluginsItem];
        
        // show directory item
        NSMenuItem *showDirectoryItem = [[[NSMenuItem alloc] initWithTitle:JDLocalize(@"keyShowDirectoryMenuItemTitle") action:@selector(showPlugin:) keyEquivalent:@""] autorelease];
        [showDirectoryItem setTarget:self];
        [[installedPluginsItem submenu] addItem:showDirectoryItem];
		
        // separator
		[[installedPluginsItem submenu] addItem:[NSMenuItem separatorItem]];
        
        // add each plugin as subitem
        [self readAndAddPluginsToMenu:[installedPluginsItem submenu]];
		
        // separator
		[[installedPluginsItem submenu] addItem:[NSMenuItem separatorItem]];
        
        // show install item
        NSMenuItem *installItem = [[[NSMenuItem alloc] initWithTitle:JDLocalize(@"keyInstallMenuItemTitle") action:@selector(installPlugin:) keyEquivalent:@""] autorelease];
        [installItem setTarget:self];
        [[installedPluginsItem submenu] addItem:installItem];
    }
}

- (void)readAndAddPluginsToMenu:(NSMenu*)menu;
{
    NSString *pluginsPath = [[NSURL pluginsDirectoryURL] path];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pluginsPath error:nil];
    if (!contents || contents.count == 0) {
        // add empty item
        NSMenuItem *emptyItem = [[[NSMenuItem alloc] initWithTitle:JDLocalize(@"keyEmptyMenuItemTitle") action:nil keyEquivalent:@""] autorelease];
        [emptyItem setEnabled:NO];
        [menu addItem:emptyItem];
    } else {
        [contents enumerateObjectsUsingBlock:^(NSString *file, NSUInteger idx, BOOL *stop) {
            if ([file hasSuffix:xcodePluginSuffix]) {
                // remove suffix
                file = [file stringByReplacingOccurrencesOfString:xcodePluginSuffix withString:@""];
                
                // add menu item
                [self addPluginNamed:file toMenu:menu];
            }
        }];
    }
}

- (void)addPluginNamed:(NSString*)name toMenu:(NSMenu*)menu;
{
    // plugin item
    NSMenuItem *pluginItem = [[[NSMenuItem alloc] initWithTitle:name action:@selector(showPlugin:) keyEquivalent:@""] autorelease];
    [pluginItem setSubmenu:[[[NSMenu alloc] init] autorelease]];
    pluginItem.tag = 99;
    [pluginItem setTarget:self];
    [menu addItem:pluginItem];
    
    // delete item
    NSMenuItem *deleteItem = [[[NSMenuItem alloc] initWithTitle:JDLocalize(@"keyUninstall") action:@selector(deletePlugin:) keyEquivalent:@""] autorelease];
    [deleteItem setTarget:self];
    [[pluginItem submenu] addItem:deleteItem];
}

#pragma mark actions

- (void)showPlugin:(NSMenuItem*)sender;
{
    NSURL *url = [NSURL pluginsDirectoryURL];
    if (sender.tag == 99) {
        url = [NSURL pluginURLForPluginNamed:sender.title];
    }
    
    // open finder
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[url]];
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



