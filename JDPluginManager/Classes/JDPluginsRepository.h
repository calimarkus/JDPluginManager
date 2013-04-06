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
}

@property (nonatomic, strong) NSMutableArray *installedPlugins;

+(JDPluginsRepository *)sharedInstance;

@end
