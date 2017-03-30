#import <Foundation/Foundation.h>
#import "FileManager.h"
#import "HipChatManager.h"
#import "ServerModel.h"
#import "TemplateModel.h"
#import "TaskManager.h"
#import "FTPManager.h"

@interface ABApplication : NSObject

typedef NS_ENUM(NSInteger,ApplicationType) {ApplicationTypeIOS, ApplicationTypeAndroid} ;

@property (nonatomic) ApplicationType type;

//App specific
@property (strong) NSString 	* name;//name coming from the plist, use the normalizedName in some case
@property (strong) NSString 	* versionFonctionnal;//iOS=CFBundleShortVersionString - Android=VersionName
@property (strong) NSString 	* versionTechnical;//iOS=CFBundleVersion Android=VersionCode
@property (strong) NSString 	* bundleIdentifier;//for android contains the package identifier
@property (strong) NSString 	* bundleName;//name of the app folder under the payload file in an ipa
@property (strong) NSURL 		* icone;
@property (strong) NSString 	* iconeName;
@property (strong) NSString 	* sdk;
@property (strong) NSString 	* minimumOS;
@property (strong) NSString 	* architecture;
@property (strong) NSDictionary	* platforms;//iPhoneOS or iPad
@property (strong) NSNumber 	* appStoreFileSize;
@property (strong) NSDate 		* creationDate;
@property (strong) NSString 	* sourceFileSize;
@property (strong) NSString 	* destFileSize;
@property (strong) NSDate 		* certificateExpiration;
@property (strong) NSString 	* signingIdentity;//the archive signing identity
@property (strong) NSString 	* provisionningProfile;//Provisionning from the embeded profile
@property (strong) NSDictionary	* entitlements;//iOS ie : com.apple.developer.icloud-services, com.apple.developer.ubiquity-container-identifiers, com.apple.developer.associated-domains, aps-environment…
@property (strong) NSString 	* locales;//android 'af' 'am' 'ar' 'be' 'bg' 'ca'


//Android
@property (strong) NSString 	* permissions;
@property (strong) NSString 	* screens;
@property (strong) NSString 	* densities;

//Integration continue informations
@property (strong) NSString 	* build_number;//build_number
@property (strong) NSDictionary * icVariablesDict;

//Associted template & server
@property (strong) ServerModel	* serverConfig;
@property (strong) TemplateModel* templateConfig;

//archive specific info
@property (strong) NSString 	* scheme;
@property (strong) NSString 	* comment;//the archive comment

//Custom value overridable the default appname
@property (strong) NSString 	* serverFolder;

//App context variables


//For xcarchive mode
@property (strong) NSURL 		* xcarchive;//apk url is also store in this… need to be cleaned
@property (strong) NSURL 		* archiveAppFolder;//xcarchive: *.xcarchive/Products/Applications/AppName.app/ IPA:the unzip folder
@property (strong) NSURL 		* buildFolderPath;//Point to the temp build folder (maybe automatically cleaned)
@property (strong) NSURL 		* outputPath;//if not empty the file have been moved from the buildFolderPath to the user customize output folder. Prefered method to get the actual path is currentOutputPath.
@property (readonly) NSURL 		* currentOutputPath;//give the path to the build dir or if moved to the customized output path


@property (strong) NSImageView 	*appIcone;//used to store the image from zip without to compute it several time


//For ipa mode
@property (strong) NSURL 		* ipaURL;

+ (ABApplication *) fakeApplication;
+ (ABApplication *) applicationWithApk:(NSURL*)archiveURL;
+ (ABApplication *) applicationIOSWithFile:(NSURL*)file;


- (NSURL*) sourceFileURL;
- (BOOL) isIpa;
- (BOOL) isXcarchive;
- (BOOL) isApk;

- (NSString*) normalizedName;
- (NSString *) ipa;//Get the name of the target ipa file
- (NSString *) apk;//Get the name of the target ipa file
- (NSURL *) urlToApp;
- (NSURL *) urlToManifest;
- (NSURL *) urlToIPA;
- (NSURL *) urlToAPK;
- (NSString *) binaryUrlWithManifestURL:(BOOL)isWithManifest;
- (NSString *) plateforme;
- (BOOL) templateRetransferable;//is the template generated is still accessible for a retransfert (usefull in case of network error)
- (NSString *) uniqueVersionIdentifier; //method to call when you want to determine the url, could be the technical version or the IC unique build number
- (void) computeFileSize;
- (BOOL) validateServerConfig;
- (BOOL) validateTemplateConfig;

- (void) parseEmbbededProfile:(NSURL*)archiveURL;


//Actions
- (NSURL *) handleBuildWithTask:(TaskManager**)task;
+ (NSURL *) pushApplication:(ABApplication*)application withBuildFolder:(NSURL*)buildFolder errorString:(NSString**)errorString FTPManager:(FTPManager*)ftpManager;

//Notification services

+ (void) notifyServicesForApplication:(ABApplication*)app withIdentifier:(NSString*)identifier buildResult:(BOOL)success;
+ (void) notifyServicesForApplication:(ABApplication*)app
					   withIdentifier:(NSString*)identifier
						  buildResult:(BOOL)isSuccessfull
								prowl:(BOOL)isProwl
							  hipchat:(BOOL)isHipchat;



/* ***********************  App builder specific ************************ */
+ (NSURL *) moveSource:(NSURL *)source versionSubFolder:(NSString*)subFolder targetDestination:(NSURL*)targetRootFolder;
+ (NSURL *) moveTemplateToOutputForApp:(ABApplication*)application withFolderDestination:(NSURL*)folderDestination;

@end
