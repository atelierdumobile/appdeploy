//
//  NSURL+BBlock.m
//  BBlock
//
//  Created by David Keegan on 4/22/12.
//  Copyright (c) 2012 David Keegan. All rights reserved.
//

#import "NSURL+BBlock.h"

@implementation NSURL(BBlock)

#if defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && __MAC_OS_X_VERSION_MIN_REQUIRED >= 1070
-(void)accessSecurityScopedResourceWithBlock:(void (^)())block{
    if([self respondsToSelector:@selector(startAccessingSecurityScopedResource)]){
        [self startAccessingSecurityScopedResource];
    }
    if(block)block();
    if([self respondsToSelector:@selector(stopAccessingSecurityScopedResource)]){
        [self stopAccessingSecurityScopedResource];
    }
}
#endif

@end
