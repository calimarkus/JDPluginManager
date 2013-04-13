//
//  JDExtraPluginsDataLoader.h
//  JDPluginManager
//
//  Created by Danny Shmueli on 4/12/13.
//
//

#import <Foundation/Foundation.h>
@protocol JDExtraPluginsDataLoaderDelegate <NSObject>
-(void)finishedLoadingExtraPluginsData;
@end

@interface JDExtraPluginsDataLoader : NSObject
{
    @private
    int toFinishCounter;
    id<JDExtraPluginsDataLoaderDelegate> _delegate;
}
@property (nonatomic, assign) id<JDExtraPluginsDataLoaderDelegate> delegate;

-(void)getPluginExtraDataFromGithub:(NSArray *)plugins;

@end
