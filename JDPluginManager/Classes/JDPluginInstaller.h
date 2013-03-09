//
//  JDPluginInstaller.h
//  JDPluginManager
//
//  Created by Markus Emrich on 04.02.13.
//
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class JDInstallProgressWindow;
@class NSTaskWithProgress;

@interface JDPluginInstaller : NSObject {
    NSTaskWithProgress* _activeTask;
    NSString* _repositoryURL;
    NSMutableArray* _pathsToBuild;
    JDInstallProgressWindow* _progressWindow;
}

+ (void)installPlugin;

- (void)beginInstallWithRepositoryUrl:(NSString*)repositoryURL
               searchInSubdirectories:(BOOL)searchSubdirectories;

@end
