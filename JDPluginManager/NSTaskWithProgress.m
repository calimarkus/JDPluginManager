//
//  NSTaskWithProgress.m
//  ExampleProject
//
//  Created by Markus Emrich on 08.03.13.
//  Copyright (c) 2013 nxtbgthng. All rights reserved.
//

#import "NSTaskWithProgress.h"


@interface NSTaskWithProgress ()
@property (nonatomic, strong) NSTask *task;
@property (nonatomic, copy) NSTaskWithOutputProgressBlock progressBlock;
@end

@implementation NSTaskWithProgress

+ (NSTaskWithProgress*)launchedTaskWithLaunchPath:(NSString*)launchPath
                            arguments:(NSArray*)arguments
                             progress:(NSTaskWithOutputProgressBlock)progressBlock
                           completion:(NSTaskWithOutputProgressBlock)completionBlock;
{
    return [self launchedTaskWithLaunchPath:launchPath
                                  arguments:arguments
                       currentDirectoryPath:nil
                                   progress:progressBlock
                                 completion:completionBlock];
}

+ (NSTaskWithProgress*)launchedTaskWithLaunchPath:(NSString*)launchPath
                            arguments:(NSArray*)arguments
                 currentDirectoryPath:(NSString*)currentDirectoryPath
                             progress:(NSTaskWithOutputProgressBlock)progressBlock
                           completion:(NSTaskWithOutputProgressBlock)completionBlock;
{
    return [[NSTaskWithProgress alloc] initWithLaunchPath:launchPath
                                                arguments:arguments
                                     currentDirectoryPath:currentDirectoryPath
                                                 progress:progressBlock
                                               completion:completionBlock];
}

#pragma mark NSTaskWithProgress

- (id)initWithLaunchPath:(NSString*)launchPath
    arguments:(NSArray*)arguments
    currentDirectoryPath:(NSString*)currentDirectoryPath
    progress:(NSTaskWithOutputProgressBlock)progressBlock
    completion:(NSTaskWithOutputProgressBlock)completionBlock;
{
    self = [super init];
    if (self) {
        NSParameterAssert(launchPath);
        
        // setup task
        NSTask *task = [[NSTask alloc] init];
        [task setStandardOutput:[NSPipe pipe]];
        [task setStandardError:[NSPipe pipe]];
        [task setLaunchPath:launchPath];
        self.task = task;
        [task release];
        
        // set arguments, if available
        if (arguments != nil && arguments.count > 0) {
            [task setArguments:arguments];
        }
        
        // set current dir, if available
        if (currentDirectoryPath != nil) {
            [task setCurrentDirectoryPath:currentDirectoryPath];
        }
        
        // setup constant updates
        self.progressBlock = progressBlock;
        NSFileHandle* fileHandle = [[task standardOutput] fileHandleForReading];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(readPipe:)
                                                     name:NSFileHandleReadCompletionNotification
                                                   object:fileHandle];
        [fileHandle readInBackgroundAndNotify];
        
        // setup completion block
        [task setTerminationHandler:^(NSTask* task)
         {
             // unregister from updates
             [[NSNotificationCenter defaultCenter] removeObserver:self
                                                             name:NSFileHandleReadCompletionNotification
                                                           object:fileHandle];
             
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
             if (completionBlock) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     completionBlock(task,outputString);
                 });
             }
         }];
        
        // launch task
        [task launch];
    }
    return self;
}

- (void)dealloc
{
    self.task = nil;
    self.progressBlock = nil;
    
    [super dealloc];
}

- (void)readPipe:(NSNotification*)notification;
{
    if (self.progressBlock) {
        NSData *data = [notification.userInfo objectForKey:NSFileHandleNotificationDataItem];
        NSString *readData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressBlock(self,readData);
        });
    }
    
    // stay reading
    [[[self.task standardOutput] fileHandleForReading] readInBackgroundAndNotify];
}

@end





