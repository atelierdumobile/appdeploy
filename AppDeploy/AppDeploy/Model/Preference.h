#import <Foundation/Foundation.h>
#import "TemplateModel.h"


@interface Preference : NSObject


#define PREF_STRING(key) [[NSUserDefaults standardUserDefaults]  stringForKey:key]
#define PREF_BOOL(key) [[NSUserDefaults standardUserDefaults]  boolForKey:key]




+ (Preference *)instance;


//Integration
+ (BOOL) isEnabledNotificationInCaseOfFailure;
+ (NSString*) prowlApiKey;
+ (BOOL) isProwlEnabled;
+ (NSString*) hipchatAuthToken;
+ (BOOL) isHipchatEnabled;
+ (NSString*) hipchatRoomID;

	
@end
