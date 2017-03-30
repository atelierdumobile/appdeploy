#import "NSView+DisableSubViews.h"

@implementation NSView (DisableSubViews)

- (void)disableSubViews {
    [self setSubViewsEnabled:NO];
}

- (void)enableSubViews {
    [self setSubViewsEnabled:YES];
}

- (void)setSubViewsEnabled:(BOOL)enabled {
    NSView* currentView = NULL;
    NSEnumerator* viewEnumerator = [[self subviews] objectEnumerator];
	
    while( currentView = [viewEnumerator nextObject] )
    {
        if( [currentView respondsToSelector:@selector(setEnabled:)] )
        {
            [(NSControl*)currentView setEnabled:enabled];
        }
        [currentView setSubViewsEnabled:enabled];
		
        [currentView display];
    }
}

@end
