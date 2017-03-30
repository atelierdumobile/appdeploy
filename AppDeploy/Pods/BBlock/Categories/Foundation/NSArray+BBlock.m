//
//  NSArray+BBlock.m
//  BBlock
//
//  Created by David Keegan on 3/7/12.
//  Copyright 2012 David Keegan. All rights reserved.
//

#import "NSArray+BBlock.h"

@implementation NSArray(BBlock)

- (void)enumerateEachObjectUsingBlock:(void(^)(id obj))block{
    NSParameterAssert(block != nil);
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        block(obj);
    }];
}

- (NSArray *)arrayWithObjectsMappedWithBlock:(id(^)(id obj))block{
    NSParameterAssert(block != nil);
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        [array addObject:block(obj)];
    }];
    return [NSArray arrayWithArray:array];
}

@end
