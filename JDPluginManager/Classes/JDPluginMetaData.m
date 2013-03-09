//
//  JDPluginMetaData.m
//  ExampleProject
//
//  Created by Markus Emrich on 09.03.13.
//  Copyright (c) 2013 nxtbgthng. All rights reserved.
//

#import "JDPluginMetaData.h"

NSString *const JDPluginManagerMetaDataFileName = @".JDPluginManager.meta";

NSString *const JDPluginManagerMetaDataRepositoryKey = @"JDPluginManagerMetaDataRepositoryKey";
NSString *const JDPluginManagerMetaDataReadmePathKey = @"JDPluginManagerMetaDataReadmePathKey";

@interface JDPluginMetaData ()
@property (nonatomic, strong) NSString *pluginPath;
@end

@implementation JDPluginMetaData

@synthesize dictionary = _dictionary;
@synthesize pluginPath = _pluginPath;

+ (JDPluginMetaData*)metaDataForPluginAtPath:(NSString*)pluginPath;
{
    NSString *path = [pluginPath stringByAppendingPathExtension:JDPluginManagerMetaDataFileName];

    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
        
        if (dictionary) {
            JDPluginMetaData *metaData = [[[JDPluginMetaData alloc] initWithPluginPath:pluginPath] autorelease];
            metaData.dictionary = dictionary;
            return metaData;
        }
    };
    
    return nil;
}

- (id)initWithPluginPath:(NSString*)pluginPath;
{
    self = [super init];
    if (self) {
        _pluginPath = pluginPath;
    }
    return self;
}

- (void)copyAndSetReadmeFromPath:(NSString*)readmePath;
{
    NSString *path = [self.pluginPath stringByAppendingPathExtension:@".jdpm-README"];
    if([[NSFileManager defaultManager] copyItemAtPath:readmePath toPath:path error:nil]) {
        [self.dictionary setValue:path forKey:JDPluginManagerMetaDataReadmePathKey];
        [self save];
    }
}

- (BOOL)save;
{
    NSString *path = [self.pluginPath stringByAppendingPathExtension:JDPluginManagerMetaDataFileName];
    return [self.dictionary writeToFile:path atomically:YES];
}

@end
