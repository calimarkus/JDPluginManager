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
    // name
    self.textField.stringValue = pluginData.name;
    
    // description
    if (pluginData.gitHubDescription.length > 0) {
        subTitleTextField.stringValue = pluginData.gitHubDescription;
    } else if (!pluginData.gitHubDescription) {
        subTitleTextField.stringValue = @"Loading Description from GitHub...";
    } else {
        subTitleTextField.stringValue = @"No Description";
    }
    
    // date
    lastPushDate.stringValue = pluginData.lastPushDate ? [pluginData.lastPushDate description] : @"";

    // install button
    installUnInstallButton.title  = isInstalledPlugin ? @"Uninstall" : @"Install";

    // button hiding
    needsUpdateButton.hidden = !pluginData.needsUpdate;
    revealInFinderButton.hidden = !isInstalledPlugin;
    readmeButton.hidden = !isInstalledPlugin;
}

@end
