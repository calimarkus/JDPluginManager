//
//  JDPluginsCellView.m
//  JDPluginManager
//
//  Created by Danny Shmueli on 4/11/13.
//
//

#import "JDPluginsCellView.h"

@implementation JDPluginsCellView

-(void)setCellWithPluginMetaData:(JDPluginMetaData *)pluginData canBeInstalled:(BOOL)canBeInstalled
{
    subTitleTextField.stringValue = pluginData.gitHubDescription ? pluginData.gitHubDescription : @"Loading...";
    self.textField.stringValue = pluginData.name;
    installUnInstallButton.title = canBeInstalled ? @"Install" : @"UnInstall";
    revealInFinderButton.hidden = canBeInstalled;
    lastPushDate.stringValue = pluginData.lastPushDate ? [pluginData.lastPushDate description] : @"";
    BOOL doesPluginNeedsUpdate = pluginData.needsUpdate;
    NSLog(@"plugins needs update: %@", doesPluginNeedsUpdate ? @"YES" : @"NO");
    needsUpdateButton.hidden = !pluginData.needsUpdate;
}

@end
