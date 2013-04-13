//
//  JDPluginsCellView.h
//  JDPluginManager
//
//  Created by Danny Shmueli on 4/11/13.
//
//

#import <Cocoa/Cocoa.h>
#import "JDPluginMetaData.h"

@interface JDPluginsCellView : NSTableCellView
{
    IBOutlet NSTextField *subTitleTextField, *lastPushDate;
    IBOutlet NSButton *installUnInstallButton, *needsUpdateButton, *revealInFinderButton;
}

-(void)setCellWithPluginMetaData:(JDPluginMetaData *)pluginData isInstalledPlugin:(BOOL)isInstalledPlugin;
@end
