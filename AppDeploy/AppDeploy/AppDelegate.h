#import <Cocoa/Cocoa.h>
#import "ABApplication.h"
#import "FTPManager.h"
#import "MainNSWindow.h"


@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate>

typedef enum notificationBuildType
{
	BUILD_TYPE_TEMPLATE,
	BUILD_TYPE_UPLOAD,
} BUILD_TYPE;


@property (strong) CDEvents* events;
@property (assign) IBOutlet MainNSWindow* window;
@property (strong) ABApplication* application;//current application

-(void) notificationForApp:(ABApplication*)application buildType:(BUILD_TYPE)buildType withbuildResult:(BOOL)success;
@end
