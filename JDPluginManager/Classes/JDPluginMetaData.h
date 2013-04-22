//
//  JDPluginMetaData.h
//  ExampleProject
//
//  Created by Markus Emrich on 09.03.13.
//  Copyright (c) 2013 nxtbgthng. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const JDPluginManagerMetaDataRepositoryKey;
extern NSString *const JDPluginManagerMetaDataReadmePathKey;

@interface JDPluginMetaData : NSObject {
    NSMutableDictionary *_dictionary;
    NSString *_pluginPath;
    NSString *_name;
    NSString *_gitHubDescription;
    NSDate *_lastPushDate, *_localPluginModifiedDate;
}

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *gitHubApiRepoURL;
@property (nonatomic, copy) NSString *gitHubDescription;

@property (nonatomic, strong) NSDate *lastPushDate;
@property (nonatomic, strong) NSDate *localPluginModifiedDate;
@property (nonatomic, readonly) BOOL needsUpdate;

+ (JDPluginMetaData*)metaDataForPluginAtPath:(NSString*)pluginPath;
+ (JDPluginMetaData*)metaDataForPluginAtPath:(NSString*)pluginPath andName:(NSString *)name;

- (id)initWithPluginPath:(NSString*)pluginPath;
- (id)initWithPluginPath:(NSString*)pluginPath andName:(NSString *)name;

- (id)objectForKey:(id)aKey;
- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey;

- (void)findAndSetReadmeAtBuildPath:(NSString*)buildPath;
- (BOOL)save;

@end
