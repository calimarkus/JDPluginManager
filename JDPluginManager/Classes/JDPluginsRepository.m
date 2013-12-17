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

@implementation JDPluginsRepository

@synthesize installedPlugins = _installedPlugins;
@synthesize availablePlugins = _availablePlugins;
@synthesize extraPluginsDataLoader = _extraPluginsDataLoader;

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
    NSArray *pluginsNamesAndInstallDates = [NSFileManager allPluginsWithModifiedDate:YES];
    self.installedPlugins = [NSMutableArray arrayWithCapacity:pluginsNamesAndInstallDates.count];
    [pluginsNamesAndInstallDates enumerateObjectsUsingBlock:^(NSDictionary *pluginNameAndDate, NSUInteger idx, BOOL *stop) {
        NSString *pluginFile = [pluginNameAndDate objectForKey:JDPluginNameKey];
        if ([pluginFile hasSuffix:xcodePluginSuffix]) {
            // remove suffix
            
            pluginFile = [pluginFile stringByReplacingOccurrencesOfString:xcodePluginSuffix withString:@""];
            
            // get plugin extra data
            JDPluginMetaData *pluginMetaData = [JDPluginMetaData metaDataForPluginAtPath:[[NSURL pluginURLForPluginNamed:pluginFile] path] andName:pluginFile];
            pluginMetaData.localPluginModifiedDate = [pluginNameAndDate objectForKey:JDPluginModifiedDate];
            [self.installedPlugins addObject:pluginMetaData];
        }
    }];
    
    self.availablePlugins = [NSMutableArray arrayWithArray:[JDAvialablePluginsLoader getAvailabePlugins]];
    [self removeInstalledPluginsFromAvailableList];
    return self;
}

-(void)getPluginsExtraDataWithDelegate:(id<JDExtraPluginsDataLoaderDelegate>)delegate
{
    if (self.extraPluginsDataLoader != nil) return; //we already got them
    self.extraPluginsDataLoader = [[JDExtraPluginsDataLoader alloc] init];
    self.extraPluginsDataLoader.delegate = delegate;
    [self.extraPluginsDataLoader getPluginsExtraDataFromGithub:[self.availablePlugins arrayByAddingObjectsFromArray:self.installedPlugins] ];
//    [self.extraPluginsDataLoader getPluginExtraDataFromGithub:self.installedPlugins];
}

-(void)removedUnInstalledPlugin:(NSInteger)index
{
    [self.installedPlugins removeObjectAtIndex:index];
}

-(void)removeInstalledPluginsFromAvailableList
{
    for (JDPluginMetaData *installedPlugin in self.installedPlugins)
    {
        NSUInteger indexOfObject =  [self.availablePlugins indexOfObjectPassingTest:^ BOOL (JDPluginMetaData* obj, NSUInteger idx, BOOL *stop)
                                     {
                                         return [obj.name isEqualToString: installedPlugin.name];
                                     }];
        if (indexOfObject == NSNotFound)
            continue;
        [self.availablePlugins removeObjectAtIndex:indexOfObject];
    }
}

@end
