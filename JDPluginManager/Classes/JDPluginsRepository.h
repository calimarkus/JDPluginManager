//
//  JDPluginsRepository.h
//  JDPluginManager
//
//  Created by Danny Shmueli on 4/6/13.
//
//

#import <Foundation/Foundation.h>
#import "JDExtraPluginsDataLoader.h"

@interface JDPluginsRepository : NSObject <JDExtraPluginsDataLoaderDelegate>
{
    NSMutableArray *_installedPlugins;
    NSMutableArray *_availablePlugins;
    JDExtraPluginsDataLoader *_extraPluginsDataLoader;
    id<JDExtraPluginsDataLoaderDelegate> _delegate;
}
@property (nonatomic, assign) id<JDExtraPluginsDataLoaderDelegate> delegate;
@property (nonatomic, retain) JDExtraPluginsDataLoader *extraPluginsDataLoader;
@property (nonatomic, retain) NSMutableArray *installedPlugins;
@property (nonatomic, retain) NSMutableArray *availablePlugins;

+(JDPluginsRepository *)sharedInstance;
-(void)removedUnInstalledPlugin:(NSInteger)index;
-(void)getPluginsExtraData;
@end
