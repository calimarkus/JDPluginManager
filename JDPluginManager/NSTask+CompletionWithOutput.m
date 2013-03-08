//
//  NSTask+CompletionWithOutput.m
//  ExampleProject
//
//  Created by Markus Emrich on 08.03.13.
//  Copyright (c) 2013 nxtbgthng. All rights reserved.
//

#import "NSTask+CompletionWithOutput.h"

@implementation NSTask (CompletionWithOutput)

+ (NSTask*)launchedTaskWithLaunchPath:(NSString*)launchPath
                            arguments:(NSArray*)arguments
                           completion:(NSTaskWithOutputCompletionBlock)completion;
{
    return [self launchedTaskWithLaunchPath:launchPath
                                  arguments:arguments
                       currentDirectoryPath:nil
                                 completion:completion];
}

+ (NSTask*)launchedTaskWithLaunchPath:(NSString*)launchPath
                            arguments:(NSArray*)arguments
                 currentDirectoryPath:(NSString*)currentDirectoryPath
                           completion:(NSTaskWithOutputCompletionBlock)completion;
{
    NSParameterAssert(launchPath);
    
    NSTask *task = [[NSTask alloc] init];
    [task setStandardOutput:[NSPipe pipe]];
    [task setStandardError:[NSPipe pipe]];
    [task setLaunchPath:launchPath];
    
    if (arguments != nil && arguments.count > 0) {
        [task setArguments:arguments];
    }
    
    if (currentDirectoryPath != nil) {
        [task setCurrentDirectoryPath:currentDirectoryPath];
    }
    
    [task setTerminationHandler:^(NSTask* task)
     {
         NSString* outputString = nil;
         
         // catch standard output
         if ([task terminationStatus] == 0) {
             NSPipe* outPipe = task.standardOutput;
             NSData* output = [[outPipe fileHandleForReading] readDataToEndOfFile];
             outputString = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
         }
         
         // catch errors
         else {
             NSPipe* errorPipe = task.standardError;
             NSData* error = [[errorPipe fileHandleForReading] readDataToEndOfFile];
             outputString = [[NSString alloc] initWithData:error encoding:NSUTF8StringEncoding];
         }
         
         // call completion block
         if (completion) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 completion(task,outputString);
             });
         }
     }];
    [task launch];
    
    return task;
}

@end





