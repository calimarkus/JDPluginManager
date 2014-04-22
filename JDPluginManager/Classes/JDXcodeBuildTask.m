//
//  JDXcodeBuildTask.m
//  ExampleProject
//
//  Created by Markus Emrich on 09.03.13.
//  Copyright (c) 2013 nxtbgthng. All rights reserved.
//


#import "global.h"
#import "JDInstallProgressWindow.h"

#import "JDXcodeBuildTask.h"

NSString *const xcodeBuildPath = @"/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild";


@interface JDXcodeBuildTask ()
@property (atomic, strong) NSMutableString *allXcodeBuildOutput;
@property (atomic, copy) NSString *previousProgressText;
@end

@implementation JDXcodeBuildTask

@synthesize allXcodeBuildOutput = _allXcodeBuildOutput;
@synthesize previousProgressText = _previousProgressText;

+ (instancetype)launchedTaskWithCurrentDirectoryPath:(NSString*)currentDirectory
                                      progressWindow:(JDInstallProgressWindow*)progressWindow
                                          completion:(void(^)())completion
{
    JDXcodeBuildTask *task = [[JDXcodeBuildTask alloc] initWithCurrentDirectoryPath:currentDirectory
                                                                     progressWindow:progressWindow
                                                                         completion:completion];
    [task.task launch];
    return task;
}

- (id)initWithCurrentDirectoryPath:(NSString*)currentDirectory
                                      progressWindow:(JDInstallProgressWindow*)progressWindow
                                          completion:(void(^)())completion
{
    completion = [completion copy];
    [progressWindow appendTitle:JDLocalize(@"keyInstallBuildMessage")];
    
    self = [super initWithLaunchPath:xcodeBuildPath arguments:nil currentDirectoryPath:currentDirectory progress:^(NSTask *task, NSString *output) {
        [self handleXcodeBuildOutput:output inProgressWindow:progressWindow];
    } completion:^(NSTask *task, NSString *output) {
        [self handleXcodeBuildOutput:output inProgressWindow:progressWindow];
        if (completion) {
            completion();
        }
    }];
    
    if (self) {
        _allXcodeBuildOutput = [[NSMutableString alloc] init];
        _previousProgressText = [progressWindow.textView.string copy];
    }
    
    return self;
}


#pragma mark handle output

- (void)handleXcodeBuildOutput:(NSString*)output
       inProgressWindow:(JDInstallProgressWindow*)progressWindow
{
    [self.allXcodeBuildOutput appendString:output];
    
    progressWindow.textView.string = [NSString stringWithFormat: @"%@%@\n",
                                      self.previousProgressText,
                                      [self minimizedXcodeBuildOutput]];
    [progressWindow scrollToBottom];
}

- (NSString*)minimizedXcodeBuildOutput
{
    NSMutableString *minimizedOutput = [NSMutableString string];
    NSArray *allLines = [self.allXcodeBuildOutput componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for (NSString *line in allLines) {
        for (NSString *search in @[@"BUILD", @"ERROR", @"error"]) {
            if ([line rangeOfString:search].length > 0) {
                [minimizedOutput appendFormat:@"\n%@\n", line];
            }
        }
    }
    return [minimizedOutput stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
