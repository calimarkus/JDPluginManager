//
//  JDPluginsWindowController.m
//  JDPluginManager
//
//  Created by Danny Shmueli on 4/6/13.
//
//

#import "JDPluginsWindowController.h"
#import "JDPluginsRepository.h"
#import "JDPluginMetaData.h"

@interface JDPluginsWindowController ()

@end

@implementation JDPluginsWindowController

-(id)init
{
    self = [super initWithWindowNibName:@"JDPluginsWindowController"];
	if (!self) return nil;
    return self;

}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

#
#pragma mark - Table management
#
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSLog(@"About to return count: %li", (unsigned long)[JDPluginsRepository sharedInstance].installedPlugins.count);
	return [JDPluginsRepository sharedInstance].installedPlugins.count;
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	JDPluginMetaData *pluginMetaData = [[JDPluginsRepository sharedInstance].installedPlugins objectAtIndex: row];
    NSLog(@"Table column identifier: %@", tableColumn.identifier);
	if ([tableColumn.identifier isEqualToString:@"Name"]) {
		return pluginMetaData.name;
	}
	else if ([tableColumn.identifier isEqualToString:@"Description"]) {
		return @"Plugin description";
	}
    else if ([tableColumn.identifier isEqualToString:@"Action"]) {
		return @"Plugins actions";
	}
	return @"Yikes!";
}

@end
