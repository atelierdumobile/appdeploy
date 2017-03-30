#import "ABApplication.h"
#import "TemplateGeneration.h"
#import "ConfigurationManager.h"

@interface ABApplication()

- (NSString*) normalizedNameAndVersion;//appname/techversion/ facebook_ios/1.0

@end

@implementation ABApplication

- (id)init
{
	self = [super init];
	if (self) {
		self.sourceFileSize = nil;
		self.destFileSize = nil;
		self.icVariablesDict= [NSMutableDictionary dictionary];
	}
	return self;
}

-(NSString *)description {
	return [NSString stringWithFormat:@"%@ - %@ (%@) - uniqueIdentifier=%@ - %@ icone=%@ scheme=%@ signing=%@, serverFolder=%@", self.name, self.versionFonctionnal, self.versionTechnical, self.uniqueVersionIdentifier, self.bundleIdentifier, [self.icone absoluteString], self.scheme, self.signingIdentity, self.serverFolder];
}

- (BOOL) isIpa {
	return !IsEmpty(self.ipaURL);
}

- (BOOL) isApk {
	return self.type == ApplicationTypeAndroid;
}

- (BOOL) isXcarchive {
	return !IsEmpty(self.xcarchive);
}

- (NSURL*) outputfolderVersionPath {
	if ( IsEmpty(self.outputPath) ) {
		return nil;
	}
	else {
		return [self.outputPath URLByAppendingPathComponent:self.uniqueVersionIdentifier];
	}
	
	return nil;
}

- (NSURL*) currentOutputPath {
	if (!IsEmpty(self.outputPath)) {
		return self.outputfolderVersionPath;
	}
	else {
		return self.buildFolderPath;
	}
}


- (NSString *) plateforme {
	if (self.type == ApplicationTypeAndroid) {
		return kAndroidPlateforme;
	}
	else {
		return kIOSPlateforme;
	}
}

- (NSURL*) sourceFileURL {
	if (self.isIpa) return self.ipaURL;
	else if(self.isXcarchive) return self.xcarchive;
	else if (self.isApk) return self.xcarchive;
	return nil;
}


- (NSString *) ipa {
	return [NSString stringWithFormat:@"%@.ipa", self.normalizedName];
}

- (NSString *) apk {
	return [NSString stringWithFormat:@"%@.apk", self.normalizedName];
}

- (NSURL *) urlToApp {
	return [self appVersionnedURLWithHttps:NO];
}

- (NSURL *) urlToIPA {
	return [[self appVersionnedURLWithHttps:NO] URLByAppendingPathComponent:[self ipa]];
}

- (NSURL*) urlToAPK {
	return [[self appVersionnedURLWithHttps:NO] URLByAppendingPathComponent:[self apk]];
}


//http://atelierdumobile.com/apps/betas//MMM_POC_iOS/manifest.plist
//itms-services://?action=download-manifest&url=[[PUBLIC_SERVER_BASE_URL]]/[[APP_NAME_NORM]]/[[APP_MANIFEST_NAME]]

- (NSURL *) urlToManifest {
	return [[self appVersionnedURLWithHttps:YES] URLByAppendingPathComponent:@"manifest.plist"];
}


- (NSURL *) appVersionnedURLWithHttps:(BOOL)isHTTPS {
	return [self appVersionnedURLWithServer:self.serverConfig https:isHTTPS];
}


