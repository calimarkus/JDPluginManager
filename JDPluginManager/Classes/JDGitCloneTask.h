//
//  JDGitCloneTask.h
//  ExampleProject
//
//  Created by Markus Emrich on 09.03.13.
//  Copyright (c) 2013 nxtbgthng. All rights reserved.
//

#import "NSTaskWithProgress.h"

extern NSString *const gitPath;
extern NSString *const tmpClonePath;

@class JDInstallProgressWindow;

@interface JDGitCloneTask : NSTaskWithProgress {
    NSMutableString* _allGitOutput;
    NSString* _previousProgressText;
}

+ (instancetype)launchedTaskWithRepositoryPath:(NSString*)repositoryPath
                               progressWindow:(JDInstallProgressWindow*)progressWindow
                                   completion:(void(^)(NSString *clonePath))completion;

@end
