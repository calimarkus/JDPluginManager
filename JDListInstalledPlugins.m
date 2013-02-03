//
//  JDListInstalledPlugins.m
//  JDListInstalledPlugins
//
//  Created by Markus Emrich on 03.02.2013.
//
//

#import "JDListInstalledPlugins.h"


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
	NSMenuItem *editMenuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
	if (editMenuItem) {
        // separator
		[[editMenuItem submenu] addItem:[NSMenuItem separatorItem]];
		
        // main item
		NSMenuItem *installedPluginsItem = [[[NSMenuItem alloc] initWithTitle:@"Installed Plugins" action:@selector(showPlugin:) keyEquivalent:@""] autorelease];
        [installedPluginsItem setSubmenu:[[[NSMenu alloc] initWithTitle:@"Installed Plugins"] autorelease]];
		[installedPluginsItem setTarget:self];
		[[editMenuItem submenu] addItem:installedPluginsItem];
		
        // add each plugin as subitem
        NSString *pluginsPath = [[self pluginsDirectoryURL] path];
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pluginsPath error:nil];
        [contents enumerateObjectsUsingBlock:^(NSString *file, NSUInteger idx, BOOL *stop) {
            if ([file hasSuffix:@".xcplugin"]) {
                // remove suffix
                file = [file stringByReplacingOccurrencesOfString:@".xcplugin" withString:@""];
                
                // add menu item
                NSMenuItem *pluginItem = [[[NSMenuItem alloc] initWithTitle:file action:@selector(showPlugin:) keyEquivalent:@""] autorelease];
                pluginItem.tag = 99;
                [pluginItem setTarget:self];
                [[installedPluginsItem submenu] addItem:pluginItem];
            }
        }];
    }
}

- (void)showPlugin:(NSMenuItem*)sender
{
    NSURL *url = [self pluginsDirectoryURL];
    
    if (sender.tag == 99) {
        NSString *folderName = [NSString stringWithFormat: @"%@.xcplugin/", sender.title];
        NSString *pluginPath = [[url path] stringByAppendingPathComponent:folderName];
        url = [NSURL fileURLWithPath:pluginPath];
    }
    
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[url]];
}

- (NSURL*)pluginsDirectoryURL;
{
    NSString *pluginDirectory = @"~/Library/Application Support/Developer/Shared/Xcode/Plug-ins";
    return [NSURL fileURLWithPath:[pluginDirectory stringByExpandingTildeInPath]];
}

@end
