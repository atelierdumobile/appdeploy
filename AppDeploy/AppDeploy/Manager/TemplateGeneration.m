#import "TemplateGeneration.h"

@implementation TemplateGeneration

#define kDefaultHTMLFileName @"index.html"
#define kAppLogoFileName @"app.png"

+ (NSURL*) previewTemplateWithTemplate:(TemplateModel*)template application:(ABApplication*)application versioned:(BOOL)isVersionned {
	
	NSURL * tempFolder = [FileManager createTempFolderPreview];
	BOOL success = [TemplateGeneration createTemplateForApplication:application toURL:tempFolder binaryMode:NO versionFolderMode:isVersionned];
	
	if (!success) return nil;
	else {
		NSURL * url = [tempFolder URLByAppendingPathComponent:kDefaultHTMLFileName];
		return url;
	}
}


+ (NSURL*) previewTemplateWithFakeApp:(TemplateModel*)template {
	ABApplication * fakeApp =  [ABApplication fakeApplication];
	fakeApp.templateConfig = template;
	return [TemplateGeneration previewTemplateWithTemplate:template application:fakeApp versioned:NO];
}

//simple method to add some protection
+ (NSString *) replaceInString:source key:(NSString*)aKey withString:(NSString*)aString {
    if (source==nil || IsEmpty(source)) return nil;
    if (aString == nil) {
        LoggerData(0, @"Warning - replaceInString:key:withString value is nil for key=%@", aKey);
        return source;
    }
    
   return [source stringByReplacingOccurrencesOfString:aKey withString:aString];
}

+ (NSString *) generateHTMLDownloadPage:(ABApplication *) application withDateFormat:(TemplateDateFormatType)dateFormat error:(NSError**)error {
	TemplateModel* template = application.templateConfig;
	
	NSString *myTemplateHtml = nil;
	
	//Embedded
	if ([template isDefaultConfig]) {
		myTemplateHtml = [[NSBundle mainBundle] pathForResource:template.fileNameWithoutExtension ofType:@"html"];
		//LoggerData(1, @"generateHTMLDownloadPage.myTemplateHtml = %@", myTemplateHtml);
	}
	//external
	else {
		myTemplateHtml = template.path.path;
	}
	
	
	NSString* content = [NSString stringWithContentsOfFile:myTemplateHtml
												  encoding:NSUTF8StringEncoding
													 error:error];
	
	if (content != nil) {
        
        content=[TemplateGeneration replaceInString:content key:@"[[APP_NAME]]" withString:application.name];
        content=[TemplateGeneration replaceInString:content key:@"[[RELEASE_TYPE]]" withString:@"Release"];
		
		//content = [content stringByReplacingOccurrencesOfString:@"[[TITLE]]" withString:[NSString stringWithFormat:@"%@%@",application.name, @"- Beta Release"]];
		content = [TemplateGeneration replaceInString:content key:@"[[PLATEFORME]]" withString:application.plateforme];
		content = [TemplateGeneration replaceInString:content key:@"[[VERSION_CODE]]" withString:application.versionTechnical];
		content = [TemplateGeneration replaceInString:content key:@"[[VERSION_NAME]]" withString:application.versionFonctionnal];
		content = [TemplateGeneration replaceInString:content key:@"[[BINARY_URL]]" withString:[application binaryUrlWithManifestURL:YES]];
		content = [TemplateGeneration replaceInString:content key:@"[[OS_MIN]]" withString:application.minimumOS];
		content = [TemplateGeneration replaceInString:content key:@"[[SDK]]" withString:application.sdk];
		content = [TemplateGeneration replaceInString:content key:@"[[BUNDLE_IDENTIFIER]]" withString:application.bundleIdentifier];
		
		if (!IsEmpty(template.logo)) {
			content = [TemplateGeneration replaceInString:content key:@"[[LOGO_URL]]" withString:template.logo];
		}
        else {//if no url logo then use the app default icone
            content = [TemplateGeneration replaceInString:content key:@"[[LOGO_URL]]" withString:kAppLogoFileName];
        }
		content = [TemplateGeneration replaceInString:content key:@"[[APP_ICONE_NAME]]" withString:kAppLogoFileName];
		
		NSDate * now = [NSDate date];
		NSString * dateString = @"";
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		if (dateFormat== TemplateDateFormatDateTime) {
			[formatter setDateStyle:NSDateFormatterShortStyle];
			[formatter setTimeStyle:NSDateFormatterShortStyle];
			dateString = [formatter stringFromDate:now];
		}
		else if (dateFormat== TemplateDateFormatDateOnly) {
			[formatter setDateStyle:NSDateFormatterShortStyle];
			[formatter setTimeStyle:NSDateFormatterNoStyle];
			dateString = [formatter stringFromDate:now];
		}
		else {//remove no date
			dateString = @"";
		}
		
		content = [TemplateGeneration replaceInString:content key:@"[[DATE]]" withString:dateString];
        content = [TemplateGeneration replaceInString:content key:@"[[IC_UNIQUE_NUMBER]]" withString:application.uniqueVersionIdentifier];
		
		
		//Integration continous
		if (application.icVariablesDict != nil && [application.icVariablesDict  count]>0) {
			LoggerData(1, @"using data from icVariablesDict");
			for (NSString * key in application.icVariablesDict) {
				NSString * value = [application.icVariablesDict objectForKey:key];
				NSString * keyFormatted = [NSString stringWithFormat:@"[[%@]]", key.uppercaseString];
                content = [TemplateGeneration replaceInString:content key:keyFormatted withString:value];
			}
		}
		
		//Size
		[application computeFileSize];
		content = [TemplateGeneration replaceInString:content key:@"[[SIZE]]" withString:application.destFileSize];

		//Full date
		[formatter setDateStyle:NSDateFormatterShortStyle];
		[formatter setTimeStyle:NSDateFormatterShortStyle];
		dateString = [formatter stringFromDate:now];
		content = [TemplateGeneration replaceInString:content key:@"[[DATE_FULL]]" withString:dateString];
		
		return content;
	}
	else {//not found
		LoggerData(0, @"generateHTMLDownloadPage read template %@", myTemplateHtml);
		
		return nil;
	}
}



