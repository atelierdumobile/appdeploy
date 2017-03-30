#import <Cocoa/Cocoa.h>

@interface NSView (DisableSubViews)

- (void)disableSubViews;
- (void)enableSubViews;
- (void)setSubViewsEnabled:(BOOL)enabled;

@end
