#import <Foundation/Foundation.h>

@interface HipChatManager : NSObject

+ (BOOL) sendMessage:(NSString*)message withSuccess:(BOOL)success error:(NSError **)error;
+(BOOL)sendMessage:(NSString *)message
			 color:(NSString *)colorString
		 authToken:(NSString*)authToken
			roomID:(NSString*)roomID
			 error:(NSError **)error;
@end
