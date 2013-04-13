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

    NSMutableArray *availablePlugins = [NSMutableArray arrayWithCapacity:availablePluginsJSONArray.count];
    for (NSDictionary *plugin in availablePluginsJSONArray)
    {
        NSString *repoPath = [plugin objectForKey:@"git"];
        NSString *name = [plugin objectForKey:@"title"];
        JDPluginMetaData *pluginMetaData = [[JDPluginMetaData alloc] initWithPluginPath:nil andName:name];
        
        [pluginMetaData setObject:repoPath forKey:JDPluginManagerMetaDataRepositoryKey];
        [availablePlugins addObject:pluginMetaData];
    }
    
    return availablePlugins;
}

@end
