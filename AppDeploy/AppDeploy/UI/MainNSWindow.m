#import "MainNSWindow.h"
#import "AppDelegate.h"
#import "FileManager.h"
#import "NSView+DisableSubViews.h"
#import "IOSManager.h"
#import "ABApplication.h"
#import "NetworkSettingVC.h"
#import "IntegrationSettingVC.h"
#import "AndroidSettingVC.h"
#import "GeneralSettingVC.h"
#import "XcodeSettingVC.h"
#import "TemplateSettingVC.h"
#import "TerminalSettingVC.h"
#import "ConfigurationManager.h"
#import "ServerModel.h"
#import "PreferencesWindowController.h"
#import "TaskManager.h"
#import "TemplateGeneration.h"
#import "NSDictionary+description.h"
#import "NSArray+description.h"
#import "SoundHelper.h"

#define delegate ((AppDelegate *)[NSApplication sharedApplication].delegate)


@interface MainNSWindow()

typedef enum {
    DeployMode,
    SignAndTemplateMode,
} ActionMode;



//Views
@property (strong) IBOutlet NSView *infoAppView;
@property (strong) IBOutlet NSView *mainView;
@property (strong) IBOutlet NSView *dragView;
@property (strong) IBOutlet BackgroundView *fullscreenWaitingView;

//Home
@property (weak) IBOutlet NSImageView *dragImage;

//App detail
@property (weak) IBOutlet NSImageView *icone;
@property (weak) IBOutlet NSTextField *appName;
@property (weak) IBOutlet NSTextField *appBundleId;
@property (weak) IBOutlet NSTextField *signingIdentity;
@property (weak) IBOutlet NSTextField *provisionningTextField;
@property (weak) IBOutlet NSTextField *provisionningExpirationDate;
@property (weak) IBOutlet NSTextField *buildURLTextField;
@property (weak) IBOutlet NSProgressIndicator *wheelIndicatorPublish;
@property (weak) IBOutlet NSImageView *buildStatusImagePublish;
@property (weak) IBOutlet NSProgressIndicator *wheelIndicatorTemplate;
@property (weak) IBOutlet NSImageView *buildStatusImageTemplate;
@property (weak) IBOutlet NSButton *templateButton;
@property (weak) IBOutlet NSButton *openBuildButton;
@property (weak) IBOutlet NSButton *previewButton;
@property (weak) IBOutlet NSButton *signPublishButton;
@property (weak) IBOutlet NSProgressIndicator *uploadProgessIndicator;
@property (weak) IBOutlet NSTextField *sourceFileSize;
@property (weak) IBOutlet NSTextField *creationDate;
@property (weak) IBOutlet NSButton *provisioningButton;
@property (unsafe_unretained) IBOutlet NSTextView *commentTV;
@property (weak) IBOutlet NSScrollView *commentContainer;
@property (weak) IBOutlet NSView *commentView;
@property (weak) IBOutlet NSTextField *technicalDetail;
@property (weak) IBOutlet NSPopUpButton *templatePopupButton;
@property (weak) IBOutlet NSPopUpButtonCell *serverConfigPopupButton;
@property (weak) IBOutlet NSButton *cleanAfterBuildButton;
@property (weak) IBOutlet NSButton *appUrlPreviewButton;

//Menu
@property (weak) IBOutlet NSMenuItem *openOutputFolderItem;
@property (weak) IBOutlet NSMenuItem *displayInformationItem;
@property (weak) IBOutlet NSMenuItem *generateTemplateItem;
@property (weak) IBOutlet NSMenuItem *generateDeployItem;
@property (weak) IBOutlet NSMenuItem *goToWebpageItem;
@property (weak) IBOutlet NSMenuItem *appUrlCopyItem;
@property (weak) IBOutlet NSMenuItem *openCustomOutputFolderItem;
@property (weak) IBOutlet NSMenuItem *generateTemplateWithoutBinaryItem;
@property (weak) IBOutlet NSMenuItem *showMobileProvisoningItem;
@property (weak) IBOutlet NSMenuItem *showPlistItem;
@property (weak) IBOutlet NSMenuItem *showFileInFinder;

//Key
@property (nonatomic) BOOL altKeyDown;

//Tasks
@property (strong) TaskManager * buildTask;
@property (strong) FTPManager * ftpTask;

//Waiting view fullscreen
@property (weak) IBOutlet NSProgressIndicator *fullscreenWaitingIndicator;
@property (strong)  PreferencesWindowController *preferencesWindowController;


@end

@implementation MainNSWindow

#pragma mark - Menu


- (void) disableMenuItems {
	NSArray * items = @[self.openOutputFolderItem,
						self.displayInformationItem,
						self.generateTemplateItem,
						self.generateDeployItem,
						self.goToWebpageItem,
						self.appUrlCopyItem,
						self.generateTemplateWithoutBinaryItem,
						self.showMobileProvisoningItem,
						self.showPlistItem,
                        self.showFileInFinder];
	for (NSMenuItem * item in items) {
		//[item setTarget:nil];
		[item setAction:NULL];
	}
}

- (void) enableCopyAppUrlItem {
	[self.appUrlCopyItem setAction:@selector(copyURLIntoPasteboard:)];
}

- (void) disableItemOutputFolder {
	[self.openOutputFolderItem setAction:nil];
}

- (void) enableItemOutputFolder {
	[self.openOutputFolderItem setAction:@selector(openBuildFolder:)];
}

- (void) enableItemDisplayInformationItem {
	[self.displayInformationItem setAction:@selector(moreAboutApp:)];
}

- (void) enableItemGenerateSignItem {
	[self.generateDeployItem setAction:@selector(signAndPush:)];
}

- (void) enableItemGenerateDeployItem {
	[self.generateTemplateItem setAction:@selector(signAndTemplate:)];
}

