//
//  NSFileManager+JDPluginManager.h
//  ExampleProject
//
//  Created by Markus Emrich on 09.03.13.
//  Copyright (c) 2013 nxtbgthng. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString const* JDPluginNameKey;
extern NSString const* JDPluginModifiedDate;


@interface NSFileManager (JDPluginManager)

+ (NSArray*)allPluginsWithModifiedDate:(BOOL)withModifiedDate;

@end
