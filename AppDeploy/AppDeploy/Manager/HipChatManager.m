#import "HipChatManager.h"
#import "Constants.h"

@implementation HipChatManager


//curl -H "Content-Type: application/json"      -X POST      -d "{\"color\": \"purple\", \"message_format\": \"text\", \"message\": \"$MESSAGE\" }"      https://api.hipchat.com/v2/room/$ROOM_ID/notification?auth_token=$AUTH_TOKEN

+(BOOL)sendMessage:(NSString *)message
			 color:(NSString *)colorString
			 authToken:(NSString*)authToken
			roomID:(NSString*)roomID
			 error:(NSError **)error {
    
    BOOL returnValue = NO;
	if (!message) return NO;
	if (!roomID) return NO;
	if (!authToken) return NO;
	
	NSMutableString *s = [NSMutableString new];
	[s appendFormat:@"{\"color\": \"%@\", \"message_format\": \"text\", \"message\": \"%@\" }",colorString, message];
	
	NSData *postData = [s dataUsingEncoding:NSUTF8StringEncoding];
	
	NSString * stringURL = [NSString stringWithFormat:@"https://api.hipchat.com/v2/room/%@/notification?auth_token=%@", roomID, authToken];
	NSMutableURLRequest *addRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:stringURL]];
	[addRequest setHTTPMethod:@"POST"];
	[addRequest setHTTPBody:postData];
	[addRequest setValue: @"application/json" forHTTPHeaderField: @"Content-Type"];
	
	
	NSURLResponse *response;
	NSData *data = [NSURLConnection sendSynchronousRequest:addRequest returningResponse:&response error:error];
	
	if (data != nil && *error == nil) {
		returnValue = YES;
	}
	else {
		LoggerNetwork(0, @"Result error %@", *error);
	}
	
	return returnValue;
}

+ (BOOL) sendMessage:(NSString*)message withSuccess:(BOOL)success error:(NSError **)error {
	NSString * hipchatApiKey = [Preference hipchatAuthToken];
	NSString * hipchatroom = [Preference hipchatRoomID];
	if (kHipChatEnabled && [Preference isHipchatEnabled] && hipchatApiKey != nil) {
		
		NSString * color = @"green";
		if (!success) {
			color = @"red";
		}
		
		[HipChatManager sendMessage:message color:color authToken:hipchatApiKey roomID:hipchatroom error:error];
		if (*error !=nil) {
			LoggerNetwork(0, @"HipChat error : %@", *error);
			return NO;
		}
		else {
			LoggerNetwork(1, @"HipChat success");
			return YES;
		}
	}
	else {
		LoggerError(0,@"Warning hipchat is not enabled");
		return NO;
	}
}


@end
