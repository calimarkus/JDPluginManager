//
//  JDXcodeBuildTask.h
//  ExampleProject
//
//  Created by Markus Emrich on 09.03.13.
//  Copyright (c) 2013 nxtbgthng. All rights reserved.
//

#import "NSTaskWithProgress.h"

extern NSString *const xcodeBuildPath;


@class JDInstallProgressWindow;

@interface JDXcodeBuildTask : NSTaskWithProgress {
    NSMutableString* _allXcodeBuildOutput;
    NSString* _previousProgressText;
}

+ (instancetype)launchedTaskWithCurrentDirectoryPath:(NSString*)currentDirectory
                                      progressWindow:(JDInstallProgressWindow*)progressWindow
                                          completion:(void(^)())completion;

@end
