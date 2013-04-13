//
//  JDPluginsWindowController.m
//  JDPluginManager
//
//  Created by Danny Shmueli on 4/6/13.
//
//

#import "JDPluginsWindowController.h"

#import "JDPluginMetaData.h"
#import "JDPluginInstaller.h"
#import "JDPluginsCellView.h"
#import "NSURL+JDPluginManager.h"
#import "global.h"


@implementation JDPluginsWindowController
@synthesize segmentControl = _segmentControl;
@synthesize pluginsTableView = _pluginsTableView;
@synthesize customInstallUrlTextField = _customInstallUrlTextField;

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
    [JDPluginsRepository sharedInstance].delegate = self;
    [[JDPluginsRepository sharedInstance] getPluginsExtraData];
    self.customInstallUrlTextField.stringValue =  JDLocalize(@"keyInstallAlertExampleText");
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
#pragma mark - Buttons
-(IBAction)segmentedControllerChangedSelection:(id)sender
{
    [self.pluginsTableView reloadData];
}
-(IBAction)didPressInstallOrUnInstallButton:(id)sender
{
    NSInteger selectedRow = [self.pluginsTableView rowForView:sender];
    JDPluginMetaData *pluginMetaData = [self getPluginMetaDataAtIndex:selectedRow];
    
    if (self.segmentControlSetOnAvailablePlugins)
    {
        //Install
        NSString *gitUrl = [pluginMetaData objectForKey:JDPluginManagerMetaDataRepositoryKey];
        [[[[JDPluginInstaller alloc] init] autorelease] beginInstallWithRepositoryPath:gitUrl searchInSubdirectories:NO];
    }
    else
    {
        //Uninstall
        [self removePlugin:pluginMetaData.name atIndexInTable:selectedRow];
    }
}

-(IBAction)didPressUpdateButton:(id)sender
{
    NSString *gitURL = [[self getPluginMetaDataFromSenderButtonInRow:sender ] objectForKey:JDPluginManagerMetaDataRepositoryKey];
    [[[[JDPluginInstaller alloc] init] autorelease] beginInstallWithRepositoryPath:gitURL searchInSubdirectories:NO];
}

-(IBAction)didPressViewReadmeButton:(id)sender
{
    NSString *readmePath = [[self getPluginMetaDataFromSenderButtonInRow:sender] objectForKey:JDPluginManagerMetaDataReadmePathKey];
    if (readmePath)
        [[NSWorkspace sharedWorkspace] openFile:readmePath];
}

-(IBAction)didPressViewOnGithubButton:(id)sender
{
    NSString *gitURL = [[self getPluginMetaDataFromSenderButtonInRow:sender] objectForKey:JDPluginManagerMetaDataRepositoryKey];
    gitURL = [gitURL stringByReplacingOccurrencesOfString:@"git@github.com:" withString:@"github.com/"];
    if (![gitURL hasPrefix:@"HTTP"] || ![gitURL hasPrefix:@"http"]) {
        gitURL = [NSString stringWithFormat: @"http://%@", gitURL];
    }
    NSURL *url = [NSURL URLWithString:gitURL];
    if (url) {
        [[NSWorkspace sharedWorkspace] openURL:url];
    }
}

-(void)removePlugin:(NSString *)name atIndexInTable:(NSInteger)indexInTable
{
    // construct alert
    NSAlert *alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:JDLocalize(@"keyUninstallAlertTitleFormat"), name]
                                     defaultButton:JDLocalize(@"keyUninstall")
                                   alternateButton:JDLocalize(@"keyCancel")
                                       otherButton:nil
                         informativeTextWithFormat:JDLocalize(@"keyUninstallAlertMessageFormat"), name];
    alert.alertStyle = NSCriticalAlertStyle;
    
    // show alert
    NSInteger selectedButtonIndex = [alert runModal];
    if (selectedButtonIndex == 0) {
        return;
    }
    
    // move plugin folder to trash
    NSString *pluginPath = [[NSURL pluginURLForPluginNamed:name] path];
    BOOL deleted = [[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
                                                                source:[pluginPath stringByDeletingLastPathComponent]
                                                           destination:@""
                                                                 files:[NSArray arrayWithObject:[pluginPath lastPathComponent]]
                                                                   tag:nil];
    if (deleted) {
        [[JDPluginsRepository sharedInstance] removedUnInstalledPlugin:indexInTable];
        [self.pluginsTableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:indexInTable] withAnimation:NSTableViewAnimationEffectFade];
    }
}
#
#pragma mark - Table management
#
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	NSInteger count =  self.segmentControlSetOnAvailablePlugins ? [JDPluginsRepository sharedInstance].availablePlugins.count :[JDPluginsRepository sharedInstance].installedPlugins.count;
    return count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	JDPluginMetaData *pluginMetaData = [self getPluginMetaDataAtIndex:row];
    
	if ([tableColumn.identifier isEqualToString:@"MainCell"]) {
        JDPluginsCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
        [cellView setCellWithPluginMetaData:pluginMetaData canBeInstalled: self.segmentControlSetOnAvailablePlugins];
        return cellView;
	}
    return nil;
    
}

#pragma makr- JDExtraPluginsDataLoaderDelegate
-(void)finishedLoadingExtraPluginsData
{
    NSLog(@"about to reload table with data");
    [self.pluginsTableView reloadData];
}

#pragma mark - Private
-(JDPluginMetaData *)getPluginMetaDataFromSenderButtonInRow:(id)sender
{
    NSInteger selectedRow = [self.pluginsTableView rowForView:sender];
    return[self getPluginMetaDataAtIndex:selectedRow];
}

-(JDPluginMetaData *)getPluginMetaDataAtIndex:(NSInteger)index
{
    return self.segmentControlSetOnAvailablePlugins ? [[JDPluginsRepository sharedInstance].availablePlugins objectAtIndex: index] : [[JDPluginsRepository sharedInstance].installedPlugins objectAtIndex: index];
}

@end