- (void) enableItemGoToWebsiteItem {
	[self.goToWebpageItem setAction:@selector(openUrl:)];
}

- (void) enableItemOpenCustomOutputFolderItem {
	[self.openCustomOutputFolderItem setAction:@selector(openCustomOutputFolder:)];
}

- (void) disableItemOpenCustomOutputFolderItem {
	[self.openCustomOutputFolderItem setAction:nil];
}

- (void) enableItemGenerateTemplateWithoutBinaryItem {
	[self.generateTemplateWithoutBinaryItem setAction:@selector(generateTemplateWithoutBinary:)];
}

- (void) enableItemShowMobileProvisoningItem {
	[self.showMobileProvisoningItem setAction:@selector(showMobileprovision:)];
}

- (void) enableItemShowPlistItem {
	[self.showPlistItem setAction:@selector(showPlistFile:)];
}

- (void) enableItemShowFileInFinder {
    [self.showFileInFinder setAction:@selector(showFileInFinder:)];
}


- (IBAction)showPreferences:(id)sender {
	if (self.preferencesWindowController ==nil) {
				
		NetworkSettingVC *networkVC = [[NetworkSettingVC alloc] init];
        IntegrationSettingVC *prowlVC = [[IntegrationSettingVC alloc] init];
        TerminalSettingVC *terminalVC = [[TerminalSettingVC alloc] init];
		GeneralSettingVC *generalVC = [[GeneralSettingVC alloc] init];
        XcodeSettingVC *XcodeVC = [[XcodeSettingVC alloc] init];
        AndroidSettingVC *androidVC = [[AndroidSettingVC alloc] init];
		TemplateSettingVC *templateVC = [[TemplateSettingVC alloc] init];
		
		NSArray *controllers = @[generalVC, networkVC,templateVC, XcodeVC, androidVC, prowlVC, terminalVC];
		
		self.preferencesWindowController = [[PreferencesWindowController alloc]
											initWithViewControllers:controllers
											andTitle:NSLocalizedString(@"Preferences",
																	   @"Preferences")];
		self.preferencesWindowController.mainWindow = self;
	}
	[self.preferencesWindowController showWindow:self];
}


- (void)awakeFromNib {
	[[ConfigurationManager sharedManager ] loadConfiguration];
	
	[self.dragImage unregisterDraggedTypes];
	[self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
	
	[self disableMenuItems];
	[self displayDragView];
	[self defaultUI];
	[self initUploadProgressListener];
	[self updateMenuTitle];
}



#pragma mark - Application settings
- (void) setApplication:(ABApplication*)application {
	if (application != nil) {
		[self disableItemOutputFolder];
		
		[self enableItemDisplayInformationItem];
		[self enableItemGenerateSignItem];
		[self enableItemGenerateDeployItem];
		[self enableItemGenerateTemplateWithoutBinaryItem];
		[self enableItemGoToWebsiteItem];
		[self enableCopyAppUrlItem];
		[self enableItemShowMobileProvisoningItem];
		[self enableItemShowPlistItem];
        [self enableItemShowFileInFinder];
		
		[self populateTemplateWithApplication:application defaultConfig:nil];
        [self populateServerConfigPopupButtonWithDefaultConfig:nil];

		//define a default server configuration required to display the final path
		application.serverConfig = [self currentServerConfiguration];
		application.templateConfig = [self currentTemplateConfiguration];
		
		[self defaultUI];
		[self updatePublishTo:(ABApplication*)application];

		
		//COMMUN
		NSString * appVersion = [NSString stringWithFormat:@"%@ (%@)", application.versionFonctionnal, application.versionTechnical];
		if (!IsEmpty(appVersion)) {
			self.appName.stringValue = [NSString stringWithFormat:@"%@ - %@   ℹ️", application.name, appVersion];
		}
		else {
			self.appName.stringValue = application.name;
		}
		
		
		if (application.isIpa && !IsEmpty(application.iconeName)) {
			//need to decode from zip
			NSData * imageData = [IOSManager imageFromIPAFile:application.ipaURL withFileName:application.iconeName];
			self.icone.image = [[NSImage alloc] initWithData:imageData];
			application.appIcone = self.icone;
		}
		else if (application.isApk) {
			NSData * imageData = [AndroidManager imageDataFromAPK:application.xcarchive];
			self.icone.image = [[NSImage alloc] initWithData:imageData];
			application.appIcone = self.icone;
		}
		//NSLog(@"\n\n\n%@ ", application.icone);
		// /Users/gros/Library/Developer/Xcode/Archives/2013-11-22/NegatifPlusDev\ 22-11-2013\ 16.49.xcarchive/Products/Applications/NegDev.app/icon@2x.png
		else if (!IsEmpty(application.icone)) {
			self.icone.image = [[NSImage alloc] initWithContentsOfURL:application.icone];
		}
		else {
			//if (application.type == ApplicationTypeIOS) {
				self.icone.image = [NSImage imageNamed:@"IconePlaceholder.png"];
			//Do it with nice icone :p
			//}
			//else {
			//	self.icone.image = [NSImage imageNamed:@"app_android.png"];
			//}
		}

		[self updateFileSizeWithApplication:application];
		
		[self updateUIWithKeyPressedWithApplication:application];
	}
	else {
		//when saving setting and there is not , it is null and it is not a warning
		//LoggerApp(0, @"setApplication isNull");
	}
}

//TODO: to change according to the fmk retained
- (void) initUploadProgressListener {
	[[NSNotificationCenter defaultCenter] addObserverForName:kNotificationUploadProgress
													  object:nil
													   queue:[NSOperationQueue mainQueue]
												  usingBlock:^(NSNotification *notification) {
													  NSDictionary *userInfo = notification.userInfo;
													  
													  NSNumber * progression = [userInfo objectForKey:@"Progression"];
													  double progressionDouble = [progression doubleValue];
													  //LoggerView(4,@"Progress received! %.1f", progressionDouble);
													  [self.uploadProgessIndicator setDoubleValue:progressionDouble];
												  }];
}


- (void) setProvisionningProfile:(NSString *) provisionningName withPlaceHolder:(NSString*) provisionningDefault{
	if (!IsEmpty(provisionningName)) {
		self.provisionningTextField.stringValue = provisionningName;
	}
	else {
		[[self.provisionningTextField cell] setPlaceholderString:provisionningDefault];
	}
}




- (void) displayInfoApplication:(ABApplication*)application {
	if (application) {
		//display application
		[self defineFile:application.sourceFileURL];
		[self setApplication:application];
		[self displayApplicationView];
    }
	else {
		LoggerApp(0, @"displayInfoAppForArchive cannot be handled %@", application);
	}
}


#pragma mark  - Actions

- (IBAction)previewTemplateAction:(id)sender {
    ABApplication * application = delegate.application;
    if (application != nil) {
        NSURL * url = application.currentOutputPath;
        if (url != nil) {
            NSString * path = [NSString stringWithFormat:@"%@%@", url.path, @"/index.html"];
            BOOL openSuccess = [[NSWorkspace sharedWorkspace] openFile:path];
            if (!openSuccess) {
                LoggerError(0, @"Coulnd't open %@ for %@", path, application.normalizedName);
            }
        }
    }
}

- (IBAction)openPreferenceFolder:(id)sender {
	[[NSWorkspace sharedWorkspace] openFile:[ConfigurationManager configurationFolder].path];
}
- (IBAction)openCustomOutputFolder:(id)sender {
	if ([ConfigurationManager sharedManager].isCustomTemplateFolderEnabled) {
		[[NSWorkspace sharedWorkspace] openFile:[ConfigurationManager sharedManager].customTemplateFolder.path];
	}
}

- (IBAction)help:(id)sender {
	NSString * message = @""
	"App builder is taking care of iOS and Android application deployment, generating a friendly download page and upload it to your own server requiring just html support.\n\n"
	"• iOS : just drag an existing .ipa or .xcarchive. AppDeploy can automatically detect an archive (Xcode->Product->Archive) and display an OSX notification to handle the build. In both cases configure an entreprise certificate to avoid handling UDID.\n\n"
	"• Android : just drag an existing .apk file. Full support with android sdk configured, simple support otherwise with by respecting apk file naming {name}_{versionName}_{versionCode}.apk (ie weather_1.3_23.apk)."
	"";
	[self showMessage:message withTitle:@"About"];
}


- (BOOL) validateUrl: (NSString *) candidate {
    NSString *urlRegEx =
    @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:candidate];
}


