//
//  JDPluginsRepository.h
//  JDPluginManager
//
//  Created by Danny Shmueli on 4/6/13.
//
//

#import <Foundation/Foundation.h>

@interface JDPluginsRepository : NSObject
{
    NSMutableArray *_installedPlugins;
    NSArray *_availablePlugins;
}

@property (nonatomic, strong) NSMutableArray *installedPlugins;
@property (nonatomic, strong) NSArray *availablePlugins;

+(JDPluginsRepository *)sharedInstance;
-(void)removedUnInstalledPlugin:(NSInteger)index;
@end