//HTTPS or HTTP url to the app regarding of the needs
//Note: if the app override the serverfolder name so we use it
- (NSURL *) appVersionnedURLWithServer:(ServerModel*)server https:(BOOL)isHTTPS {
	NSString * appName = self.normalizedName;
    NSString * urlToDeploy = @"";
	if (!IsEmpty(self.serverFolder)) {
		appName = self.serverFolder;
	}
    if (server.type == ServerModelLocal) {
        //TODO: do something special for local path ?
    }
	
    NSString * baseURL = @"";
    if (!IsEmpty(server.publicUrl)) {
        baseURL = server.publicUrl;
        if (isHTTPS) {
            NSString * httpsurl = server.httpsUrl;
            if (!IsEmpty(httpsurl)) {
                baseURL = httpsurl;
            }
        }
        urlToDeploy = [NSString stringWithFormat:@"%@/%@/%@", baseURL , appName, self.uniqueVersionIdentifier];
    }
    else {//base url is empty
	    urlToDeploy = [NSString stringWithFormat:@"%@/%@", appName, self.uniqueVersionIdentifier];
    }

	urlToDeploy = [urlToDeploy stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	return [NSURL URLWithString:urlToDeploy];
}


#pragma mark init


- (NSString *) uniqueVersionIdentifier {
	if (!IsEmpty(self.build_number)) {
		return self.build_number;
	}
	else return self.versionTechnical;
}



- (NSString*) normalizedNameAndVersion {
	return [NSString stringWithFormat:@"%@/%@",[self normalizedName], self.uniqueVersionIdentifier];
}

- (NSString*) normalizedName {
	NSString * name = [self.name normalizeString];
	name = [self addPlateformeExtensionToName:name];
	return name;
}


- (NSString*) addPlateformeExtensionToName:(NSString*)name {
	if (self.type == ApplicationTypeAndroid) {
		return [NSString stringWithFormat:@"%@%@", name, kAndroidSuffix];
		
	}
	else {
		return [NSString stringWithFormat:@"%@%@", name, kIOSSuffix];
	}
}

- (BOOL) templateRetransferable {
	if ( !IsEmpty(self.buildFolderPath) && [FileManager isFileExistAtPath:self.buildFolderPath]) {
		return YES;
	}
	else return NO;
}


#pragma mark - Provisionning profile

+ (NSURL *) pathToArchiveApplicationFolder:(NSURL*)archiveURL withAppFolderPath:(NSString *)applicationPath {
	NSURL * path = [[archiveURL URLByAppendingPathComponent:KProductFolder] URLByAppendingPathComponent:applicationPath];
	return path;
}



- (NSURL *) pathToEmbeddedProfile {
        NSAssert(!IsEmpty(self.archiveAppFolder), @"pathToEmbeddedProfile - archiveAppFolder is empty");
        return [IOSManager pathToEmbeddedProfileFromArchiveAppFolder:self.archiveAppFolder ];
    return nil;
}


- (BOOL) parseEmbeddedProvisonningProfileWithFile:(NSURL*)embeddedPath withContent:(NSString*)embeddedContent {
    NSDictionary * dictionary = nil;
    if(!IsEmpty(embeddedPath)) {
        dictionary = [ProvisionningProfileHelper provisioningProfileAtPath:embeddedPath];
    }
    else if (!IsEmpty(embeddedContent)) {
        dictionary = [ProvisionningProfileHelper provisioningProfileFromContent:embeddedContent];
    }
    return [self parseEmbeddedProvisonningProfile:dictionary];
}

- (BOOL) parseEmbeddedProvisonningProfile:(NSDictionary*)provisionningDict {
    if (IsEmpty(provisionningDict)) return NO;
    /*
     ExpirationDate:date
     TeamIdentifier:GTWSK8DVU4
     TeamName:L&apos;Atelier du Mobile
     UUID:b945576a-22ca-470a-943e-c6879622ddaf
     Name:Any2013
     */
    self.certificateExpiration = provisionningDict[@"ExpirationDate"];
    NSString * teamName = provisionningDict[@"TeamName"];
    NSArray * teamIdentifier = provisionningDict[@"TeamIdentifier"];
    NSString * teamIdentifierFirst = @"";
    if (!IsEmpty(teamIdentifier) && teamIdentifier.count >0) {
        teamIdentifierFirst = [NSString stringWithFormat:@" (%@)", teamIdentifier[0]];
    }
    self.signingIdentity = [NSString stringWithFormat:@"%@%@", teamName, teamIdentifierFirst];
    NSString * UUID = provisionningDict[@"UUID"];
    self.provisionningProfile = provisionningDict[@"Name"];
    if (!IsEmpty(UUID)) {
        self.provisionningProfile = [NSString stringWithFormat:@"%@ [%@]",self.provisionningProfile,UUID];
    }
    return YES;
}





+ (ABApplication *) applicationIOSWithFile:(NSURL*)file {
	ABApplication * app = nil;
	if ([FileManager isXCarchive:file] ) {
		app =  [ABApplication parseXCarchivePlist:file];
        [app parseEmbbededProfile:file];
        [IOSManager fetchEntitlementsInformation:app.archiveAppFolder];
	}
	else if ([FileManager isIPA:file] ) {
        
        //1) Plist info
		NSDictionary * plistDictionary = [IOSManager plistFromIPAFile:file];
		if (IsEmpty(plistDictionary)) {
			return nil;
		}
        app = [ABApplication parseIPAWithURL:file withInfoPlist:plistDictionary];
        
        //2) Unzip to temp folder
        NSURL * unzipFolder = [IOSManager ipaUnzip:file withBundle:app.bundleName];
        NSURL * appFolder = [IOSManager pathToAppFolderFromIpa:unzipFolder bundleName:app.bundleName];
        app.archiveAppFolder = appFolder;
        [app parseEmbbededProfile:appFolder];
    }
    else return nil;
    
    if (!IsEmpty(app)) {
        NSDictionary * entitlements = [IOSManager fetchEntitlementsInformation:app.archiveAppFolder];
        app.entitlements = entitlements;
    }
	
	return app;
}



+ (ABApplication *) applicationWithApk:(NSURL*)archiveURL {
	ABApplication * application = nil;
	application = [[ABApplication alloc]init];
	application.type = ApplicationTypeAndroid;
	
	
	//Best way is to use Aapt to analyse the apk
	if ([AndroidManager isAAPTAvailable]) {
		NSURL * aaptPath=[ConfigurationManager sharedManager].aaptTool;
		BOOL result = [AndroidManager parseAPKWithAAPT:archiveURL application:application aaptPath:aaptPath];
		if (!result) return nil;
	}
	//Second way is to use a naming convention
	else {
		NSString * name = [archiveURL lastPathComponent];
		//hack to ignore name_version_code-debug.apk
		name = [name stringByReplacingOccurrencesOfString:@"-debug.apk" withString:@""];
		name = [name stringByReplacingOccurrencesOfString:@".apk" withString:@""];
		
		NSArray * splitArray = [name componentsSeparatedByString:@"_"];
		
		if ( [splitArray count]!=3 ) {
			LoggerData(1, @"Android application doesn't follow name convention=%@ splitcount=%lu", name, (long)[splitArray count]);
			return nil;
		}
		
		if (!IsEmpty(name)) {
			
			application.name = splitArray[0];
			if (IsEmpty(application.name)) return nil;
			application.versionFonctionnal = splitArray[1];
			application.versionTechnical= splitArray[2];
		}
	}
	
	//Commun
	application.serverFolder = [NSString stringWithFormat:@"%@",application.normalizedName];
	application.xcarchive = archiveURL;//TODO use a generic path name and test on a flag instead
	application.creationDate = [FileManager creationDateForPath:archiveURL.path];
	application.signingIdentity = @"";
	
	return application;
}


#pragma mark - Plist

//TODO: to move in iOS sections

- (void) parsePlistApp:(NSURL*)archiveURL withAppPath:(NSString *)applicationPath {
	NSURL * plistURL = [[[archiveURL URLByAppendingPathComponent:KProductFolder] URLByAppendingPathComponent:applicationPath] URLByAppendingPathComponent:kPlistFileName];
	if (plistURL != nil) {
		NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfURL:plistURL];
		[self parseInfoPlist:plistDictionary];
	}
}


