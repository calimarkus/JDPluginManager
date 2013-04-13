//
//  JDPluginsRepository.h
//  JDPluginManager
//
//  Created by Danny Shmueli on 4/6/13.
//
//

#import <Foundation/Foundation.h>
#import "JDExtraPluginsDataLoader.h"

@interface JDPluginsRepository : NSObject
{
    NSMutableArray *_installedPlugins;
    NSMutableArray *_availablePlugins;
    JDExtraPluginsDataLoader *_extraPluginsDataLoader;
}

@property (nonatomic, retain) JDExtraPluginsDataLoader *extraPluginsDataLoader;
@property (nonatomic, retain) NSMutableArray *installedPlugins;
@property (nonatomic, retain) NSMutableArray *availablePlugins;

+(JDPluginsRepository *)sharedInstance;
-(void)removedUnInstalledPlugin:(NSInteger)index;
-(void)getPluginsExtraDataWithDelegate:(id<JDExtraPluginsDataLoaderDelegate>)delegate;
@end
