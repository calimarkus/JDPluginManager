//
//  TAAppDelegate.m
//  ExampleProject
//
//  Created by Markus Emrich on 04.02.13.
//  Copyright (c) 2013 nxtbgthng. All rights reserved.
//

#import "TAAppDelegate.h"

#import "JDPluginManager.h"
#import "JDPluginInstaller.h"

@implementation TAAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.manager = [[[JDPluginManager alloc] init] autorelease];
    
    // extend menu
    [self.manager extendXcodeMenu];
    
    // install a new plugin
    [JDPluginInstaller installPlugin];
}

@end