- (void) computeFileSize {
	if (self.isIpa) {
		self.sourceFileSize = [FileManager readableSizeForPath:[self.ipaURL path]];
	}
	else if (self.isXcarchive) {
		self.sourceFileSize = [FileManager readableSizeForPath:[self.xcarchive path]];
	}
	else if (self.isApk) {
		self.sourceFileSize = [FileManager readableSizeForPath:[self.xcarchive path]];
	}
	
	self.destFileSize = [FileManager readableSizeForPath:self.currentOutputPath.path];
	
	
	LoggerData(4, @"Size = %@ - %@", self.sourceFileSize, self.destFileSize);
}


//Plist mapping for ipa AND xcarchive from the .app folder
- (BOOL) parseInfoPlist:(NSDictionary*) plistDictionary {
	if (plistDictionary) {
		//LoggerApp(3,@"dictionary %@", plistDictionary);
		
		self.bundleIdentifier = plistDictionary[@"CFBundleIdentifier"];
		self.bundleName = plistDictionary[@"CFBundleName"];
		
		self.name = plistDictionary[@"CFBundleDisplayName"];
		if (IsEmpty(self.name)) {
			self.name = self.bundleName;
		}
		
		if (IsEmpty(self.name)) {
			LoggerData(0,@"Name is empty for application %@", self.bundleIdentifier);
			return NO;
		}
		self.versionFonctionnal = plistDictionary[@"CFBundleShortVersionString"];
		self.versionTechnical = plistDictionary[@"CFBundleVersion"];
		
		self.minimumOS = plistDictionary[@"MinimumOSVersion"];
		self.architecture = plistDictionary[@"UIRequiredDeviceCapabilities"];
		self.platforms = plistDictionary[@"CFBundleSupportedPlatforms"];
		self.sdk = plistDictionary[@"DTSDKName"];
		
		//Custo Extension from plist
		self.serverFolder = plistDictionary[@"AppDeployServerFolder"];
		if (IsEmpty(self.serverFolder)) {
			self.serverFolder = [NSString stringWithFormat:@"%@",self.normalizedName];
		}
		else {
			self.serverFolder = [self addPlateformeExtensionToName:self.serverFolder];
		}
		
		NSDictionary * iPhoneIconeDict = plistDictionary[@"CFBundleIcons"];
		NSDictionary * iPadIconeDict = plistDictionary[@"CFBundleIcons~ipad"];
		
		NSString * iconeName = nil;
		if (iPhoneIconeDict) {
			iconeName = [ABApplication findLargestIconeWithDictionary:iPhoneIconeDict isIphone:YES];
		}
		if (IsEmpty(iconeName) && iPadIconeDict ) {//try the iPad if icone is empty
			iconeName = [ABApplication findLargestIconeWithDictionary:iPadIconeDict isIphone:NO];
		}
		
		if (!IsEmpty(iconeName)) {
			if (self.isIpa) {
				self.iconeName = iconeName;//save name because we need to unzip its content only if necessary
				LoggerView(4,@"Icone - set iconeName infoplist (ipa mode)=%@", self.iconeName);
			}
			else {
				self.icone = [ABApplication findImageWithName:iconeName withPath:self.archiveAppFolder];
				LoggerView(4,@"Icone - set icone infoplist (xcarchive mode) set=%@", self.icone);
			}
		}
		
		LoggerApp(4,@"application=%@", self);
		
		//TODO: maybe add control
		return YES;
	}
	
	return NO;
}


