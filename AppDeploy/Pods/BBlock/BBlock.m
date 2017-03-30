//
//  BBlock.m
//  BBlock
//
//  Created by David Keegan on 4/10/12.
//  Copyright (c) 2012 David Keegan. All rights reserved.
//

#import "BBlock.h"

@implementation BBlock

+ (void)dispatchOnMainThread:(void (^)())block{
    NSParameterAssert(block != nil);
    dispatch_async(dispatch_get_main_queue(), block);
}

+ (void)dispatchAfter:(NSTimeInterval)delay onMainThread:(void (^)())block{
    NSParameterAssert(block != nil);
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay*NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}

+ (void)dispatchOnSynchronousQueue:(void (^)())block{
    NSParameterAssert(block != nil);
    static dispatch_queue_t queue;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        queue = dispatch_queue_create("bblock.queue.serial", DISPATCH_QUEUE_SERIAL);
    });
    if(queue){
        dispatch_async(queue, block);
    }
}

+ (void)dispatchOnSynchronousFileQueue:(void (^)())block{
    NSParameterAssert(block != nil);
    static dispatch_queue_t queue;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        queue = dispatch_queue_create("bblock.queue.serial.file", DISPATCH_QUEUE_SERIAL);
    });
    if(queue){
        dispatch_async(queue, block);
    }
}

+ (void)dispatchOnDefaultPriorityConcurrentQueue:(void (^)())block{
    [self dispatchOnConcurrentQueue:DISPATCH_QUEUE_PRIORITY_DEFAULT withBlock:block];
}

+ (void)dispatchOnLowPriorityConcurrentQueue:(void (^)())block{
    [self dispatchOnConcurrentQueue:DISPATCH_QUEUE_PRIORITY_LOW withBlock:block];
}

+ (void)dispatchOnHighPriorityConcurrentQueue:(void (^)())block{
    [self dispatchOnConcurrentQueue:DISPATCH_QUEUE_PRIORITY_HIGH withBlock:block];    
}

+ (void)dispatchOnConcurrentQueue:(long)queue withBlock:(void (^)())block{
    NSParameterAssert(block != nil);
    dispatch_async(dispatch_get_global_queue(queue, 0), block);
}

@end
