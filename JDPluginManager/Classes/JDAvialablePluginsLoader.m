//
//  JDAvialablePluginsLoader.m
//  JDPluginManager
//
//  Created by Danny Shmueli on 4/8/13.
//
//

#import "JDAvialablePluginsLoader.h"
#import "NSFileManager+JDPluginManager.h"
#import "JDPluginMetaData.h"

@implementation JDAvialablePluginsLoader

+(NSArray *)getAvailabePlugins
{
    NSArray *availablePluginsJSONArray = [NSFileManager readPluginsJSONFile];

    NSLog(@"plugins json array count: %li", (unsigned long)availablePluginsJSONArray.count);
    NSMutableArray *availablePlugins = [NSMutableArray arrayWithCapacity:availablePluginsJSONArray.count];
    for (NSDictionary *plugin in availablePluginsJSONArray)
    {
        NSString *repoPath = [plugin objectForKey:@"git"];
        NSString *description = [plugin objectForKey:@"description"];
        NSString *name = [plugin objectForKey:@"title"];
        JDPluginMetaData *pluginMetaData = [[JDPluginMetaData alloc] initWithPluginPath:repoPath andName:name];
        NSLog(@"plugin added: %@", pluginMetaData.description);
        [availablePlugins addObject:pluginMetaData];
    }
    
    return availablePlugins;
}

@end
