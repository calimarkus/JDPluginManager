//
//  JDPluginsRepository.m
//  JDPluginManager
//
//  Created by Danny Shmueli on 4/6/13.
//
//

#import "JDPluginsRepository.h"
#import "NSFileManager+JDPluginManager.h"
#import "NSURL+JDPluginManager.h"
#import "JDPluginMetaData.h"
#import "JDAvialablePluginsLoader.h"

@interface  JDPluginsRepository  ()

@end

@implementation JDPluginsRepository

@synthesize installedPlugins = _installedPlugins;
@synthesize availablePlugins = _availablePlugins;


+(JDPluginsRepository *)sharedInstance
{
    static id sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
    return sharedInstance;
}

-(id)init
{
    self = [super init];
    if (!self) return nil;
    NSArray *pluginsNames = [NSFileManager allPluginsWithModifiedDate:NO];
    self.installedPlugins = [NSMutableArray arrayWithCapacity:pluginsNames.count];
    [pluginsNames enumerateObjectsUsingBlock:^(NSString *pluginFile, NSUInteger idx, BOOL *stop) {
        if ([pluginFile hasSuffix:xcodePluginSuffix]) {
            // remove suffix
            pluginFile = [pluginFile stringByReplacingOccurrencesOfString:xcodePluginSuffix withString:@""];
            
            // get plugin extra data
            JDPluginMetaData *pluginMetaData = [JDPluginMetaData metaDataForPluginAtPath:[[NSURL pluginURLForPluginNamed:pluginFile] path] andName:pluginFile];
            [self.installedPlugins addObject:pluginMetaData];
        }
    }];
    
    self.availablePlugins = [JDAvialablePluginsLoader getAvailabePlugins];
    return self;
}



@end
