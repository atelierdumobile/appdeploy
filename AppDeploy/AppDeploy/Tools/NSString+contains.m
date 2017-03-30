#import "NSString+contains.h"

@implementation NSString (contains)

- (BOOL) containsString: (NSString*) substring {
	NSRange range = [self rangeOfString : substring];
	BOOL found = ( range.location != NSNotFound );
	return found;
}

@end
