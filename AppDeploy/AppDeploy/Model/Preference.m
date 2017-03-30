#import "Preference.h"
#import "ConstantsSecured.h"
//#import <UICKeyChainStore/UICKeyChainStore.h>

#define PREF_NOTIFICATION_FAILURE @"notificationInCaseOfFailure"


//Notification
#define PREF_PROWL_API_KEY @"prowlApiKey"
#define PREF_PROWL_ENABLED @"prowlEnabled"
#define PREF_HIPCHAT_AUTHTOKEN_KEY @"hipchatAuthTokenKey"
#define PREF_HIPCHAT_ROOMID_KEY @"hipchatRoomID"
#define PREF_HIPCHAT_ENABLED @"hipchatEnabled"

//EXCEPTION
#define PREF_SERVER_PWD @"appdeploy.serverPassword"//exception for Keychain


@implementation Preference

static Preference *sharedSingleton;


#pragma mark Singleton

+ (Preference *)instance {
	@synchronized(self) {
		if (sharedSingleton == NULL)
			sharedSingleton = [[self alloc] init];
	}
	
	return(sharedSingleton);
}

#pragma mark - prowl
+ (NSString*) prowlApiKey {
	return PREF_STRING(PREF_PROWL_API_KEY);
}

+ (BOOL) isProwlEnabled {
	return PREF_BOOL(PREF_PROWL_ENABLED);
}


#pragma mark - hipchat
+ (NSString*) hipchatAuthToken {
	return PREF_STRING(PREF_HIPCHAT_AUTHTOKEN_KEY);
}

+ (NSString*) hipchatRoomID {
	return PREF_STRING(PREF_HIPCHAT_ROOMID_KEY);
}

+ (BOOL) isHipchatEnabled {
	return PREF_BOOL(PREF_HIPCHAT_ENABLED);
}

+ (BOOL) isEnabledNotificationInCaseOfFailure {
	return PREF_BOOL(PREF_NOTIFICATION_FAILURE);
}


#pragma mark - server
+ (NSString *) serverPwd {
   // return [UICKeyChainStore stringForKey:PREF_SERVER_PWD];
    return nil;
}

+ (void) savePwd:(NSString *)newPwd {
  //  [UICKeyChainStore setString:newPwd forKey:PREF_SERVER_PWD];
    
}


@end
