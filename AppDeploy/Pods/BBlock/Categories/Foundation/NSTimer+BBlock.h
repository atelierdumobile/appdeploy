//
//  NSTimer+BBlock.h
//  BBlock
//
//  Created by David Keegan on 3/12/12.
//  Copyright 2012 David Keegan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer(BBlock)

+ (instancetype)timerWithTimeInterval:(NSTimeInterval)timeInterval andBlock:(void (^)())block;
+ (instancetype)timerRepeats:(BOOL)repeats withTimeInterval:(NSTimeInterval)timeInterval andBlock:(void (^)())block;

+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval andBlock:(void (^)())block;
+ (instancetype)scheduledTimerRepeats:(BOOL)repeats withTimeInterval:(NSTimeInterval)timeInterval andBlock:(void (^)())block;

@end
