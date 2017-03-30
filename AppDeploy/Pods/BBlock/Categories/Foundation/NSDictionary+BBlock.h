//
//  NSDictionary+BBlock.h
//  BBlock
//
//  Created by David Keegan on 3/7/12.
//  Copyright 2012 David Keegan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary(BBlock)

/// Enumerate each key and object in the dictioanry.
- (void)enumerateEachKeyAndObjectUsingBlock:(void(^)(id key, id obj))block;

- (void)enumerateEachSortedKeyAndObjectUsingBlock:(void(^)(id key, id obj, NSUInteger idx))block;

@end
