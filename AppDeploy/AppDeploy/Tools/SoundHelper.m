#import "SoundHelper.h"

@implementation SoundHelper

+ (void) bip {
    [[NSSound soundNamed:@"Glass"] play];
}
+ (void) bipError {
    [[NSSound soundNamed:@"Basso"] play];
}

@end
