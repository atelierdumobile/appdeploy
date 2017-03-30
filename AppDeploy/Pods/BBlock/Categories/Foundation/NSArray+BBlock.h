//
//  NSArray+BBlock.h
//  BBlock
//
//  Created by David Keegan on 3/7/12.
//  Copyright 2012 David Keegan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray(BBlock)

/// Enumerate each object in the array.
- (void)enumerateEachObjectUsingBlock:(void(^)(id obj))block;

/// Apply the block to each object in the array and return an array of resulting objects
- (NSArray *)arrayWithObjectsMappedWithBlock:(id(^)(id obj))block;

@end