- (IBAction)openUrl:(id)sender {
    NSURL * url = delegate.application.urlToApp;
	if (!IsEmpty(url)) {
		/*NSUInteger flags = [[NSApp currentEvent] modifierFlags];
		
		if ((flags & NSCommandKeyMask) && (flags & NSAlternateKeyMask) && (flags & NSControlKeyMask)) {
			[ABApplication notifyServicesForApplication:delegate.application
										 withIdentifier:nil
											buildResult:YES];
		}
		else {*/
        BOOL urlValid = [self validateUrl:url.absoluteString];
        if (urlValid) [[NSWorkspace sharedWorkspace] openURL:delegate.application.urlToApp];
		//}
	}
}

- (IBAction)openArchiveFolder:(id)sender {
	[[NSWorkspace sharedWorkspace] openFile:[IOSManager archiveFolderPath]];
}

- (IBAction)openTempFolder:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:[FileManager temporaryFolder]]];
}


- (IBAction)copyURLIntoPasteboard:(id)sender {
	if (!IsEmpty(delegate.application.urlToApp.absoluteString)) {
		
		[[NSPasteboard generalPasteboard] clearContents];
		[[NSPasteboard generalPasteboard] setString:delegate.application.urlToApp.absoluteString  forType:NSStringPboardType];
	}
}


- (IBAction)showPlistFile:(id)sender {
	
	ABApplication  * app = delegate.application;
	NSString * fileName = @"Info.plist";
	[self showFileInArchive:app withFileName:fileName];
}

- (IBAction)showMobileprovision:(id)sender {
	
	ABApplication  * app = delegate.application;
	NSString * fileName = @"embedded.mobileprovision";
	[self showFileInArchive:app withFileName:fileName];
}

- (IBAction)showFileInFinder:(id)sender {
    NSURL* url = delegate.application.sourceFileURL;
 	//[[NSWorkspace sharedWorkspace] openURL:url];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[url]];
}


