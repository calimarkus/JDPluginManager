//
//  JDPluginMetaData.m
//  ExampleProject
//
//  Created by Markus Emrich on 09.03.13.
//  Copyright (c) 2013 nxtbgthng. All rights reserved.
//

#import "JDPluginMetaData.h"

NSString *const JDPluginManagerMetaDataFileName = @".JDPluginManager.meta";
NSString *const JDPluginManagerMetaDataReadmeName = @"README.md";

NSString *const JDPluginManagerMetaDataRepositoryKey = @"JDPluginManagerMetaDataRepositoryKey";
NSString *const JDPluginManagerMetaDataReadmePathKey = @"JDPluginManagerMetaDataReadmePathKey";

@interface JDPluginMetaData ()
@property (nonatomic, copy) NSString *pluginPath;
@end

@implementation JDPluginMetaData

@synthesize dictionary = _dictionary;
@synthesize pluginPath = _pluginPath;

+ (JDPluginMetaData*)metaDataForPluginAtPath:(NSString*)pluginPath;
{
    NSString *path = [pluginPath stringByAppendingPathComponent:JDPluginManagerMetaDataFileName];

    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSMutableDictionary *dictionary = [[[NSDictionary dictionaryWithContentsOfFile:path] mutableCopy] autorelease];
        
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
        _pluginPath = [pluginPath copy];
        _dictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    self.dictionary = nil;
    self.pluginPath = nil;
    [super dealloc];
}

- (void)findAndSetReadmeAtBuildPath:(NSString*)buildPath;
{
    NSString *sourcePath = [buildPath stringByAppendingPathComponent:@"README.md"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:sourcePath]) {
        sourcePath = [buildPath stringByAppendingPathComponent:@"README"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:sourcePath]) {
            sourcePath = [buildPath stringByAppendingPathComponent:@"readme"];
            if (![[NSFileManager defaultManager] fileExistsAtPath:sourcePath]) {
                return;
            }
        }
    }
    
    NSString *targetPath = [self.pluginPath stringByAppendingPathComponent:JDPluginManagerMetaDataReadmeName];
    [[NSFileManager defaultManager] removeItemAtPath:targetPath error:nil];
    if([[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:targetPath error:nil]) {
        [self.dictionary setObject:targetPath forKey:JDPluginManagerMetaDataReadmePathKey];
        [self save];
    } else {
        NSLog(@"ERROR copying readme");
    }
}

- (BOOL)save;
{
    NSString *path = [self.pluginPath stringByAppendingPathComponent:JDPluginManagerMetaDataFileName];
    BOOL succes = [self.dictionary writeToFile:path atomically:YES];
    
    if (!succes) {
        NSLog(@"error saving metadata");
    }
    
    return succes;
}

@end
