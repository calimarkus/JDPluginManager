//
//  TAAppDelegate.m
//  ListInstalledPluginsTest
//
//  Created by Markus Emrich on 04.02.13.
//  Copyright (c) 2013 nxtbgthng. All rights reserved.
//

#import "TAAppDelegate.h"

#import "JDListInstalledPlugins.h"

@implementation TAAppDelegate

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // extend menu
    [[[JDListInstalledPlugins alloc] init] extendXcodeMenu];
}

@end