- (void) showFileInArchive:(ABApplication*)app withFileName:(NSString*)fileName {
	NSURL * url;
	if (app !=nil) {
		if (!IsEmpty(app.archiveAppFolder)) {
			url = [app.archiveAppFolder URLByAppendingPathComponent:fileName];
		}
		/*
         else if (app.isIpa) {
            //TODO: performance keep a commun unzip file when analyzing file
			NSURL * zipextracted = [IOSManager ipaUnzip:app.ipaURL withBundle:app.bundleName];
			if (zipextracted) {
				url = [zipextracted URLByAppendingPathComponent:fileName];
			}
		}
         */
		
		if (url != nil) {
			[[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[url]];
		}
	}
}

- (IBAction)moreAboutApp:(id)sender {
	
	ABApplication * app = delegate.application;
	if (app != nil) {
		NSMutableString * message =  [NSMutableString string];
		
        if (app.type == ApplicationTypeIOS) {
            if (!IsEmpty(app.architecture)) {
                [message appendFormat:@"\nSupported architecture: %@", app.architecture.description];
            }
            if (!IsEmpty(app.platforms)) {
                [message appendFormat:@"\nPlateform: %@", app.platforms.description];
            }
			if (!IsEmpty(delegate.application.appStoreFileSize)) {
				[message appendFormat:@"\nAppStoreFileSize: %@mo", app.appStoreFileSize];
			}
			if (!IsEmpty(delegate.application.comment)) {
				[message appendFormat:@"\nComment: %@", app.comment.description];
			}
			if (!IsEmpty(app.entitlements)) {
				[message appendFormat:@"\nEntitlements :\n%@",app.entitlements.description];
			}
		}
        else if (app.type == ApplicationTypeAndroid) {
            if (!IsEmpty(app.architecture)) {
                [message appendFormat:@"\nSupported architecture: %@", app.architecture.description];
            }
            if (!IsEmpty(app.screens)) {
                [message appendFormat:@"\nSupport screens:%@",app.screens.description];
            }
            if (!IsEmpty(app.densities)) {
                [message appendFormat:@"\nDensities:%@",app.densities.description];
            }
            if (!IsEmpty(app.permissions)) {
                [message appendFormat:@"\n\nPermissions:\n%@",app.permissions.description];
            }
            if (!IsEmpty(app.locales)) {
                [message appendFormat:@"\n\nLocales:\n%@",app.locales];
            }
            if (!IsEmpty(app.entitlements)) {
                [message appendFormat:@"\nEntitlements :\n%@",app.entitlements.description];
            }
            
        }
		else {
			[message appendFormat:@"Nothing to say right now ;)."];
		}
		
		[self showMessage:message withTitle:@"More about App"];
	}
}

- (IBAction)closeWindow:(id)sender {
	if (![self isKeyWindow]) {
		//settings window
		[self.preferencesWindowController close];
	}
	else {
		//Main window
		[self cancel:nil];
	}
}

- (IBAction)cancel:(id)sender {
	[self.buildTask stopCurrentTask];
	[self.ftpTask stopTransfertAsync];
	
	[self disableMenuItems];
	[self setRepresentedURL:nil];
	[self setTitle:[[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleDisplayName"]];
	[self displayDragView];
}


- (IBAction)findLastArchive:(id)sender {
	[self showFullScreenWaiting];
	
	[BBlock dispatchOnHighPriorityConcurrentQueue:^{
		ABApplication * application = [IOSManager findLastArchive];
		delegate.application = application;
		[BBlock dispatchOnMainThread:^{
			[self displayInfoApplication:application];
			[self setApplication:application];
			[self hideFullScreenWaiting];
		}];
	}];
}


- (IBAction)generateTemplateWithoutBinary:(id)sender {
	ABApplication * app = delegate.application;
	if (app != nil&& app.templateConfig !=nil) {
		NSURL * url =  [TemplateGeneration previewTemplateWithTemplate:app.templateConfig application:app versioned:YES];
		if (url != nil) {
			LoggerData(1,@"URL to preview=%@",url);
			[[NSWorkspace sharedWorkspace] openFile:url.path];
		}
	}
}


- (IBAction)signAndTemplate:(id)sender {
	
	ABApplication * app = delegate.application;
	//Control configuration before starting
	BOOL isValid = [self checkTemplateWithApplication:app];
	if (!isValid) return;
	
	[self startLoadingWithMode:SignAndTemplateMode];
	
	if (self.buildTask !=nil) {
		[self.buildTask stopCurrentTask];
	}
	self.buildTask = [[TaskManager alloc]init];
	
	__weak TaskManager * taskWeak = self.buildTask;
	
	[BBlock dispatchOnHighPriorityConcurrentQueue:^{
		TaskManager * task = taskWeak;
		NSURL * url = [app handleBuildWithTask:&task];
		
		[BBlock dispatchOnMainThread:^{
			if (!IsEmpty(url)) {
				
				[ABApplication moveTemplateToOutputForApp:app withFolderDestination:app.buildFolderPath];
				
				if ([ConfigurationManager sharedManager].isAutomaticOpenBuildFolderEnabled) {
					[self openBuildFolder:nil];
				}
				[self openFolderButtonWithStatus:YES];
                self.previewButton.enabled = YES;
				
				if (app.isXcarchive) {
					[self updateFileSizeWithApplication:app];
				}
				//we keep the url display generaly we like to put it in an email
				[delegate notificationForApp:app buildType:BUILD_TYPE_TEMPLATE withbuildResult:YES];
			}
			else {
				[self openFolderButtonWithStatus:NO];
                self.previewButton.enabled = NO;
				[delegate notificationForApp:app buildType:BUILD_TYPE_TEMPLATE withbuildResult:NO];
			}
            [self endLoadingWithMode:SignAndTemplateMode];

			[self displayBuildWithSuccess:!IsEmpty(url) forMode:SignAndTemplateMode];
			[SoundHelper bip];
		}];
	}];
}


- (void) updateFileSizeWithApplication:(ABApplication*)app {
	[app computeFileSize];
	NSString * file = [NSString stringWithFormat:@"Archive: %@",app.sourceFileSize];
	
	if ( !IsEmpty(app.destFileSize) ) {
		file = [NSString stringWithFormat:@"%@ - Template folder: %@", file, app.destFileSize];
	}
	
	self.sourceFileSize.stringValue = file;
}


- (IBAction)signAndPush:(id)sender {
	ABApplication * app = delegate.application;
	
	//Control configuration before starting
	BOOL isValid = [self checkNetworkConfigurationWithApplication:app];
	if (!isValid) return;
	
	//Start processing
    [self startLoadingWithMode:DeployMode];
	
	if (self.buildTask !=nil) {
		[self.buildTask stopCurrentTask];
	}
	self.buildTask = [[TaskManager alloc]init];
	
	__weak TaskManager * taskWeak = self.buildTask;
	
	[BBlock dispatchOnHighPriorityConcurrentQueue:^{
		
		
		//SIGN or template
		NSURL * buildFolder = nil;
		if (self.altKeyDown) {//skip build
			buildFolder = app.buildFolderPath;
		}
		else {
			TaskManager * task = taskWeak;
			buildFolder = [app handleBuildWithTask:&task];
		}
		
		if (app.isXcarchive) {
			[self updateFileSizeWithApplication:app];
		}
		
		//respective actions
		//OpenFolderButton enable
		if (!IsEmpty(buildFolder) ) {
			if ([ConfigurationManager sharedManager].isAutomaticOpenBuildFolderEnabled) {
				[self openBuildFolder:nil];
			}
			
			[self openFolderButtonWithStatus:YES];
            self.previewButton.enabled = YES;
		}
		else {
			[self openFolderButtonWithStatus:NO];
            self.previewButton.enabled = YES;
		}
		
		app.serverConfig = [self currentServerConfiguration];
		if (delegate.application.serverConfig == nil) {
			LoggerError(0, @"Server configuration not defined");
			return;
		}
		
		//Publication
		NSString * errorString = nil;
		//if (self.ftpTask != nil) {
		//	[self.ftpTask stopTransfertAsync];
		//}
		self.ftpTask = [[FTPManager alloc]init];
		NSURL * urlToApp = [ABApplication pushApplication:app withBuildFolder:buildFolder errorString:&errorString FTPManager:self.ftpTask];
		
		[ABApplication notifyServicesForApplication:app
									 withIdentifier:nil
										buildResult:!IsEmpty(urlToApp)];
		
		//UI Update and actions
		[BBlock dispatchOnMainThread:^{
			if (!IsEmpty(urlToApp)) {
				[ABApplication moveTemplateToOutputForApp:delegate.application withFolderDestination:app.buildFolderPath];

				[delegate notificationForApp:app buildType:BUILD_TYPE_UPLOAD withbuildResult:YES];
				
				//we clean if clean setting on & if user didn't customied output path
				if ([ConfigurationManager sharedManager].isCleanAfterBuildEnabled&&IsEmpty(app.outputPath)) {
					NSError * error = nil;
					BOOL success = [FileManager removeFile:app.buildFolderPath withError:&error];
					if (!success) {
						LoggerFile(0, @"Can't clean build folder. Path=%@ Error=%@",app.buildFolderPath, error);
					}
				}
                [SoundHelper bip];
			}
			else {
				[self showMessage:[NSString stringWithFormat:@"Upload error with message : %@", errorString] withTitle:@"Upload error"];
				[delegate notificationForApp:app buildType:BUILD_TYPE_UPLOAD withbuildResult:NO];
                
                 [SoundHelper bipError];
			}
			
            [self endLoadingWithMode:DeployMode];
            [self displayBuildWithSuccess:!IsEmpty(urlToApp) forMode:DeployMode];

		}];
		LoggerApp(1, @"signAndPush result URL=%@", urlToApp);
		
	}];
}

- (IBAction)openBuildFolder:(id)sender {
	
	ABApplication * application = delegate.application;
	if (application != nil) {
		NSURL * url = application.currentOutputPath;
		NSString * path = url.path;
		BOOL openSuccess = [[NSWorkspace sharedWorkspace] openFile:path];
		if (!openSuccess) {
			LoggerError(0, @"Coulnd't open %@ for %@", path, application.normalizedName);
		}
	}
}

- (IBAction)clickDeleteBuildButton:(id)sender {
	if ([((NSButton*)sender) state] == NSOnState) {
		[ConfigurationManager sharedManager].isCleanAfterBuildEnabled = YES;
	}
	else {
		[ConfigurationManager sharedManager].isCleanAfterBuildEnabled = NO;
	}
	[[ConfigurationManager sharedManager]saveConfiguration];
}

- (IBAction)serverConfigurationChange:(id)sender {
	ABApplication * app = delegate.application;
	if (app != nil) {
		app.serverConfig = [self currentServerConfiguration];
	}
	[self updatePublishTo:app];
}

- (IBAction)templateConfigurationChange:(id)sender {
	delegate.application.templateConfig = [self currentTemplateConfiguration];
}

#pragma mark - UI indicator full screen
- (void) showFullScreenWaiting {
	[BBlock dispatchOnMainThread:^{
		[self.fullscreenWaitingIndicator startAnimation:nil];
		self.fullscreenWaitingIndicator.alphaValue = 1;
		self.fullscreenWaitingView.alphaValue = 1;
		self.fullscreenWaitingView.backgroundColor = [NSColor blackColor];
		self.fullscreenWaitingView.alphaValue = 0.6;
		[self.fullscreenWaitingView disableSubViews];
		[self.mainView addSubview:self.fullscreenWaitingView];
	}];
}

- (void) hideFullScreenWaiting {
	[BBlock dispatchOnMainThread:^{
		//animation not working
		[CATransaction begin];
		[CATransaction setAnimationDuration:1];
		//do some things to your layers
		self.fullscreenWaitingView.alphaValue = 0;
		self.fullscreenWaitingIndicator.alphaValue = 0;
		[CATransaction setCompletionBlock:^{
			[self.fullscreenWaitingView removeFromSuperview];
			[self.fullscreenWaitingIndicator stopAnimation:nil];
			
		}];
		[CATransaction commit];
	}];
}

#pragma mark - UI indicator App Detail
- (void) defaultUI {
	self.templateButton.enabled = YES;
	self.signPublishButton.enabled = YES;
    self.buildStatusImagePublish.alphaValue = 0.0;
    self.buildStatusImageTemplate.alphaValue = 0.0;
    self.wheelIndicatorPublish.alphaValue = 0.0;
    self.wheelIndicatorPublish.hidden = YES;
    self.wheelIndicatorTemplate.alphaValue = 0.0;
    self.wheelIndicatorTemplate.hidden = YES;
    self.uploadProgessIndicator.alphaValue = 0.0;
    self.uploadProgessIndicator.hidden = YES;
    
	self.openBuildButton.enabled = NO;
    self.previewButton.enabled = NO;
	[self.uploadProgessIndicator setDoubleValue:0.0];
	self.provisioningButton.hidden = YES;
	self.technicalDetail.hidden = YES;
	self.cleanAfterBuildButton.state = [ConfigurationManager sharedManager].isCleanAfterBuildEnabled;
}


- (void) updateMenuTitle {
	if(self.altKeyDown) {
		self.generateDeployItem.title = @"(Re-)Publish";
		[self.generateDeployItem setKeyEquivalentModifierMask:NSAlternateKeyMask|NSCommandKeyMask];
	}
	else {
		[self.generateDeployItem setKeyEquivalentModifierMask:NSCommandKeyMask];
		self.generateDeployItem.title = @"Generate & Publish";
	}
	
	if ([ConfigurationManager sharedManager].isCustomTemplateFolderEnabled) {
		[self enableItemOpenCustomOutputFolderItem];
	}
	else {
		[self disableItemOpenCustomOutputFolderItem];
	}
}

- (void) updateUIWithKeyPressedWithApplication:(ABApplication*)application {
	
	if (application == nil) return;
    self.provisionningTextField.stringValue = @"";
    self.provisionningExpirationDate.stringValue = @"";
    self.signingIdentity.stringValue = @"";
    self.provisioningButton.hidden = YES;
    self.appBundleId.hidden = YES;

    //COMMUN
    if (!IsEmpty(application.bundleIdentifier)) {
        self.appBundleId.stringValue = application.bundleIdentifier;
        self.appBundleId.hidden = NO;
    }

    
	//IOS
	if (application.type == ApplicationTypeIOS) {
		self.provisionningTextField.hidden = NO;
        self.provisionningExpirationDate.hidden = NO;
		self.signingIdentity.hidden = NO;
		self.appBundleId.hidden = NO;
		
        if (!IsEmpty(application.sdk)) {
            self.technicalDetail.hidden = NO;
            self.technicalDetail.stringValue = [NSString stringWithFormat:@"SDK: %@ Minimum: %@",application.sdk, application.minimumOS];
        }
        
		if (!IsEmpty(application.signingIdentity)) {
			self.signingIdentity.stringValue = application.signingIdentity;
		}
		if (!IsEmpty(application.provisionningProfile)) {
			self.provisionningTextField.stringValue = application.provisionningProfile;
            self.provisioningButton.hidden = NO;
        }
        self.provisionningExpirationDate.hidden = NO;
        if (!IsEmpty(application.certificateExpiration)) {
            if ([application.certificateExpiration compare:[NSDate date]] == NSOrderedAscending) {
                self.provisionningExpirationDate.textColor= [NSColor redColor];
            }
            else {
                self.provisionningExpirationDate.textColor= [NSColor blackColor];
            }
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.timeStyle = NSDateFormatterNoStyle;
            dateFormatter.dateStyle = NSDateFormatterLongStyle;
            
            NSString * dateFormatted = [dateFormatter stringFromDate:application.certificateExpiration];
            dateFormatted = [NSString stringWithFormat:@"Expiration: %@", dateFormatted];

            self.provisionningExpirationDate.stringValue = dateFormatted;
        }
        self.templateButton.enabled = YES;
	}
    
    if (application.type == ApplicationTypeIOS && application.xcarchive) {
        self.technicalDetail.hidden = NO;
        self.technicalDetail.stringValue = [NSString stringWithFormat:@"SDK: %@ Minimum: %@",application.sdk, application.minimumOS];
        self.templateButton.title = @"Sign & Template";
        if (self.altKeyDown && [application templateRetransferable]) {
            self.signPublishButton.title = @"(Re-)Publish";
        }
        else {
            self.signPublishButton.title = @"Sign & Template & Publish";
        }
    }
    else {
        self.templateButton.title = @"Template";
        if (self.altKeyDown && [application templateRetransferable]) {
            self.signPublishButton.title = @"(Re-)Publish";
        }
        else {
            self.signPublishButton.title = @"Template & Publish";
        }
    }
    
	
	//Android
	if (application.type == ApplicationTypeAndroid) {
		//self.signingIdentity.stringValue = @"";
		//self.appBundleId.stringValue= @"";
		self.provisionningTextField.hidden = YES;
        self.provisionningExpirationDate.hidden = YES;
		self.signingIdentity.hidden = YES;
        
        if (!IsEmpty(application.sdk)) {
            self.technicalDetail.hidden = NO;
            self.technicalDetail.stringValue = [NSString stringWithFormat:@"SDK: %@ TargetSdkVersion: %@",application.sdk, application.minimumOS];
        }
        
	}
	
	if (application.creationDate != nil) {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateStyle:NSDateFormatterMediumStyle];
		[formatter setTimeStyle:NSDateFormatterMediumStyle];
		
		self.creationDate.stringValue = [formatter stringFromDate:application.creationDate];
		self.creationDate.hidden = NO;
	}
	else {
		self.creationDate.hidden = YES;
	}
}

- (void) openFolderButtonWithStatus:(BOOL)enable {
	self.openBuildButton.enabled = enable;
	if (enable)	[self enableItemOutputFolder];
	else {
		[self disableItemOutputFolder];
	}
}

- (void) displayBuildWithSuccess:(BOOL)success forMode:(ActionMode)aMode {
   
    NSImageView * buildStatusImage = self.buildStatusImageTemplate;
    NSProgressIndicator * wheelIndicator = self.wheelIndicatorTemplate;
   
    if (aMode == DeployMode) {
        buildStatusImage = self.buildStatusImagePublish;
        wheelIndicator = self.wheelIndicatorPublish;
    }
    
	if( success) {
		buildStatusImage.image = [NSImage imageNamed:@"CheckmarkGreen.png"];
	}
	else {
		buildStatusImage.image = [NSImage imageNamed:@"Error.png"];
	}
	buildStatusImage.alphaValue = 0.0;
	[CATransaction begin];
	[CATransaction setAnimationDuration:1.0];
	//do some things to your layers
	buildStatusImage.alphaValue = 1.0;
	[CATransaction commit];
}

- (void) startLoadingWithMode:(ActionMode)aMode {
    
    NSImageView * buildStatusImage = self.buildStatusImageTemplate;
    NSProgressIndicator * wheelIndicator = self.wheelIndicatorTemplate;
    
    if (aMode == DeployMode) {
        buildStatusImage = self.buildStatusImagePublish;
        wheelIndicator = self.wheelIndicatorPublish;
    }
    
	wheelIndicator.alphaValue = 0.0;
	self.uploadProgessIndicator.alphaValue = 0.0;
	buildStatusImage.alphaValue = 0.0;
	[self.uploadProgessIndicator setDoubleValue:0.0];
	
	[CATransaction begin];
	[CATransaction setAnimationDuration:1.0];
	[CATransaction setCompletionBlock:^{
		wheelIndicator.hidden = NO;
		self.uploadProgessIndicator.hidden = NO;
	}];
	//do some things to your layers
	wheelIndicator.alphaValue = 1.0;
	self.uploadProgessIndicator.alphaValue = 1.0;
	[CATransaction commit];
	
	[wheelIndicator startAnimation:nil];
	[self.uploadProgessIndicator startAnimation:nil];
	
	self.templateButton.enabled = NO;
	self.signPublishButton.enabled = NO;
}

- (void) endLoadingWithMode:(ActionMode)aMode {
    NSImageView * buildStatusImage = self.buildStatusImageTemplate;
    NSProgressIndicator * wheelIndicator = self.wheelIndicatorTemplate;
    
    if (aMode == DeployMode) {
        buildStatusImage = self.buildStatusImagePublish;
        wheelIndicator = self.wheelIndicatorPublish;
    }
    
	wheelIndicator.alphaValue = 1.0;
	self.uploadProgessIndicator.alphaValue = 1.0;
	[wheelIndicator stopAnimation:nil];
	[self.uploadProgessIndicator stopAnimation:nil];
	
	[CATransaction begin];
	[CATransaction setAnimationDuration:0.5];
	//do some things to your layers
	wheelIndicator.alphaValue = 0.0;
	self.uploadProgessIndicator.alphaValue = 0.0;
	[CATransaction setCompletionBlock:^{
		wheelIndicator.hidden = YES;
		self.uploadProgessIndicator.hidden = YES;
	}];
	[CATransaction commit];
	
	self.templateButton.enabled = YES;
	self.signPublishButton.enabled = YES;
	
}

- (void) displayApplicationView {
	[self.dragView removeFromSuperview];
	[self.infoAppView removeFromSuperview];//protection
	[self.mainView addSubview:self.infoAppView];
}

- (void) displayDragView {
	[self.infoAppView removeFromSuperview];
	[self.mainView addSubview:self.dragView];
}

- (void) updatePublishTo:(ABApplication*)application {
	BOOL enabledPublish = NO;
     self.buildURLTextField.stringValue = @"";
	if (application != nil) {
        if (application.serverConfig != nil && application.serverConfig.type != ServerModelLocal) {
            NSURL * url = [application urlToApp];
            
            if (!IsEmpty(url) && !IsEmpty([url  absoluteString])) {
                self.buildURLTextField.stringValue = [url  absoluteString];
            }
            enabledPublish = application.serverConfig.isValid;
        }
	}
	
	//self.templateButton.enabled = enabledPublish;
	self.signPublishButton.enabled = enabledPublish;
    self.buildURLTextField.enabled = enabledPublish;
    self.appUrlPreviewButton.hidden = !enabledPublish;
}

#pragma mark - UI

//@return false if error
- (BOOL) checkNetworkConfigurationWithApplication:(ABApplication*)app {
    BOOL validServer = [app validateServerConfig];
    if (!validServer) {
        [self showMessage:@"Invalid server configuration. Please complete the setting." withTitle:@"Error"];
        return NO;
    }
    
    return YES;
}


//@return false if error
- (BOOL) checkTemplateWithApplication:(ABApplication*)app {

    BOOL validTemplate = [app validateTemplateConfig];
    if (!validTemplate) {
        [self showMessage:@"Invalid template configuration. Please complete the setting." withTitle:@"Configuration error"];
        
        return NO;
    }
    return YES;
}

- (void)refreshData {
    ServerModel * serverConfig = [self currentServerConfiguration];
    TemplateModel * templateConfig = [self currentTemplateConfiguration];
    
	[self populateServerConfigPopupButtonWithDefaultConfig:serverConfig];
	[self populateTemplateWithApplication:delegate.application defaultConfig:templateConfig];
	[self updateMenuTitle];
    [self updatePublishTo:delegate.application];
}

- (void) populateServerConfigPopupButtonWithDefaultConfig:(ServerModel*)defaultServer {
	[[self.serverConfigPopupButton menu] removeAllItems];

    
    //Do we have a default template ?
    ServerModel * selectedModel = defaultServer;
    
	NSArray * serverConfig = [ConfigurationManager sharedManager].serverConfigModels;
    int index = 0;
	for (ServerModel * aServerConfig in serverConfig) {
		[self.serverConfigPopupButton addItemWithTitle:aServerConfig.label];
        if (selectedModel != nil && [aServerConfig.label isEqualToString:selectedModel.label]) {
            [self.serverConfigPopupButton selectItemAtIndex:index];
        }
        index++;
	}
}

- (void) populateTemplateWithApplication:(ABApplication*)application defaultConfig:(TemplateModel*)defaultTemplate {
	//Populate liste
	[[self.templatePopupButton menu] removeAllItems];
	
	
	//Do we have a default template ?
	TemplateModel * selectedTemplateModel = defaultTemplate;
	if (application != nil && defaultTemplate == nil) {
		selectedTemplateModel = [[ConfigurationManager sharedManager] templateForBundle:application.bundleIdentifier];
		
	}
	NSArray * templates = [ConfigurationManager sharedManager].templateModels;
	int index = 0;
	for (TemplateModel * template in templates) {
		if ([template isValid]) {
			LoggerData(1, @"Adding %@", template.label);
			[self.templatePopupButton addItemWithTitle:template.label];
			if (selectedTemplateModel != nil && [template.key isEqualToString:selectedTemplateModel.key]) {
				[self.templatePopupButton selectItemAtIndex:index];
			}
			index++;
		}
	}
}

- (ServerModel *) currentServerConfiguration {
	NSUInteger index = self.serverConfigPopupButton.indexOfSelectedItem;
	ServerModel * server = [[ConfigurationManager sharedManager] serverModelAtIndex:index];
	return server;
}

- (TemplateModel*) currentTemplateConfiguration {
	NSUInteger index = self.templatePopupButton.indexOfSelectedItem;
	TemplateModel * template = [[ConfigurationManager sharedManager] templateModelAtIndex:index];
	return template;
}


#pragma mark - Dragging cursor
- (NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender {
	return NSDragOperationCopy;
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender {
	return NSDragOperationCopy;
}

#pragma mark - Do the drag
- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
	NSPasteboard *pboard = [sender draggingPasteboard];
	NSArray *filenames = [pboard propertyListForType:NSFilenamesPboardType];
	
	if (filenames != nil && 1 == filenames.count) {
		LoggerFile(4, @"Dragged filenames = %@", filenames);
		ABApplication * app = [MainNSWindow handleFileIfSupported:filenames[0] displayErrorMessageToWindow:self];
		delegate.application = app;
		return !IsEmpty(app);
	}
	
	return NO;
}

+ (ABApplication *) handleFileIfSupported:(NSString*)path {
    return [MainNSWindow handleFileIfSupported:path displayErrorMessageToWindow:nil];
}

//@return No if not file handled, YES otherwise
+ (ABApplication *) handleFileIfSupported:(NSString*)path displayErrorMessageToWindow:(MainNSWindow*)window {
    NSURL * fileURL = [NSURL fileURLWithPath:path];
    
    //File not readable
    if (![FileManager isFileExistAtPath:fileURL]) {
        //This case happend in case of right issue or wrong path provided
        LoggerFile(0, @"File not found at path:%@",path);
        return nil;
    }
    //IOS FILE
    else if ([FileManager isXCarchive:fileURL] || [FileManager isIPA:fileURL]) {
        LoggerFile(2, @"File = %@", fileURL);
        ABApplication * application = [ABApplication applicationIOSWithFile:fileURL];
        
        if (!IsEmpty(application)) {
            if (window!=nil) {
                [window displayInfoApplication:application];
            }
            return application;
        }
        else {
            if (window!=nil) {
                NSString * iOSMessage = @"Invalide .xcarchive or .ipa file.";
                [window showMessage:iOSMessage withTitle:@"Invalide file"];
            }
            return nil;
        }
    }
    //ANDROID FILE
    else if ([FileManager isAndroidFile:fileURL]) {
        LoggerFile(2, @"APK = %@", fileURL);
        
        ABApplication * application = [ABApplication applicationWithApk:fileURL];
        
        if (application==nil) {
            if (window!=nil) {
                NSString * androidMessage = @"You apk is not valid with the convention name_versionName_versionCode.apk (ie weather_1.3_23.apk).";
                [window showMessage:androidMessage withTitle:@"Invalide apk"];
            }
            return nil;
        }
        else {
            if (window!=nil)  [window displayInfoApplication:application];
            return application;
        }
    }
    
    
    return nil;
}



- (void) defineFile:(NSURL*)fileURL {
	[self setRepresentedURL:fileURL];
	[self setTitle:fileURL.lastPathComponent];
	[[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:fileURL];
}

- (IBAction)disclosureTriangleClicked:(id)sender {
	
	NSWindow *window =[sender window];
	NSRect frameOriginal = [window frame];
	//CGFloat frameHeight = frameOriginal.size.height;
	//LoggerError(0, @"%f", frameHeight);
	int marge = self.commentView.frame.size.height;
	
	switch([sender state]) {
		case NSOnState:
			[window setFrame:NSMakeRect(frameOriginal.origin.x,frameOriginal.origin.y, frameOriginal.size.width, frameOriginal.size.height+marge) display:NO];
			//self.commentView.hidden = NO;
			[self.commentView setNeedsDisplay:YES];
			[self.commentView setNeedsDisplayInRect:window.frame];
			[self.commentContainer setNeedsDisplayInRect:window.frame];
			[self.mainView setNeedsDisplay:YES];
			
			break;
		case NSOffState:
			[window setFrame:NSMakeRect(frameOriginal.origin.x,frameOriginal.origin.y, frameOriginal.size.width, frameOriginal.size.height-marge) display:YES];
			//self.commentView.hidden = YES;
			[self.commentView setNeedsDisplay:YES];
			[self.mainView setNeedsDisplay:YES];
			
			break;
		default:
			break;
	}
}

#pragma mark - Events

- (void)flagsChanged:(NSEvent *)theEvent {
	
	[super flagsChanged:theEvent];
	
	NSUInteger f = [theEvent modifierFlags];
	BOOL isDown = !!(f & NSAlternateKeyMask);
	if (isDown != self.altKeyDown) {
		//LoggerData(1, @"State changed. Cmd Key is: %@", isDown ? @"Down" : @"Up");
		self.altKeyDown = isDown;
		
		[self updateUIWithKeyPressedWithApplication:delegate.application];
		[self updateMenuTitle];
	}
}



@end
