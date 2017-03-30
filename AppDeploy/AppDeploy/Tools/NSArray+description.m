#import "NSArray+description.h"

@implementation NSArray (description)

- (NSString *) description {
    
    
    NSString * text = @"";
    for (id val in self) {
        if (!IsEmpty(text)) {
            text = [NSString stringWithFormat:@"%@,%@", text, val];
        }
        else text = val;
    }
    return text;
    

}

@end
