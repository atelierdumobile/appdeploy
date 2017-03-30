//
//  NSImage+BBlock.h
//  BBlock
//
//  Created by David Keegan on 2/28/12.
//  Copyright (c) 2012 David Keegan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// Helper method for creating unique image identifiers
#define BBlockImageIdentifier(fmt, ...) [NSString stringWithFormat:(@"%@%@" fmt), \
    NSStringFromClass([self class]), NSStringFromSelector(_cmd), ##__VA_ARGS__]

@interface NSImage(BBlock)

/** Returns a `NSImage` rendered with the drawing code in the block.
This method does not cache the image object. */
+ (NSImage *)imageForSize:(NSSize)size withDrawingBlock:(void(^)())drawingBlock;

/** Returns a cached `NSImage` rendered with the drawing code in the block.
The `NSImage` is cached in an `NSCache` with the identifier provided. */
+ (NSImage *)imageWithIdentifier:(NSString *)identifier forSize:(NSSize)size andDrawingBlock:(void(^)())drawingBlock;

/** Return the cached image for the identifier, or nil if there is no cached image. */
+ (NSImage *)imageWithIdentifier:(NSString *)identifier;

/** Remove the cached image for the identifier. */
+ (void)removeImageWithIdentifier:(NSString *)identifier;

/** Remove all cached images. */
+ (void)removeAllImages;

@end
