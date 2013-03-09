//
//  NSTaskWithProgress.h
//  ExampleProject
//
//  Created by Markus Emrich on 08.03.13.
//  Copyright (c) 2013 nxtbgthng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^NSTaskWithOutputProgressBlock)(NSTask* task, NSString* output);

@interface NSTaskWithProgress : NSObject {
    NSTask* _task;
    NSTaskWithOutputProgressBlock _progressBlock;
}

@property (nonatomic, readonly) NSTask *task;

+ (NSTaskWithProgress*)launchedTaskWithLaunchPath:(NSString*)launchPath
                                        arguments:(NSArray*)arguments
                                         progress:(NSTaskWithOutputProgressBlock)progressBlock
                                       completion:(NSTaskWithOutputProgressBlock)completionBlock;

+ (NSTaskWithProgress*)launchedTaskWithLaunchPath:(NSString*)launchPath
                                        arguments:(NSArray*)arguments
                             currentDirectoryPath:(NSString*)currentDirectoryPath
                                         progress:(NSTaskWithOutputProgressBlock)progressBlock
                                       completion:(NSTaskWithOutputProgressBlock)completionBlock;


- (id)initWithLaunchPath:(NSString*)launchPath
               arguments:(NSArray*)arguments
    currentDirectoryPath:(NSString*)currentDirectoryPath
                progress:(NSTaskWithOutputProgressBlock)progressBlock
              completion:(NSTaskWithOutputProgressBlock)completionBlock;

@end
