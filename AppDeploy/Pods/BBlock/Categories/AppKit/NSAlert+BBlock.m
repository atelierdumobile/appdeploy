//
//  NSAlert+Blocks.m
//  Cloud Backup Agent
//
//  Created by Andreas Zöllner on 07.08.15.
//  Copyright (c) 2015 Studio Istanbul Medya Hiz. Tic. Ltd. Sti. All rights reserved.
//

#import "NSAlert+BBlock.h"
#import <objc/objc-runtime.h>

static char BBlockSheetKey;

@implementation NSAlert (BBlock)
-(void)beginSheetModalForWindow:(NSWindow *)window completionHandler:(void (^)(NSInteger))handler contextInfo:(void *)contextInfo {
    [self beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(_alertDidEnd:returnCode:contextInfo:) contextInfo:contextInfo];
    objc_setAssociatedObject(self, &BBlockSheetKey, handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)_alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    void (^handler)(NSInteger returnCode) = objc_getAssociatedObject(self, &BBlockSheetKey);
    [alert.window orderOut:nil];
    handler(returnCode);
    objc_setAssociatedObject(self, &BBlockSheetKey, nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
@end