//self.icone = [self.xcarchiveAppFolder URLByAppendingPathComponent:iconeName];
//Test image for iPhone and iPad
+ (NSURL *) findImageWithName:(NSString*)iconeName withPath:(NSURL*)url {
	
	//first iphone @2x, then @1x, then ipad retina then ipad @1x
	for (NSString * extension in @[@"@2x.png", @".png", @"@2x~ipad.png", @"~ipad.png"]) {
		NSString * iconeNameWithExtension = [NSString stringWithFormat:@"%@%@", iconeName, extension];
		NSURL * iconeUrl = [url URLByAppendingPathComponent:iconeNameWithExtension];
		if ([[NSImage alloc] initWithContentsOfURL:iconeUrl] !=nil) {
			LoggerView(5,@"Icone - findImageWithName - return =%@", iconeUrl);
			
			return iconeUrl;
		}
	}
	
	
	return nil;
}


//Take the largest icone from the dictionary, the comparaison is not really necessary the array seems ordered
+ (NSString*) findLargestIconeWithDictionary:(NSDictionary*)dict isIphone:(BOOL)isIphone  {
	NSString * iconeName = nil;
	if (!IsEmpty(dict)) {
		NSArray * iconesArray= dict[@"CFBundlePrimaryIcon"][@"CFBundleIconFiles"];
		for (NSString * anIcone in iconesArray) {
			LoggerView(4,@"Icone - found infoplist=%@", anIcone);
			
			if (IsEmpty(iconeName)) {
				iconeName = anIcone;
			}
			else {//keep the highest version
				//iconeName < anIcone
				if ([anIcone compare:iconeName options:NSNumericSearch] == NSOrderedDescending) {
					iconeName = anIcone;
				}
			}
		}
		
	}
	
	return iconeName;
}

