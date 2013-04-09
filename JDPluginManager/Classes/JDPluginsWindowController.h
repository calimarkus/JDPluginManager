//
//  JDPluginsWindowController.h
//  JDPluginManager
//
//  Created by Danny Shmueli on 4/6/13.
//
//

#import <Cocoa/Cocoa.h>

@interface JDPluginsWindowController : NSWindowController <NSTableViewDataSource>
{
    IBOutlet NSTableView *_pluginsTableView;
    IBOutlet NSSegmentedControl *_segmentControl;
}
@property (nonatomic, retain) IBOutlet NSTableView *pluginsTableView;
@property (nonatomic, retain) IBOutlet NSSegmentedControl *segmentControl;
@property (nonatomic, readonly) BOOL *segmentControlSetOnAvailablePlugins;

-(IBAction)segmentedControllerChangedSelection:(id)sender;
@end
