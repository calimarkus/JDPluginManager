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
    NSMutableDictionary* _dictionary;
    NSString* _pluginPath;
}

@property (nonatomic, strong) NSMutableDictionary *dictionary;

+ (JDPluginMetaData*)metaDataForPluginAtPath:(NSString*)pluginPath;

- (id)initWithPluginPath:(NSString*)pluginPath;

- (void)findAndSetReadmeAtBuildPath:(NSString*)buildPath;
- (BOOL)save;

@end
