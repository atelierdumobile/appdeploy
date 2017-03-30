#import "ProwlManager.h"
#import "Constants.h"

@implementation ProwlManager


+(BOOL)sendMessage:(NSString *)message
    forApplication:(NSString *)application
             event:(NSString *)event
           withURL:(NSString *)url
            forKey:(NSString *)key
          priority:(NSInteger )priority
             error:(NSError **)error {
    
    BOOL returnValue = NO;
    // default to normal priority if none given
    if (!application) return NO;
    if (!event && !message) return NO;
    if (key ==nil) return NO;
    if (!priority) priority = 0;
    
	NSMutableString *s = [NSMutableString new];
	
	
	[s appendFormat:@"%@=%@&",@"application",[application stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
	if (event)       [s appendFormat:@"%@=%@&",@"event",[event stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];  ;
	if (message)     [s appendFormat:@"%@=%@&",@"description",[message stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];  ;
	if (url)         [s appendFormat:@"%@=%@&",@"url",[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];  ;
	
	[s appendFormat:@"%@=%@&",@"apikey",[key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	[s appendFormat:@"%@=%@&",@"priority",[[[NSNumber numberWithInt:(int)priority] stringValue] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
	NSData *postData = [s dataUsingEncoding:NSUTF8StringEncoding];
	
	
	NSMutableURLRequest *addRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://api.prowlapp.com/publicapi/add"]];
	[addRequest setHTTPMethod:@"POST"];
	[addRequest setHTTPBody:postData];
	[addRequest setValue: @"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField: @"Content-Type"];
	
	
	NSURLResponse *response;
	NSData *data = [NSURLConnection sendSynchronousRequest:addRequest returningResponse:&response error:error];
	
	if (data != nil && *error == nil) {
		returnValue = YES;
	}
	else {
		LoggerError(1, @"Result error %@", *error);
	}
	
	return returnValue;
}


+ (BOOL) sendMessage:(NSString*)message withBuildURL:(NSString*)buildURL error:(NSError **)error {
	NSString * prowlApiKey = [Preference prowlApiKey];
	if (kEnableProwl&&[Preference isProwlEnabled] && prowlApiKey != nil) {
		
		NSString * appName = [[[NSBundle mainBundle] infoDictionary]  objectForKey:@"CFBundleDisplayName"];
		[ProwlManager sendMessage:appName forApplication:appName event:message withURL:buildURL forKey:prowlApiKey priority:2 error:error];
		if (*error !=nil) {
			LoggerError(0, @"Prowl error : %@", *error);
			return NO;
		}
		else {
			return YES;
		}
	}
	else {
		LoggerError(0,@"Warning Prowl is not enabled");
		return NO;
	}
	
}


@end
