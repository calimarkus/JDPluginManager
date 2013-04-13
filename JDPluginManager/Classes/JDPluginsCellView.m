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
    lastPushDate.stringValue = pluginData.lastPushDate ? [pluginData.lastPushDate description] : @"";
    needsUpdateButton.hidden = !pluginData.needsUpdate;
}

@end
