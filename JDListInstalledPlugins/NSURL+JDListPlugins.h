//
//  NSURL+JDListPlugins.h
//  JDListInstalledPlugins
//
//  Created by Markus Emrich on 05.02.13.
//
//

#import <Foundation/Foundation.h>

extern NSString *const xcodePluginSuffix;

@interface NSURL (JDListPlugins)

+ (NSURL*)pluginURLForPluginNamed:(NSString*)pluginName;
+ (NSURL*)pluginsDirectoryURL;

@end
