//
//  JDPluginInstaller.h
//  JDPluginManager
//
//  Created by Markus Emrich on 04.02.13.
//
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface JDPluginInstaller : NSObject

+ (void)installPlugin;

- (void)beginInstallWithRepositoryUrl:(NSString*)repositoryURL
               searchInSubdirectories:(BOOL)searchSubdirectories;

@end
