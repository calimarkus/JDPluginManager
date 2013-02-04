//
//  JDListInstalledPlugins.m
//  JDListInstalledPlugins
//
//  Created by Markus Emrich on 03.02.2013.
//
//

#import "JDListInstalledPlugins.h"

#if JDListInstalledPluginsTest == 1
    #define JDLocalize(keyName) NSLocalizedString(keyName, nil)
#else
    #define JDLocalize(keyName) NSLocalizedStringFromTableInBundle(keyName, @"Localizable", [NSBundle bundleForClass:[self class]], nil)
#endif

NSString *const xcodePluginSuffix = @".xcplugin";
NSString *const pluginsDirectoryPath = @"~/Library/Application Support/Developer/Shared/Xcode/Plug-ins";

@interface JDListInstalledPlugins () <NSAlertDelegate>
- (void)readAndAddPluginsToMenu:(NSMenu*)menu;
- (void)addPluginNamed:(NSString*)name toMenu:(NSMenu*)menu;

- (void)showPlugin:(NSMenuItem*)sender;
- (void)deletePlugin:(NSMenuItem*)sender;

- (NSURL*)URLForPluginNamed:(NSString*)pluginName;
- (NSURL*)pluginsDirectoryURL;
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
    }
}

- (void)readAndAddPluginsToMenu:(NSMenu*)menu;
{
    NSString *pluginsPath = [[self pluginsDirectoryURL] path];
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
    NSURL *url = [self pluginsDirectoryURL];
    if (sender.tag == 99) {
        url = [self URLForPluginNamed:sender.title];
    }
    
    // open finder
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[url]];
}

- (void)deletePlugin:(NSMenuItem*)sender;
{
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    NSString *pluginName = [sender parentItem].title;
    
    NSAlert *alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:JDLocalize(@"keyUninstallAlertTitleFormat"), pluginName]
                                     defaultButton:JDLocalize(@"keyUninstall")
                                   alternateButton:nil
                                       otherButton:JDLocalize(@"keyCancel")
                         informativeTextWithFormat:JDLocalize(@"keyUninstallAlertMessageFormat"), pluginName, appName];
    alert.alertStyle = NSCriticalAlertStyle;
    NSInteger result = [alert runModal];
    
    if (result == 1) {
        NSString *pluginPath = [[self URLForPluginNamed:pluginName] path];
        BOOL deleted = [[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
                                                                    source:[pluginPath stringByDeletingLastPathComponent]
                                                               destination:@""
                                                                     files:[NSArray arrayWithObject:[pluginPath lastPathComponent]]
                                                                       tag:nil];
        if (deleted) {
            [[sender.parentItem.parentItem submenu] removeItem:sender.parentItem];
        }
    }
}

#pragma mark helper

- (NSURL*)URLForPluginNamed:(NSString*)pluginName;
{
    NSString *folderName = [NSString stringWithFormat: @"%@%@/", pluginName, xcodePluginSuffix];
    NSString *pluginPath = [[[self pluginsDirectoryURL] path] stringByAppendingPathComponent:folderName];
    return [NSURL fileURLWithPath:pluginPath];
}

- (NSURL*)pluginsDirectoryURL;
{
    return [NSURL fileURLWithPath:[pluginsDirectoryPath stringByExpandingTildeInPath]];
}

@end



