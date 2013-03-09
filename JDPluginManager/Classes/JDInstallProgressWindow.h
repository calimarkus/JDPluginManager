//
//  JDInstallProgressWindow.h
//  ExampleProject
//
//  Created by Markus Emrich on 09.03.13.
//  Copyright (c) 2013 nxtbgthng. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JDInstallProgressWindow : NSWindow {
    NSTextView* _textView;
}

@property (nonatomic, readonly) NSTextView *textView;

- (id)initWithContentRect:(NSRect)contentRect;

- (void)appendLine:(NSString*)line;
- (void)appendTitle:(NSString*)title;

- (void)scrollToBottom;

@end
