//
//  NSButton+BBlock.m
//  BBlock
//
//  Created by David Keegan on 4/10/12.
//  Copyright (c) 2012 David Keegan. All rights reserved.
//

#import "NSButton+BBlock.h"
#import <objc/runtime.h>

static char BBlockNSButtonInKey;
static char BBlockNSButtonOutKey;
static char BBlockNSButtonTrackingKey;

@implementation NSButton(BBlock)

- (void)setInCallback:(BBNSButtonCallback)block{
    [self setupTrackingArea];
    objc_setAssociatedObject(self, &BBlockNSButtonInKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setOutCallback:(BBNSButtonCallback)block{
    [self setupTrackingArea];
    objc_setAssociatedObject(self, &BBlockNSButtonOutKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setInCallback:(BBNSButtonCallback)inBlock andOutCallback:(BBNSButtonCallback)outBlock{
    [self setInCallback:inBlock];
    [self setOutCallback:outBlock];
}

- (void)setupTrackingArea{
    NSTrackingArea *trackingArea = objc_getAssociatedObject(self, &BBlockNSButtonTrackingKey);
    if(!trackingArea){
        NSTrackingArea *trackingArea =
        [[NSTrackingArea alloc] 
         initWithRect:self.visibleRect
         options:NSTrackingMouseEnteredAndExited|NSTrackingActiveAlways
         owner:self userInfo:nil];
        [self addTrackingArea:trackingArea];
        objc_setAssociatedObject(self, &BBlockNSButtonTrackingKey, trackingArea, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)mouseEntered:(NSEvent *)theEvent{
    BBNSButtonCallback callback = objc_getAssociatedObject(self, &BBlockNSButtonInKey);
    if(self.isEnabled && callback){
        callback(self);
    }
}

- (void)mouseExited:(NSEvent *)theEvent{
    BBNSButtonCallback callback = objc_getAssociatedObject(self, &BBlockNSButtonOutKey);
    if(callback){
        callback(self);
    }
}

@end
