//
//  JDPluginsCellView.m
//  JDPluginManager
//
//  Created by Danny Shmueli on 4/11/13.
//
//

#import "JDPluginsCellView.h"

@implementation JDPluginsCellView

-(void)setCellWithPluginMetaData:(JDPluginMetaData*)pluginData
               isInstalledPlugin:(BOOL)isInstalledPlugin
{
    self.textField.stringValue = pluginData.name;
    
    if (pluginData.gitHubDescription.length > 0) {
        subTitleTextField.stringValue = pluginData.gitHubDescription;
    } else if (!pluginData.gitHubDescription) {
        subTitleTextField.stringValue = @"Loading Description from GitHub...";
    } else {
        subTitleTextField.stringValue = @"No Description";
    }
    
    installUnInstallButton.title  = isInstalledPlugin ? @"Uninstall" : @"Install";
    revealInFinderButton.hidden = !isInstalledPlugin;
    lastPushDate.stringValue = pluginData.lastPushDate ? [pluginData.lastPushDate description] : @"";
    needsUpdateButton.hidden = !pluginData.needsUpdate;
    readmeButton.hidden = !isInstalledPlugin;
    
    NSLog(@"%@ / %@", pluginData.name, pluginData.gitHubDescription);
}

@end
