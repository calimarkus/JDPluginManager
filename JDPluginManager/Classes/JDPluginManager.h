//
//  JDPluginManager.h
//  JDPluginManager
//
//  Created by Markus Emrich on 03.02.2013.
//
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "JDPluginsWindowController.h"


@interface JDPluginManager : NSObject{
    JDPluginsWindowController *_jdpm;
}
@property (nonatomic, retain) JDPluginsWindowController *jdpm;

- (void)extendXcodeMenu;
@end
