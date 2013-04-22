//
//  JDPluginsWindowController.h
//  JDPluginManager
//
//  Created by Danny Shmueli on 4/6/13.
//
//
#import "JDPluginsRepository.h"
#import <Cocoa/Cocoa.h>

@interface JDPluginsWindowController : NSWindowController <NSTableViewDataSource, JDExtraPluginsDataLoaderDelegate>
{
    IBOutlet NSTableView *_pluginsTableView;
    IBOutlet NSSegmentedControl *_segmentControl;
}

@property (nonatomic, retain) IBOutlet NSTableView *pluginsTableView;
@property (nonatomic, retain) IBOutlet NSSegmentedControl *segmentControl;
@property (nonatomic, readonly) BOOL segmentControlSetOnAvailablePlugins;

-(IBAction)segmentedControllerChangedSelection:(id)sender;
-(IBAction)didPressInstallOrUnInstallButton:(id)sender;
-(IBAction)didPressViewReadmeButton:(id)sender;
-(IBAction)didPressViewOnGithubButton:(id)sender;
-(IBAction)didPressUpdateButton:(id)sender;
-(IBAction)didPressRevealInFinderButton:(id)sender;

@end
