//
//  JDExtraPluginsDataLoader.h
//  JDPluginManager
//
//  Created by Danny Shmueli on 4/12/13.
//
//

#import <Foundation/Foundation.h>

@class JDExtraPluginsDataLoader;

@protocol JDExtraPluginsDataLoaderDelegate <NSObject>
- (void)extraPluginsDataLoaderDidFinish:(JDExtraPluginsDataLoader*)loader;
@end

@interface JDExtraPluginsDataLoader : NSObject

@property (nonatomic, assign) id<JDExtraPluginsDataLoaderDelegate> delegate;

-(void)getPluginsExtraDataFromGithub:(NSArray *)plugins;

@end