//Plist available for xcarchive only
+ (ABApplication *) parseXCarchivePlist:(NSURL*)archiveURL {
	
	//First step is Global APP
	ABApplication * application = nil;
	
	
	NSURL * plistURL = [archiveURL URLByAppendingPathComponent:kPlistFileName];
	LoggerFile(3,@"plistFile=%@", [plistURL absoluteString]);
	NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfURL:plistURL];
	if (dictionary != nil) {
		application = [[ABApplication alloc]init];
		application.type = ApplicationTypeIOS;
		
		application.xcarchive = archiveURL;
		
		application.name = dictionary[@"Name"];
		application.serverFolder = application.normalizedName;//default value
		application.scheme = dictionary[@"SchemeName"];
		application.comment = dictionary[@"Comment"];
		application.creationDate = dictionary[@"CreationDate"];
		
		NSNumber * size = dictionary[@"AppStoreFileSize"];
		if( size !=nil) {
			application.appStoreFileSize = @([size intValue]/1024/1024);//convert to mo
		}
		
		NSDictionary * appPropertyDict = dictionary[@"ApplicationProperties"];
		application.signingIdentity = appPropertyDict[@"SigningIdentity"];
		//application.versionFonctionnal= appPropertyDict[@"CFBundleShortVersionString"];
		//application.versionTechnical = appPropertyDict[@"CFBundleVersion"];
		//application.bundle = appPropertyDict[@"CFBundleIdentifier"];
		
		NSString * applicationPath = appPropertyDict[@"ApplicationPath"];
		//complet the information with the application level
		if (!IsEmpty(applicationPath)) {
			//Specific apps settings
			application.archiveAppFolder = [ABApplication pathToArchiveApplicationFolder:archiveURL withAppFolderPath:applicationPath ];
            
            //Plist of the application folder, this one is like the ipa plist to add complement information
            [application parsePlistApp:archiveURL withAppPath:applicationPath];
		}
				
		//optionnal
		NSArray * icones = appPropertyDict[@"IconPaths"];
		if (!IsEmpty(icones) && IsEmpty(application.icone)) {
			LoggerView(4,@"Icone - found info in xcharchive IconPaths");
			
			//The largest size is the last one
			for (NSString * anIcone in icones) {
				application.icone = [archiveURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",KProductFolder, anIcone] ];
				LoggerView(4,@"Icone found xcarchive plist (url constructed)=%@", application.icone);
			}
			
			LoggerView(4,@"Icone - take icone from xcarchive plist =%@", application.icone);
		}
		
		LoggerFile(3,@"Main application %@", application);
	}
	return application;
	
}


- (void) parseEmbbededProfile:(NSURL*)archiveURL {
    NSAssert(!IsEmpty(archiveURL), @"EmbededProvisionning profile path is empty");

    NSURL * embeddedPath = [self pathToEmbeddedProfile];
    [self  parseEmbeddedProvisonningProfileWithFile:embeddedPath withContent:nil];
}

+ (ABApplication *) parseIPAWithURL:(NSURL*)ipaURL withInfoPlist:(NSDictionary*)plistDictionary {
	//First step is Global APP
	ABApplication * application = nil;
	
	application = [[ABApplication alloc]init];
	application.type = ApplicationTypeIOS;
	application.ipaURL = ipaURL;
	
	if ([application parseInfoPlist:plistDictionary]) {
		application.creationDate = [FileManager creationDateForPath:ipaURL.path];
		
		return application;
	}
	
	return nil;
}



#pragma mark - plateform specific

