//
//  NSTask+CompletionWithOutput.h
//  ExampleProject
//
//  Created by Markus Emrich on 08.03.13.
//  Copyright (c) 2013 nxtbgthng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^NSTaskWithOutputCompletionBlock)(NSTask* task, NSString* output);

@interface NSTask (CompletionWithOutput)

+ (NSTask*)launchedTaskWithLaunchPath:(NSString*)launchPath
                            arguments:(NSArray*)arguments
                           completion:(NSTaskWithOutputCompletionBlock)completion;

+ (NSTask*)launchedTaskWithLaunchPath:(NSString*)launchPath
                            arguments:(NSArray*)arguments
                 currentDirectoryPath:(NSString*)currentDirectoryPath
                           completion:(NSTaskWithOutputCompletionBlock)completion;

@end
