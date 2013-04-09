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
@synthesize segmentControl = _segmentControl;
@synthesize pluginsTableView = _pluginsTableView;

-(BOOL *)segmentControlSetOnAvailablePlugins
{
   return self.segmentControl.selectedSegment == 0;
}

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
-(IBAction)segmentedControllerChangedSelection:(id)sender
{
    [self.pluginsTableView reloadData];
}

#
#pragma mark - Table management
#
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	return self.segmentControlSetOnAvailablePlugins ? [JDPluginsRepository sharedInstance].availablePlugins.count :[JDPluginsRepository sharedInstance].installedPlugins.count;
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	JDPluginMetaData *pluginMetaData =  self.segmentControlSetOnAvailablePlugins ? [[JDPluginsRepository sharedInstance].availablePlugins objectAtIndex: row] : [[JDPluginsRepository sharedInstance].installedPlugins objectAtIndex: row];
    
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
