#import "NSString+normalization.h"

@implementation NSString (normalization)

- (NSString *) normalizeString {
	NSString * textToNormalize = [self lowercaseString];
	
	// Defining what characters to accept
	NSMutableCharacterSet *acceptedCharacters = [[NSMutableCharacterSet alloc] init];
	[acceptedCharacters formUnionWithCharacterSet:[NSCharacterSet letterCharacterSet]];
	[acceptedCharacters formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
	[acceptedCharacters addCharactersInString:@"_-"];
	
	// Turn accented letters into normal letters (optional)
	NSData *sanitizedData = [textToNormalize dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	// Corrected back-conversion from NSData to NSString
	NSString *sanitizedText = [[NSString alloc] initWithData:sanitizedData encoding:NSASCIIStringEncoding];
	
	// Removing unaccepted characters
	NSString* output = [[sanitizedText componentsSeparatedByCharactersInSet:[acceptedCharacters invertedSet]] componentsJoinedByString:@""];
	return output;
}
@end
