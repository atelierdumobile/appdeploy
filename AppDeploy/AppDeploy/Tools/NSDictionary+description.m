#import "NSDictionary+description.h"
#import "NSArray+description.h"

@implementation NSDictionary (description)

- (NSString *) description {
    NSString * text = @"";
    for (id key in self) {
        id val = [self objectForKey:key];
        NSString * valeur = val;
        if ([val isKindOfClass:NSArray.class]) {
            valeur = ((NSArray*)val).description;
        }
        else if ([val isKindOfClass:NSDictionary.class]) {
            valeur = ((NSDictionary*)val).description;
        }
        //LoggerData(0, @"key=%@ valeur=%@", key, valeur);
        if (IsEmpty(text)) {
            text = [NSString stringWithFormat:@"%@=%@", key, valeur];
        }
        else {
            text = [NSString stringWithFormat:@"%@\n%@=%@", text, key, valeur];
        }
    }
    return text;
}

@end
