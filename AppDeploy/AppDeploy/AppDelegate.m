#import "AppDelegate.h"
#import "MainNSWindow.h"
#import "FileManager.h"
#import "IOSManager.h"
#import "ConfigurationManager.h"
#import <Sparkle/Sparkle.h>
#import "ScriptManager.h"

#define kKeyArchivePath @"xcArchivePath"
#define kKeyNotificationType @"xcNotificationType"
#define kValueActionTypeBuildDetection @"KeyActionTypeBuildDetection"
#define kValueActionTypeBuildReleasedUpload @"KeyActionTypeBuildReleasedUpload"
#define kValueActionTypeBuildReleasedTemplate @"KeyActionTypeBuildReleasedTemplate"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	LoggerApp(1, @"Loading App Version %@ (%@)",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]);
	
    if (kCleanTempFolderAtStartup) [FileManager cleanTemporaryData];
    
	//Disable auto check when in debug mode
	#ifdef DEBUG
		LoggerApp(0,@"Warning - Version control check disabled");
		[[SUUpdater sharedUpdater]setAutomaticallyChecksForUpdates:NO];
	#endif
	
    //Script
    ScriptManager * scriptManager = [[ScriptManager alloc]init];
   [scriptManager commandLineSupport];
	
	if (!scriptManager.commandLineMode) {
		self.window.isVisible = YES;
		//init tracking
		[self trackArchiveFolderChange];
		if ([ConfigurationManager sharedManager].isAutoScanArchiveEnabled) {
			ABApplication * application = [IOSManager findLastArchive];
			self.application = application;
			[self.window displayInfoApplication:application];
		}
	}
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    //LoggerData(0,@"applicationShouldTerminate");

    [FileManager cleanTemporaryData];
    return  NSTerminateNow;
}


#pragma mark - Notification
-(void) notificationForApp:(ABApplication*)application buildType:(BUILD_TYPE)buildType withbuildResult:(BOOL)success {
	
	NSUserNotification *notification = [[NSUserNotification alloc] init];
	if (success) {
		notification.title = @"Deployment sucessfull";
	}
	else {
		notification.title = @"Deployment error";
	}
	notification.informativeText = [NSString stringWithFormat:@"Application \"%@\" just finished to deploy with version %@(%@).",
									application.name,
									application.versionFonctionnal,
									application.versionTechnical];
	notification.soundName = NSUserNotificationDefaultSoundName;
    [notification setValue:@YES forKey:@"_showsButtons"];
    
	if (buildType == BUILD_TYPE_TEMPLATE) {
		notification.userInfo = @{kKeyNotificationType:kValueActionTypeBuildReleasedTemplate};
		notification.actionButtonTitle = @"Preview";

	}
	else if (buildType == BUILD_TYPE_UPLOAD) {
		if (success) {
			notification.actionButtonTitle = @"Open url";
			notification.userInfo = @{kKeyNotificationType:kValueActionTypeBuildReleasedUpload};
		}
	}
	
	NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
	center.delegate = self;
	
	LoggerApp(2, @"Notification send with message %@-%@", notification.title, notification.informativeText);
	[center deliverNotification:notification];
}

-(void) notificationBuildDetection:(ABApplication *) application {
	NSUserNotification *notification = [[NSUserNotification alloc] init];
	notification.title = @"New build detected";
	notification.informativeText = [NSString stringWithFormat:@"Do you want to handle the build \"%@\" ?",application.name];
	notification.userInfo = @{kKeyArchivePath:application.xcarchive.path, kKeyNotificationType:kValueActionTypeBuildDetection};
    notification.soundName = NSUserNotificationDefaultSoundName;
    [notification setValue:@YES forKey:@"_showsButtons"];
	notification.hasActionButton = YES;
	notification.actionButtonTitle = @"Open";
    
	LoggerApp(1, @"Notification will be send with %@", notification.identifier);
    
    NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
    center.delegate = self;
	[center deliverNotification:notification];
}


- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
	
	LoggerApp(1, @"Notification detailed clicked");
	
	NSString * type = notification.userInfo[kKeyNotificationType];
	NSString * path = notification.userInfo[kKeyArchivePath];
	
	if ( [type isEqualToString:kValueActionTypeBuildReleasedUpload] )  {
		if (notification.activationType == NSUserNotificationActivationTypeActionButtonClicked) {
			if (!IsEmpty(self.application.urlToApp.absoluteString)) {
				[[NSWorkspace sharedWorkspace] openURL:self.application.urlToApp];
			}
		}
	}
	else if ( [type isEqualToString:kValueActionTypeBuildReleasedTemplate] )  {
		if (notification.activationType == NSUserNotificationActivationTypeActionButtonClicked) {
			//[[NSWorkspace sharedWorkspace] openURL:self.application.currentOutputPath];
            if (self.application.currentOutputPath!=nil) {
                [[NSWorkspace sharedWorkspace] openURL:[self.application.currentOutputPath URLByAppendingPathComponent:@"/index.html"]];
            }
        }
	}
	else if ( [type isEqualToString:kValueActionTypeBuildDetection] ) {
		NSURL * xcarchivePathURL = [NSURL fileURLWithPath:path];
		ABApplication * appDetected = [ABApplication applicationIOSWithFile:xcarchivePathURL];
		self.application = appDetected;
		[self.window displayInfoApplication:appDetected];
	}
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
	return YES;
}


#pragma mark - Automatic detection
- (void) trackArchiveFolderChange {
    NSArray * array = @[[NSURL URLWithString:[IOSManager archiveFolderPath]]];
    
    self.events = [[CDEvents alloc] initWithURLs:array  block:^(CDEvents *watcher, CDEvent *event) {
        if ([FileManager isXCarchive:event.URL]) {
            NSURL * xcarchivePathURL = event.URL;
            xcarchivePathURL = event.URL;
            
            LoggerFile(3, @"Archive detected : SELECTED \"%@\"\nFullPath=%@", [xcarchivePathURL lastPathComponent],xcarchivePathURL);
            //[self findLastModifiedArchive];
            //[self.window setRepresentedURL:xcarchivePathURL]; //TODO necessary ?
            
            ABApplication * appDetected = [ABApplication applicationIOSWithFile:xcarchivePathURL];
            //Notification
            [self notificationBuildDetection:appDetected];
        }
        
    }
                                       onRunLoop:[NSRunLoop currentRunLoop]
                            sinceEventIdentifier:kCDEventsSinceEventNow
                            notificationLantency:ARCHIVE_LATENCY
                         ignoreEventsFromSubDirs:CD_EVENTS_DEFAULT_IGNORE_EVENT_FROM_SUB_DIRS
                                     excludeURLs:nil
                             streamCreationFlags:kCDEventsDefaultEventStreamFlags];
    
}

#pragma mark - Drag&Drop

//used for drag and drop files + call when starting in command line too
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename {
	if (filename!=nil && ![filename isEqualToString:@"YES"]) {
		ABApplication * app = [MainNSWindow handleFileIfSupported:filename displayErrorMessageToWindow:self.window];
		self.application = app;
		return !IsEmpty(app);
		//TODO: handle case where the app is not launched and we should display a loader
	}
	return YES;//allow to test in xcode when providing the YES parameter
}

- (BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper ofType:(NSString *)typeName error:(NSError **)outError {
	
	if ([typeName isEqualToString:@""]) {
		return YES;
	}
	return NO;
	
}


@end
