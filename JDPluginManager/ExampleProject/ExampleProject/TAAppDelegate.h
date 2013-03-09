//
//  TAAppDelegate.h
//  ExampleProject
//
//  Created by Markus Emrich on 04.02.13.
//  Copyright (c) 2013 nxtbgthng. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class JDPluginManager;

@interface TAAppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) JDPluginManager *manager;

@end
