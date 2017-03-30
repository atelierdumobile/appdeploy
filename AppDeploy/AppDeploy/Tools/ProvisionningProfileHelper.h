#import <Foundation/Foundation.h>

@interface ProvisionningProfileHelper : NSObject

+ (NSDictionary *)provisioningProfileAtPath:(NSURL *)path;
+ (NSDictionary *)provisioningProfileFromContent:(NSString*)embeddedProfilePlistContent;

@end
