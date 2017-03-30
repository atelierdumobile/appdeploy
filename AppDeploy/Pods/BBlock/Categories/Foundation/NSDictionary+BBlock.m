//
//  NSDictionary+BBlock.m
//  BBlock
//
//  Created by David Keegan on 3/7/12.
//  Copyright 2012 David Keegan. All rights reserved.
//

#import "NSDictionary+BBlock.h"

@implementation NSDictionary(BBlock)

- (void)enumerateEachKeyAndObjectUsingBlock:(void(^)(id key, id obj))block{
    NSParameterAssert(block != nil);
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        block(key, obj);
    }];
}

- (void)enumerateEachSortedKeyAndObjectUsingBlock:(void(^)(id key, id obj, NSUInteger idx))block{
    NSParameterAssert(block != nil);
    NSArray *keys = [[self allKeys] sortedArrayUsingSelector:@selector(compare:)];
    [keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj, [self objectForKey:obj], idx);
    }];
}

@end
