//
//  NSApplication+BBlock.h
//  BBlock
//
//  Created by Jonathan Willing on 5/11/12.
//  Copyright 2012 Jonathan Willing. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSApplication(BBlock)

- (void)beginSheet:(NSWindow*)sheet 
    modalForWindow:(NSWindow*)modalWindow 
 completionHandler:(void (^)(NSInteger returnCode))handler;

@end
