//
//  NSObject+BBlock.h
//  BBlock
//
//  Created by David Keegan on 5/31/12.
//  Copyright 2012 David Keegan. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BBlockNSObjectKeyName(k) NSStringFromSelector(@selector(k))

@interface NSObject(BBlock)

typedef void (^NSObjectBBlock)(NSString *keyPath, id object, NSDictionary *change);
- (NSString *)addObserverForKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(NSObjectBBlock)block;
- (void)removeObserverForToken:(NSString *)identifier;
- (void)removeObserverBlocksForKeyPath:(NSString *)keyPath;

- (void)changeValueWithKey:(NSString *)key changeBlock:(void(^)())changeBlock;

@end
