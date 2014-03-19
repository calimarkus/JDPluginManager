//
//  JDGitCloneTask.m
//  ExampleProject
//
//  Created by Markus Emrich on 09.03.13.
//  Copyright (c) 2013 nxtbgthng. All rights reserved.
//

#import "global.h"
#import "JDInstallProgressWindow.h"

#import "JDGitCloneTask.h"

NSString *const gitPath        = @"/usr/bin/git";
NSString *const tmpClonePath   = @"/tmp/JDPluginManager/";


@interface JDGitCloneTask ()
@property (atomic, strong) NSMutableString *allGitOutput;
@property (atomic, copy) NSString *previousProgressText;
@end

@implementation JDGitCloneTask

@synthesize allGitOutput = _allGitOutput;
@synthesize previousProgressText = _previousProgressText;

+ (instancetype)launchedTaskWithRepositoryPath:(NSString*)repositoryPath
                               progressWindow:(JDInstallProgressWindow*)progressWindow
                                   completion:(void(^)(NSString *clonePath))completion
{

    JDGitCloneTask *task = [[JDGitCloneTask alloc] initWithRepositoryPath:repositoryPath
                                                          progressWindow:progressWindow
                                                              completion:completion];
    [task.task launch];
    return task;
}

- (id)initWithRepositoryPath:(NSString*)repositoryPath
             progressWindow:(JDInstallProgressWindow*)progressWindow
                 completion:(void(^)(NSString *clonePath))completion
{
    [progressWindow appendTitle:JDLocalize(@"keyInstallCloneMessage")];
    [progressWindow appendLine:[NSString stringWithFormat: @"Repository: %@\n", repositoryPath]];
    
    NSString *clonePath = [tmpClonePath stringByAppendingPathComponent:[[repositoryPath lastPathComponent] stringByReplacingOccurrencesOfString:@".git" withString:@""]];
    NSArray *gitArgs = @[@"clone", repositoryPath, clonePath, @"--progress", @"--verbose"];

    self = [super initWithLaunchPath:gitPath arguments:gitArgs currentDirectoryPath:nil progress:^(NSTask *task, NSString *output) {
        [self handleGitOutput:output inProgressWindow:progressWindow];
    } completion:^(NSTask *task, NSString *output) {
        [self handleGitOutput:output inProgressWindow:progressWindow];
        if (completion) {
            completion(clonePath);
        }
    }];
    
    if (self) {
        _allGitOutput = [[NSMutableString alloc] init];
        _previousProgressText = [progressWindow.textView.string copy];
    }
    
    return self;
}


#pragma mark handle output

- (void)handleGitOutput:(NSString*)output
       inProgressWindow:(JDInstallProgressWindow*)progressWindow
{
    [self.allGitOutput appendString:output];

    progressWindow.textView.string = [NSString stringWithFormat: @"%@%@\n",
                                      self.previousProgressText,
                                      [self minimizedGitOutput]];
    [progressWindow scrollToBottom];
}

- (NSString*)minimizedGitOutput
{
    NSMutableString *minimizedOutput = [NSMutableString string];
    NSString *previousLine = nil;
    for (__strong NSString *line in [self.allGitOutput componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]) {
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        static NSInteger refLength = 15;
        if (previousLine && previousLine.length > refLength && line.length > refLength &&
            [[previousLine substringToIndex:refLength] isEqualToString:[line substringToIndex:refLength]]) {
            [minimizedOutput replaceOccurrencesOfString:previousLine withString:line options:NSBackwardsSearch range:NSMakeRange(0, minimizedOutput.length)];
        } else {
            [minimizedOutput appendFormat:@"%@\n", line];
        }
        previousLine = line;
    }
    return [minimizedOutput stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end



