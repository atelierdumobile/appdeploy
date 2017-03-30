#import <Foundation/Foundation.h>

@interface ProwlManager : NSObject

+ (BOOL) sendMessage:(NSString*)message withBuildURL:(NSString*)buildURL error:(NSError **)error ;

@end
