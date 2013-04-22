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
    IBOutlet NSTextField *subTitleTextField;
    IBOutlet NSTextField *lastPushDate;
    
    IBOutlet NSButton *installUnInstallButton;
    IBOutlet NSButton *readmeButton;
    IBOutlet NSButton *needsUpdateButton;
    IBOutlet NSButton *revealInFinderButton;
}

-(void)setCellWithPluginMetaData:(JDPluginMetaData*)pluginData
               isInstalledPlugin:(BOOL)isInstalledPlugin;

@end
