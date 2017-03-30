#import "BackgroundView.h"

@implementation BackgroundView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	
	if (self.backgroundColor) {
		[self.backgroundColor setFill];
		NSRectFill(dirtyRect);
	}
	
    [super drawRect:dirtyRect];
}

@end
