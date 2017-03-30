//
//  NSApplication+BBlock.m
//  BBlock
//
//  Created by Jonathan Willing on 5/11/12.
//  Copyright 2012 Jonathan Willing. All rights reserved.
//

#import "NSApplication+BBlock.h"
#import <objc/runtime.h>

static char BBlockSheetKey;

@implementation NSApplication(BBlock)

- (void)beginSheet:(NSWindow*)sheet 
    modalForWindow:(NSWindow*)modalWindow 
 completionHandler:(void (^)(NSInteger returnCode))handler {
   
    [self beginSheet:sheet
      modalForWindow:modalWindow
       modalDelegate:self
      didEndSelector:@selector(_sheetDidEnd:returnCode:contextInfo:)
         contextInfo:NULL];
    objc_setAssociatedObject(self, &BBlockSheetKey, handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)_sheetDidEnd:(NSWindow*)sheet
          returnCode:(int)returnCode
         contextInfo:(void*)contextInfo {
    
    void (^handler)(NSInteger returnCode) = objc_getAssociatedObject(self, &BBlockSheetKey);
    [sheet orderOut:nil];
    handler(returnCode);
    objc_setAssociatedObject(self, &BBlockSheetKey, nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
