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
@property (atomic, strong) NSString *previousProgressText;
@end

@implementation JDGitCloneTask

+ (instancetype)launchedTaskWithRepositoryURL:(NSString*)repositoryURL
                               progressWindow:(JDInstallProgressWindow*)progressWindow
                                   completion:(void(^)(NSString *clonePath))completion;
{

    JDGitCloneTask *task = [[JDGitCloneTask alloc] initWithRepositoryURL:repositoryURL
                                                          progressWindow:progressWindow
                                                              completion:completion];
    [task.task launch];
    return task;
}

- (id)initWithRepositoryURL:(NSString*)repositoryURL
             progressWindow:(JDInstallProgressWindow*)progressWindow
                 completion:(void(^)(NSString *clonePath))completion;
{
    [progressWindow appendLine:[NSString stringWithFormat:JDLocalize(@"keyInstallCloneMessageFormat"), repositoryURL]];
    
    NSString *clonePath = [tmpClonePath stringByAppendingPathComponent:[[repositoryURL lastPathComponent] stringByReplacingOccurrencesOfString:@".git" withString:@""]];
    NSArray *gitArgs = @[@"clone", repositoryURL, clonePath, @"--progress", @"--verbose"];

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

- (void)dealloc
{
    self.allGitOutput = nil;
    self.previousProgressText = nil;
    [super dealloc];
}

#pragma mark handle output

- (void)handleGitOutput:(NSString*)output
       inProgressWindow:(JDInstallProgressWindow*)progressWindow;
{
    [self.allGitOutput appendString:output];
    [self updateProgressWindowWithCurrentOutput:progressWindow];
}

- (void)updateProgressWindowWithCurrentOutput:(JDInstallProgressWindow*)progressWindow;
{
    NSMutableString *text = [NSMutableString stringWithString:self.previousProgressText];
    [text appendString:@"\n\n"];
    
    NSString *previousLine = nil;
    for (NSString *line in [self.allGitOutput componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]) {
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        static NSInteger refLength = 15;
        if (previousLine && previousLine.length > refLength && line.length > refLength &&
            [[previousLine substringToIndex:refLength] isEqualToString:[line substringToIndex:refLength]]) {
            [text replaceOccurrencesOfString:previousLine withString:line options:NSBackwardsSearch range:NSMakeRange(0, text.length)];
        } else {
            [text appendFormat:@"%@\n", line];
        }
        previousLine = line;
    }

    progressWindow.textView.string = text;
    [progressWindow scrollToBottom];
}

@end



