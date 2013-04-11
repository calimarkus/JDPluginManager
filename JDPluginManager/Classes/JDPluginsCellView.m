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
    subTitleTextField.stringValue = @"ssklsjslkjs";
    self.textField.stringValue = pluginData.name;
    installUnInstallButton.title = canBeInstalled ? @"Install" : @"UnInstall";
}

@end
