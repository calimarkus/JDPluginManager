//
//  NSFileManager+JDPluginManager.m
//  ExampleProject
//
//  Created by Markus Emrich on 09.03.13.
//  Copyright (c) 2013 nxtbgthng. All rights reserved.
//

#import "NSURL+JDPluginManager.h"

#import "NSFileManager+JDPluginManager.h"

NSString const* JDPluginNameKey = @"JDPluginNameKey";
NSString const* JDPluginModifiedDate = @"JDPluginModifiedDate";


@implementation NSFileManager (JDPluginManager)

+ (NSArray*)allPluginsWithModifiedDate:(BOOL)withModifiedDate;
{
    NSError* error = nil;
    NSArray* filesArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[NSURL pluginsDirectoryURL] path] error:&error];
    if(error != nil) {
        NSLog(@"error getting plugin files at path %@", [[NSURL pluginsDirectoryURL] path]);
        return nil;
    }
    
    // order by name
    filesArray = [filesArray sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    
    // return only files
    if (!withModifiedDate) {
        return filesArray;
    }
    
    // read modified date
    NSMutableArray* filesAndProperties = [NSMutableArray arrayWithCapacity:[filesArray count]];
    for(NSString* file in filesArray) {
        NSString* filePath = [[[NSURL pluginsDirectoryURL] path] stringByAppendingPathComponent:file];
        NSDictionary* properties = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
        NSDate* modDate = [properties objectForKey:NSFileModificationDate];
        
        if(error != nil) {
            NSLog(@"error reading modified date for file %@", file);
            continue;
        }
        
        [filesAndProperties addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                       file, JDPluginNameKey,
                                       modDate, JDPluginModifiedDate,
                                       nil]];
    }
    
    return filesAndProperties;
}

+(NSArray *)readPluginsJSONFile
{
    @try {
        NSBundle *pluginBundle = [NSBundle bundleWithIdentifier:@"com.nxtbgthng.JDPluginManager"];
        NSString *pluginsJSONPath = [pluginBundle pathForResource:@"plugins" ofType:@"json"];
        if (!pluginsJSONPath) return nil;
        NSData *pluginsJSONData = [NSData dataWithContentsOfFile:pluginsJSONPath];
        if (!pluginsJSONData)
        {
            return nil;
        }
        NSError *error;
        id plugins = [NSJSONSerialization JSONObjectWithData:pluginsJSONData options:NSJSONReadingAllowFragments error:&error];
        NSArray *plgns = plugins;
        return plgns;

    }
    @catch (NSException *exception) {
        NSLog(@"json error: %@", exception.userInfo);
    }
    @finally {
        
    }
}
@end