+ (NSString *) generateHTMLRootRedirectPage:(ABApplication *) application error:(NSError**)error {
	NSString *myTemplateHtml = [[NSBundle mainBundle] pathForResource:@"templateIndexRoot" ofType:@"html"];
	NSString* content = [NSString stringWithContentsOfFile:myTemplateHtml
												  encoding:NSUTF8StringEncoding
													 error:error];
	
	
	if (content != nil) {
		content = [content stringByReplacingOccurrencesOfString:@"[[REDIRECT_IDENTIFIER]]" withString:application.uniqueVersionIdentifier];
		return content;
	}
	else {//not found
		return nil;
	}
}


+ (BOOL) createTemplateForApplication:(ABApplication*)application
								toURL:(NSURL*)folder
						   binaryMode:(BOOL)isBinaryMode
					versionFolderMode:(BOOL)isVersionFolderMode {
	
	if (folder ==nil || IsEmpty(folder) || application == nil) {
		LoggerError(0, @"createTemplateForApplication with invalid arguments call");
		return NO;
	}
	
	NSURL * destinationFolder = folder;
	
	if (isVersionFolderMode) {
		destinationFolder = [folder URLByAppendingPathComponent:application.uniqueVersionIdentifier];
		BOOL createFolder = [FileManager createFolder:destinationFolder];
		if (IsEmpty(destinationFolder) || !createFolder) {
			LoggerError(0, @"createTemplateForApplication error in creating output folder");
			return NO;
		}
	}
	
	if (isVersionFolderMode) {
		//ROOT FOLDER
		//html root download page
		NSError * errorGenerateTemplate = nil;
		
		NSString * htmlRootPath = [NSString stringWithFormat:@"%@/%@", [folder path],kDefaultHTMLFileName];
		NSString * htmlRootPage = [TemplateGeneration generateHTMLRootRedirectPage:application error:&errorGenerateTemplate];
		if (htmlRootPage == nil || errorGenerateTemplate != nil) {
			LoggerFile(0,@"Empty htmlRootPage generation. Error = %@", errorGenerateTemplate);
			return NO;
		}
		NSError * errorRootPage = nil;
		
		BOOL resultRootHTML = [htmlRootPage writeToFile:htmlRootPath atomically:YES encoding:NSUnicodeStringEncoding error:&errorRootPage];
		if (!resultRootHTML) {
			LoggerFile(0,@"Cannot copy resultRootHTML %@", errorRootPage);
		}
	}
	
	//COPY BINARY
	if (isBinaryMode) {
		//move ipa/apk to version folder /0.1/
		NSString * archiveName = application.ipa;
		if (application.type == ApplicationTypeAndroid) {
			archiveName = application.apk;
		}
		
		NSError * moveError = nil;
		
		BOOL moveResult = [[FileManager sharedManager] moveItemAtURL:[folder URLByAppendingPathComponent:archiveName] toURL:[destinationFolder URLByAppendingPathComponent:archiveName] error:&moveError];
		if (!moveResult) {
			LoggerFile(0,@"Cannot move .ipa/.apk file=\"%@\" error=%@", archiveName, moveError);
		}
	}
	
	//IOS Specific
	if (application.type == ApplicationTypeIOS) {
		//manifest
		NSDictionary * manifestPlist = [IOSManager createManifest:application];
		NSString * manifestPath = [NSString stringWithFormat:@"%@/manifest.plist", [destinationFolder path]];
		BOOL resultPlist = [manifestPlist writeToFile:manifestPath atomically:YES];
		if (!resultPlist) {
			LoggerFile(0,@"Cannot copy resultPlist");
		}
	}
	
	
	//html download page
	NSError * errorGenerationDownloadPage;
	NSString * htmlPath = [NSString stringWithFormat:@"%@/%@", [destinationFolder path],kDefaultHTMLFileName];
	NSString * htmlDownloadPage = [TemplateGeneration generateHTMLDownloadPage:application withDateFormat:application.templateConfig.dateFormat error:&errorGenerationDownloadPage];
	if (IsEmpty(htmlDownloadPage) || errorGenerationDownloadPage != nil) {
		LoggerFile(0,@"Empty downloadPage generation. Error = %@", errorGenerationDownloadPage);
		return NO;
	}
	NSError * error = nil;
	
	BOOL resultHTML = [htmlDownloadPage writeToFile:htmlPath atomically:YES encoding:NSUnicodeStringEncoding error:&error];
	if (!resultHTML) {
		LoggerFile(0,@"Cannot copy resultHTML %@", error);
	}
	
	/** ****************************************** APP ICONE ****************************************** **/
	//TODO: do I need app icone in the template ???
	NSURL * iconeDestinationURL = [destinationFolder URLByAppendingPathComponent:kAppLogoFileName];
	NSString * iconSourceString = nil;

	BOOL successGenerate = false;
	if (!IsEmpty(application.icone)) {
		//Default Image icone
		iconSourceString = application.icone.path;
	}
	
	//zip file case == ipa
	if (application.appIcone != nil) {
		//LoggerFile(1, @"Image found in appIcone");
		successGenerate= [FileManager saveImage:application.appIcone.image withScale:1.0f toURL:iconeDestinationURL];
		iconSourceString=iconeDestinationURL.absoluteString;
		if (!successGenerate) {
			LoggerError(0, @"Copy internal app icone to %@ with error %@", iconeDestinationURL.path, error);
		}
		
	}
	else if (iconSourceString != nil &&  [[NSFileManager defaultManager] isReadableFileAtPath:iconSourceString]) {
		//LoggerFile(1, @"Copy source app icone %@ to %@", iconSourceString, iconeDestinationURL);
		
		//[[NSFileManager defaultManager] copyItemAtPath:iconSourceString toPath:[iconeDestinationURL path] error:&iconeCopyError];
		
		//Fix a bug with image loaded from ipa
		successGenerate= [FileManager saveImageFromImagePath:[NSURL fileURLWithPath:iconSourceString] withScale:1.0f toURL:iconeDestinationURL];
		if (!successGenerate) {
			LoggerError(0, @"Copy internal app icone to %@ with error %@", iconeDestinationURL.path, error);
		}
	}
	
	
	//Default icone app
	if (!successGenerate|| iconSourceString ==nil) {
		//Default Image icone
		NSError * iconeCopyError = nil;
		NSString * icone_name = [NSString stringWithFormat:@"app_%@", application.plateforme.lowercaseString];
		iconSourceString = [[NSBundle mainBundle]pathForResource:icone_name ofType:@"png"];
		NSURL * iconeDestination = [destinationFolder URLByAppendingPathComponent:kAppLogoFileName];
		if ( [[NSFileManager defaultManager] isReadableFileAtPath:iconSourceString]) {
			//LoggerFile(1, @"Copy app icone to %@", iconeDestination);
			[[NSFileManager defaultManager] copyItemAtPath:iconSourceString toPath:[iconeDestination path] error:&iconeCopyError];
			if (iconeCopyError!=nil) {
				LoggerError(0, @"Copy app icone to %@ with error=%@", iconeDestination, error);
			}
		}
	}
	
	return YES;
	
}




@end