- (NSString *) binaryUrlWithManifestURL:(BOOL)isWithManifest {
	
	if (self.type == ApplicationTypeIOS) {
		if (isWithManifest) {
			return [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@", [[self urlToManifest] absoluteString]];
		}
		else {
			return [[self urlToIPA] absoluteString];
		}
	}
	else {
		return [[self urlToAPK] absoluteString];
	}
}


#pragma mark - actions

- (NSURL *) handleBuildWithTask:(TaskManager **)task {
	return [ABApplication handleBuild:self withTask:task];
}



//@return build folder in case of success
+ (NSURL *) handleBuild:(ABApplication *)application withTask:(TaskManager **)task {
	LoggerApp(4, @"handleBuild - xcarchiveAppURL=%@ - application=%@",application.xcarchive ,application);
	
	if (IsEmpty(application)) return nil;
	
 if ( (application.type==ApplicationTypeIOS && (!IsEmpty(application.xcarchive) || !IsEmpty(application.ipaURL)) )
	 || (application.type==ApplicationTypeAndroid  && !IsEmpty(application.apk) )
	 ){
		
		NSURL * folderDestination = nil;
		NSURL * emptyFolderPath = [FileManager createTempFolderWithFolderName:[NSString stringWithFormat:@"%@%@",TEMP_FOLDER_PREFIX, application.normalizedName]];
		folderDestination=emptyFolderPath;
		if (IsEmpty(emptyFolderPath) ) {
			LoggerError(0, @"Can't create temporary Folder");
			return nil;
		}
		
		if (IsEmpty(folderDestination) || ![FileManager isFileExistAtPath:folderDestination]) {
			LoggerError(0, @"Can't find destination folder");
			return nil;
		}
		else {
			application.buildFolderPath = folderDestination;
			BOOL success =  NO;
			
			//Xcarchive
			if (application.type == ApplicationTypeIOS && application.xcarchive) {
				success = [IOSManager createIPAWithApplication:application
													  toFolder:folderDestination
												 provisionning:application.provisionningProfile
										  defaultProvisionning:kDefaultProvisioningName
													  withTask:task];
				
				if (success) {
					LoggerApp(1, @"Archive generating ipa successfull");
				}
				else {
					LoggerApp(0, @"Archive generating ipa failure");
				}
			}
			//IPA && APK
			else if (application.isIpa || application.isApk) {
				NSURL * archiveURL = nil;
				NSString * destinationFileName = nil;
				
				if (application.isIpa) {
					archiveURL = application.ipaURL;
					destinationFileName = application.ipa;
				}
				else if (application.isApk) {
					archiveURL = application.xcarchive;
					destinationFileName = application.apk;
					
				}
				
				NSURL * source = [NSURL fileURLWithPath:[archiveURL path]];
				NSURL * destinationArchive = [folderDestination URLByAppendingPathComponent: destinationFileName];
				
				NSError * error = nil;
				
				success = [FileManager copyFile:source toURL:destinationArchive error:&error];
				if (!success) {
					LoggerFile(0, @"Can't copy ipa/apk %@  to %@ - Error = %@",[source path], [destinationArchive path], error);
				}
				
				if (success) {
					LoggerApp(1, @"IPA/APK copy successfull");
				}
				else {
					LoggerApp(0, @"IPA/APK copy failure");
				}
			}
			
			
			if (success) {
				success = [TemplateGeneration createTemplateForApplication:application
																	 toURL:folderDestination
																binaryMode:YES
														 versionFolderMode:YES];
				
				if (success) {
					LoggerApp(1, @"Templating successfull");
				}
				else {
					LoggerApp(0, @"Templating failure");
				}
				
				return folderDestination;
			}
		}
	}
	else {
		LoggerApp(0, @"No application defined");
	}
	
	return nil;
}




+ (NSURL *) pushApplication:(ABApplication*)application
			withBuildFolder:(NSURL*)buildFolder
				errorString:(NSString**)errorString
				 FTPManager:(FTPManager*)ftpManager {
	
	NSAssert(application.serverConfig!=nil, @"Configuration server is nil for publishing the application");
	if (buildFolder != nil) {//build success
		LoggerApp(1, @"Starting upload");
		
		FTPManager * ftp = nil;
		if( ftpManager == nil) {
			ftp = [[FTPManager alloc]init];
		}
		else {
			ftp = ftpManager;
		}
		BOOL result = [ftp  uploadFolder:buildFolder
								  server:application.serverConfig.server
								  ftpUrl:[NSURL URLWithString:application.serverConfig.remotePath]
								 ftpUser:application.serverConfig.username
								 ftpPass:application.serverConfig.password
					  withRootFolderName:application.serverFolder
								   error:errorString];
		
		if (result) {
			NSURL * url = [application urlToApp];
			LoggerApp(1, @"Upload ended %@", [url absoluteString]);
			return url;
		}
		else {
			LoggerApp(0, @"Upload failure");
			return nil;
		}
	}
	else {
		LoggerApp(1, @"Don't upload build signing is not available");
		return nil;
	}
}


//@return the url on the server
/*- (NSURL *) handleBuildAndPushWithError:(NSString**)errorString skipBuild:(BOOL)skipBuild {
	NSURL * buildFolder = nil;
	
	if (skipBuild && [self templateRetransferable]) {
 LoggerApp(1, @"SkipBuild");
 buildFolder = 	self.buildFolderPath;
	}
	else {
 buildFolder = [self handleBuild];
	}
	NSURL * urlToApp = [ABApplication pushApplication:self withBuildFolder:buildFolder errorString:errorString];
	
	return urlToApp;
 }*/


#pragma mark - Integration services
+ (void) notifyServicesForApplication:(ABApplication*)app
					   withIdentifier:(NSString*)identifier
						  buildResult:(BOOL)isSuccessfull {
	
	[ABApplication notifyServicesForApplication:app
								 withIdentifier:identifier
									buildResult:isSuccessfull
										  prowl:[Preference isProwlEnabled]
										hipchat:[Preference isHipchatEnabled]];
	
}

//Notify the service about a build
//
//@param app the application to send information about
//@param withIdentifier an unique id to reference the build app (optional), used in case of empty app
//@param isSuccessfull is the build is a success or a failure
//@param isProwl enable or disable the service for this notify (used for batch)
//@param isHipchat enable or disable the service for this notify (used for batch)

//archiveURL:(NSURL*)url
+ (void) notifyServicesForApplication:(ABApplication*)app
					   withIdentifier:(NSString*)identifier
						  buildResult:(BOOL)isSuccessfull
								prowl:(BOOL)isProwl
							  hipchat:(BOOL)isHipchat {
	if ( isSuccessfull || (!isSuccessfull && [Preference isEnabledNotificationInCaseOfFailure]) )  {
		//LoggerApp(4, @"Notification enter");
		
		if (isProwl) {
			BOOL succes = [ABApplication prowlMessageForApplication:app withIdentifier:identifier buildResult:isSuccessfull];
            if (succes) LoggerApp(4, @"Prowl notification sent");
		}
		/*
         else {
			LoggerApp(1, @"Prowl disabled");
		}*/
		
		if (isHipchat) {
			BOOL success = [ABApplication hipchatMessageForApplication:app withIdentifier:identifier buildResult:isSuccessfull];
			if (success) LoggerApp(4, @"HipChat notification sent");
		}
		/*
         else {
			LoggerApp(1, @"HipChat disabled");
		}*/
	}
}

+ (BOOL) prowlMessageForApplication:(ABApplication*)application withIdentifier:(NSString*)identifier buildResult:(BOOL)success {
	NSString * message = nil;
	NSError * error = nil;
	if (IsEmpty(application)) {
		message = [NSString stringWithFormat:@"Build failure for %@", identifier];
	}
	else if (success) {
		message = [NSString stringWithFormat:@"New build %@ - %@(%@)", application.name, application.versionFonctionnal, application.versionTechnical];
	}
	else {
		message = [NSString stringWithFormat:@"Build failure %@ - %@(%@)", application.name, application.versionFonctionnal, application.versionTechnical];
	}
	
	return [ProwlManager sendMessage:message withBuildURL:[[application urlToApp] absoluteString] error:&error];
}


+ (BOOL) hipchatMessageForApplication:(ABApplication*)application withIdentifier:(NSString*)identifier buildResult:(BOOL)success {
	NSString * message = [NSString stringWithFormat:@"%@ - %@(%@) - %@", application.name, application.versionFonctionnal, application.versionTechnical, application.urlToApp.absoluteString];
	NSError * error = nil;
	
	if (IsEmpty(application)) {
		message = [NSString stringWithFormat:@"Build failure for %@", identifier];
	}
	else if (success) {
		message = [NSString stringWithFormat:@"New build %@", message];
	}
	else {
		message = [NSString stringWithFormat:@"Build failure %@", message];
	}
	return [HipChatManager sendMessage:message withSuccess:success error:&error];
}



#pragma mark - move file

+ (NSURL *) moveSource:(NSURL *)source versionSubFolder:(NSString*)subFolder targetDestination:(NSURL*)targetRootFolder {
	//move to the output folder
	//We keep an intermediate move because app compilation cannot replace existing file
	if (!IsEmpty(targetRootFolder) && !IsEmpty(source)) {
		
		NSURL * targetAppFolder = targetRootFolder;
		NSURL * targetVersionSubFolder = [targetAppFolder URLByAppendingPathComponent:subFolder isDirectory:YES];
		NSURL * targetIndexHTMLFile = [targetAppFolder URLByAppendingPathComponent:@"index.html" isDirectory:NO];
		
		NSURL * sourceVersionSubFolder = [source URLByAppendingPathComponent:subFolder isDirectory:YES];
		NSURL * sourceIndexHTMLFile = [source URLByAppendingPathComponent:@"index.html" isDirectory:NO];
		
		
		NSError * error = nil;
		
		//case 0 : ROOT folder doesn't exist (ie: APPNAME)
		if (![FileManager isFileExistAtPath:targetAppFolder]) {
			BOOL success = [FileManager createFolder:targetAppFolder intermediateCreation:YES error:&error];
			if (!success) {
				LoggerError(0, @"Couln't create final output folder %@ (data remains in %@) - Error=%@", targetRootFolder, source, error);
				return nil;
			}
		}
		
		// copy redirecte html
		NSError * errorHtml = nil;
		BOOL replaceHTMLSuccess = [[FileManager sharedManager] replaceItemAtURL:targetIndexHTMLFile withItemAtURL:sourceIndexHTMLFile backupItemName:nil options:NSFileManagerItemReplacementUsingNewMetadataOnly resultingItemURL:nil error:&errorHtml];
		if (!replaceHTMLSuccess) {
			LoggerError(0, @"Couln't copy html root template final output folder %@ (data remains in %@) - Error=%@", targetIndexHTMLFile, source, errorHtml);
			return nil;
		}
		
		
		// copy version folder
		
		if ([FileManager isReadblePath:targetVersionSubFolder]) {
			NSError * errorRemoveVersionSubFolder=nil;
			BOOL successRemove = [FileManager removeFile:targetVersionSubFolder withError:&errorRemoveVersionSubFolder];
			if (!successRemove) {
				LoggerError(0,@"Couldn't remove existing folder %@ - error=%@",targetVersionSubFolder,errorRemoveVersionSubFolder);
				return nil;
			}
		}
		
		NSError * errorVersionFolder = nil;
		BOOL replaceVersionFolderSuccess = [[FileManager sharedManager] replaceItemAtURL:targetVersionSubFolder withItemAtURL:sourceVersionSubFolder backupItemName:nil options:NSFileManagerItemReplacementUsingNewMetadataOnly resultingItemURL:nil error:&errorVersionFolder];
		if (!replaceVersionFolderSuccess) {
			LoggerError(0, @"Couln't copy version folder %@ to the final output folder %@ (data remains in %@) - Error=%@", subFolder, targetVersionSubFolder, source, errorVersionFolder);
			return nil;
		}
		
		//clean source folder
		NSError * errorCleaningRootFolder=nil;
		BOOL delete = [FileManager removeFile:source withError:&errorCleaningRootFolder];
		if (!delete) {
			LoggerError(0, @"Warning couln't clean the source folder %@ - Error=%@", source, errorVersionFolder);
		}
		return targetRootFolder;
	}
	return nil;
}

//Do the job only if the ConfigurationManager isCustomTemplateFolderEnabled and there is a valid customTemplateFolder for output
//The path to the output path is updated at the end of the job if moved application.outputPath
+ (NSURL *) moveTemplateToOutputForApp:(ABApplication*)application withFolderDestination:(NSURL*)folderDestination {
	NSURL * url = folderDestination;
	ConfigurationManager * config = [ConfigurationManager sharedManager];
	if (config.isCustomTemplateFolderEnabled && !IsEmpty(config.customTemplateFolder)) {
		LoggerFile(4, @"Enter moving to customer folder");
		
		NSURL * tempTemplateFolder = folderDestination;
		NSString * appName = application.normalizedName;
		if (!IsEmpty(application.serverFolder)) {
			appName = application.serverFolder;
		}
		LoggerFile(4, @"Enter moving to customer folder %@", appName);

		
		NSURL * targetRootFolder = [config.customTemplateFolder URLByAppendingPathComponent:appName isDirectory:YES];
		//targetDist = [targetDist URLByAppendingPathComponent:application.versionTechnical isDirectory:YES];
		
		
		NSURL * outputResult = [ABApplication moveSource:tempTemplateFolder versionSubFolder:application.uniqueVersionIdentifier targetDestination:targetRootFolder];
		LoggerData(4, @"Data moved to custom folder %@", outputResult);
		folderDestination = outputResult;//TODO: maybe change state only when output successfull
		
		//we move the source so notify it
		application.outputPath = outputResult;
		LoggerFile(4, @"Exit moving to customer folder");
	}
	return url;
}


#pragma mark - Template & Server config

- (BOOL) validateServerConfig {
	if (self.serverConfig== nil || ![self.serverConfig isValid]) {
		return NO;
	}
	return YES;
}

- (BOOL) validateTemplateConfig {
	if (self.templateConfig == nil || ![self.templateConfig isValid]) {
		return NO;
	}
	return YES;
}

#pragma mark - Fake data

+ (ABApplication *) fakeApplication {
	ABApplication * fakeApp = [[ABApplication alloc]init];
	fakeApp.name = @"Test template";
	fakeApp.versionFonctionnal = @"1.0";
    fakeApp.versionTechnical = @"10";
    fakeApp.minimumOS = @"8.0";
    fakeApp.sdk = @"iphoneos8.4";

	fakeApp.bundleIdentifier = @"com.atelierdumobile.appDeployTest";
	fakeApp.type = ApplicationTypeIOS;
	
	//IC
	fakeApp.build_number = @"200";
	fakeApp.icVariablesDict = @{
		@"build_cause":@"MANUALTRIGGER",
		@"build_url":@"https://app.atelierdumobile.com/jenkins/view/Hermes/job/Test_IOS/17",
		@"commit_branch" : @"v5-dev",
		@"commit_id" : @"78f464c71a469ec11e0fe2b0f1999bac75502875",
		@"commit_tag" : @"",
		@"ws_config" : @"1",
		@"xcode_config": @"release",
		@"xcode_name" : @"xcode6.3.1.app",
		@"xcode_scheme" : @"Release",
		@"xcode_sdk" : @"iphoneos",
		@"xcode_target" : @"TestApp",
        @"env" : @"PROD",
        @"PLATFORM_BUILD_VERSION_NAME":@"5.1.1-1819727",
        @"gradle_task":@"release"
		};
	
	return fakeApp;
}


@end
