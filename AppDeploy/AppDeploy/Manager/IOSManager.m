#import "IOSManager.h"
#import "TemplateGeneration.h"
#import <SBYZipArchive/SBYZipArchive.h>
#import "FileManager.h"
#import "TaskManager.h"

@implementation IOSManager

+ (NSData*) imageFromIPAFile:(NSURL*)ipaURL withFileName:(NSString*)imageName {
	
	NSError * error=nil;
	SBYZipArchive *archive = [[SBYZipArchive alloc] initWithContentsOfURL:ipaURL error:&error];
	
	if (error != nil) {
		LoggerError(0, @"IPA format failure. Exit %@",error);
		return nil;
	}
	else {
		
		[archive loadEntriesWithError:&error];
		if (error!=nil) {
			LoggerError(0, @"Reading ipa failure. Exit %@",error);
			return nil;
		}
		
		if ([archive.entries count]>0) {
			SBYZipEntry * infoPlistEntry = nil;
			
			
			
			LoggerData(1, @"targetName = %@",imageName);
			
			for (SBYZipEntry * entry in archive.entries) {
				if ([entry.fileName containsString:imageName]) {
					LoggerData(1, @"Filename = %@",entry.fileName);
					infoPlistEntry = entry;
					break;
				}
			}
			
			if (infoPlistEntry == nil) {
				LoggerError(0, @"Error - no plist found in IPA");
				return nil;
			}
			
			NSData *image = [infoPlistEntry dataWithError:&error];
			if (error) {
				LoggerError(0, @"Can't read plist of ipa file");
				return nil;
			}
			return image;
		}
	}
	return nil;
}

+ (NSDictionary*) plistFromIPAFile:(NSURL*)ipaURL {
	
	NSError * error=nil;
	SBYZipArchive *archive = [[SBYZipArchive alloc] initWithContentsOfURL:ipaURL error:&error];
	
	if (error != nil) {
		LoggerError(0, @"IPA format failure. Exit %@",error);
		return nil;
	}
	else {
		
		[archive loadEntriesWithError:&error];
		if (error!=nil) {
			LoggerError(0, @"Reading ipa failure. Exit %@",error);
			return nil;
		}
		//LoggerInfo(1, @"Entries %d",[archive.entries count]);
		
		if ([archive.entries count]>0) {
			
			SBYZipEntry * infoPlistEntry = nil;
			
			
			for (SBYZipEntry * entry in archive.entries) {
				if ([entry.fileName hasSuffix:@".app/Info.plist"] && [entry.fileName hasPrefix:@"Payload/"]) {
					LoggerData(1, @"Filename = %@",entry.fileName);
					infoPlistEntry = entry;
				}
			}
			
			LoggerData(1, @"targetPlist found = %@",infoPlistEntry.fileName);
			
			if (infoPlistEntry == nil) {
				LoggerError(0, @"Error - no plist found in IPA");
				return nil;
			}
			
			
			NSData *plistData = [infoPlistEntry dataWithError:&error];
			if (error) {
				LoggerError(0, @"Can't read plist of ipa file");
				return nil;
			}
			
			NSPropertyListFormat format;
			//NSDictionary* plist = [NSPropertyListSerialization propertyListFromData:plistData mutabilityOption:NSPropertyListImmutable format:&format errorDescription:nil];
			NSDictionary* plist = [NSPropertyListSerialization propertyListWithData:plistData options:NSPropertyListImmutable format:&format error:&error];
			if (error) {
				LoggerError(0, @"Can't read content of plist in the ipa file");
				return nil;
			}
			//LoggerApp(4, @"Plist Content %@",plist);
			
			return plist;
		}
	}
	return nil;
}



+ (ABApplication *) findLastArchive {
	NSString * archiveFilePath = [self findLastModifiedArchiveFilePath];
	NSURL * archiveFileURL = [NSURL fileURLWithPath:archiveFilePath];
	ABApplication * application = nil;
	if ([FileManager isXCarchive:archiveFileURL]) {
		LoggerFile(3, @"Detected \"%@\"\nFullPath=%@", [archiveFileURL lastPathComponent],archiveFileURL);
		
		application = [ABApplication applicationIOSWithFile:archiveFileURL];
		//self.xcarchiveAppURL = archiveFileURL;
		//[((MainNSWindow *)self.window) setApplication:self.application];
		if (!IsEmpty(application)) {
		 return application;
		}
		LoggerApp(1, @"Application defined=%@", application);
		//		if (!IsEmpty(application)) {
		//			[self displayInfoAppForArchive:self.xcarchiveAppURL];
		//			return YES;
		//		}
	}
	return nil;
}




#pragma mark - Publish

+ (NSDictionary *) createManifest:(ABApplication *) application {
	
	NSString *myTemplatePlist = [[NSBundle mainBundle] pathForResource:@"templateManifest" ofType:@"plist"];
	NSMutableDictionary *templateDict = [NSMutableDictionary dictionaryWithContentsOfFile:myTemplatePlist];
	
	//NSLog(@"Plist=%@",templateDict);
	
	//Server URL
	NSString * urlToDeploy = [[application urlToIPA] absoluteString];
	
	templateDict[@"items"][0][@"assets"][0][@"url"] = urlToDeploy;
	templateDict[@"items"][0][@"metadata"][@"bundle-identifier"] = application.bundleIdentifier;
	templateDict[@"items"][0][@"metadata"][@"bundle-version"] = application.versionFonctionnal;
	templateDict[@"items"][0][@"metadata"][@"title"] = application.name;
	
	//NSLog(@"Plist=%@",templateDict);
	
	return templateDict;
}


//TODO stop running task
//TODO use class TaskManager and attach the process so we can cancel it
//if ([self.buildTask isRunning]) {
//	[self.buildTask terminate];
//}

//Return containing folder of the ipa
+ (BOOL) createIPAWithApplication:(ABApplication *)application
						 toFolder:(NSURL*)emptyFolderPath
					provisionning:(NSString*)provisionningName
			 defaultProvisionning:(NSString*)provisionningByDefault
						 withTask:(TaskManager**)task {
	
	LoggerApp(2, @"ENTER createIPA with %@",provisionningName);
	
	if (application!=nil) {
		NSString * provisionning = provisionningByDefault;
		
		if (!IsEmpty(provisionningName)) {
			provisionning = provisionningName;
		}
		
		//Create a temp folder
		if (!IsEmpty(emptyFolderPath)&&!IsEmpty(provisionning)&&!IsEmpty([application.xcarchive path])) {
			LoggerApp(4,@"createIPA starting url=%@",[application.xcarchive path]);
			
			NSURL * destinationIPA = [emptyFolderPath URLByAppendingPathComponent: application.ipa];
			
			
			LoggerTask(3, @"Will executing /usr/bin/xcodebuild -exportArchive -exportFormat ipa -archivePath \"%@\" -exportPath \"%@\" -exportProvisioningProfile %@",
					   [application.xcarchive path],
					   [destinationIPA path],
					   provisionning);
			
			BOOL success = YES;
			@try {
				NSString *outputString = nil;
				NSString *errorString = nil;
				TaskManager * currentTask = *task;
				if (currentTask ==nil) {
					 currentTask= [[TaskManager alloc] init];
				}
				
				int codeResult = [currentTask executeXcodeBuildForArchive:application.xcarchive.path
														 toDestinationIPA:destinationIPA.path
														withProvisionning:provisionning
															 outputString:&outputString
															  errorString:&errorString
														 workingDirectory:emptyFolderPath.path];
				
				LoggerData(4, @"Command return : %@",outputString);
				if (!IsEmpty(errorString)) {
					LoggerError(1, @"Signing command return (not necessary blocking) : %@",errorString);
					//success = NO; //we can got some error on stderr but with a success, focus on the signing errors on stdout
				}
				
				if ([outputString rangeOfString:@"Codesign check fails"].location != NSNotFound) {
					LoggerError(0,@"WARNING : issues execution signature (not blocking)");
					
					//Disabled since 10.9.5 we get an error Codesign check fails : /var/folders/pl/sm7322l53_gflttprjk000wr0000gn/T/XXX/APPNAME.app: resource envelope is obsolete
					//success = NO;
				}
				
				BOOL cleanXcodeBuild = YES;
				if (cleanXcodeBuild) {
					[self cleanIPATempBuildFolder:outputString withRegularExpression:@"Results at \'.*\'"];
					[self cleanPayloadTempBuildFolder:outputString withRegularExpression:@"Temporary Directory: \'.*'  \\(will NOT be deleted on exit when verbose set\\)"];
				}
				
				if (codeResult == 0 && success) {
					LoggerApp(3,@"CreateIPA succeeded.");
					
					return YES;
				}
				else {
					LoggerApp(0,@"CreateIPA failed.");
					return NO;
				}
				
			}
			@catch (NSException *exception) {
				LoggerTask(0, @"Exception Running Task: %@", [exception description]);
			}
			@finally {}
		}
	}
	else {
		LoggerApp(0, @"No application defined");
	}
	
	LoggerApp(2, @"Exit createIPA");
	
	return  NO;
}

+ (BOOL) cleanIPATempBuildFolder:(NSString*)outputString withRegularExpression:(NSString*)regularExpression {
	LoggerFile(4, @"cleanTempBuildFolder with regex=%@", regularExpression);
	
	NSError * error ;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularExpression options:NSRegularExpressionCaseInsensitive error:&error];
	
	if (error) {
		LoggerError(0, @"Regex output file error = %@", error);
	}
	
	NSArray *matches = [regex matchesInString:outputString  options:0 range:NSMakeRange(0, [outputString length])];
	for (NSTextCheckingResult * match in matches) {
		NSString* xcodeIpaBuildPath = [outputString substringWithRange:match.range];
		LoggerApp(1, @"Brut extract : %@", xcodeIpaBuildPath);
		
		xcodeIpaBuildPath = [xcodeIpaBuildPath stringByReplacingOccurrencesOfString:@"Results at '" withString:@""];
		LoggerApp(1, @"Clean step1 : %@", xcodeIpaBuildPath);
		
		xcodeIpaBuildPath = [xcodeIpaBuildPath stringByReplacingOccurrencesOfString:@"'" withString:@""];
		LoggerApp(1, @"Clean step2 : %@", xcodeIpaBuildPath);
		
		if ([xcodeIpaBuildPath hasSuffix:kIOSIPAExtension]) {
			LoggerApp(1, @"File is an ipa");
			
			NSString * containingFolderPath = [xcodeIpaBuildPath stringByDeletingLastPathComponent];
			LoggerApp(4, @"containingFolderPath=%@",containingFolderPath);
			
			NSString * containingFolderName = [containingFolderPath lastPathComponent];
			LoggerApp(4, @"containingFolderName=%@",containingFolderName);
			
			NSString * rootFolder = [containingFolderPath stringByDeletingLastPathComponent];
			LoggerApp(4, @"RootFolder=%@",rootFolder);
			
			//protection :). Confirm it is below T folder the path we are gonna remove
			if ([[rootFolder lastPathComponent] isEqualToString:@"T"]) {
				LoggerApp(4, @"Below T Folder");
				
				BOOL cleaningXcodeBuildFolderSuccess = [FileManager removeFile:[NSURL fileURLWithPath:containingFolderPath] withError:&error];
				if (!cleaningXcodeBuildFolderSuccess) {
					LoggerFile(0, @"Cleaning failure of xcode temporary build folder of %@ - %@", containingFolderPath, error);
					return NO;
				}
				else {
					LoggerFile(1, @"Cleaning success of xcode temporary build folder %@", containingFolderPath);
					return YES;
				}
			}
		}
	}
	
	return NO;
}

+ (BOOL) cleanPayloadTempBuildFolder:(NSString*)outputString withRegularExpression:(NSString*)regularExpression {
	LoggerFile(4, @"cleanTempBuildFolder with regex=%@", regularExpression);
	
	NSError * error ;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularExpression options:NSRegularExpressionCaseInsensitive error:&error];
	
	if (error) {
		LoggerError(0, @"Regex output file error = %@", error);
	}
	
	NSArray *matches = [regex matchesInString:outputString  options:0 range:NSMakeRange(0, [outputString length])];
	for (NSTextCheckingResult * match in matches) {
		NSString* xcodeIpaBuildPath = [outputString substringWithRange:match.range];
		LoggerApp(1, @"Brut extract : %@", xcodeIpaBuildPath);
		xcodeIpaBuildPath = [xcodeIpaBuildPath stringByReplacingOccurrencesOfString:@"Temporary Directory: " withString:@""];
		xcodeIpaBuildPath = [xcodeIpaBuildPath stringByReplacingOccurrencesOfString:@"  (will NOT be deleted on exit when verbose set)" withString:@""];
		LoggerApp(1, @"Clean step1 : %@", xcodeIpaBuildPath);
		
		xcodeIpaBuildPath = [xcodeIpaBuildPath stringByReplacingOccurrencesOfString:@"'" withString:@""];
		LoggerApp(1, @"Clean step2 : %@", xcodeIpaBuildPath);
		
		xcodeIpaBuildPath = [xcodeIpaBuildPath stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		LoggerApp(1, @"Clean step3 : \"%@\"", xcodeIpaBuildPath);
		
		NSString * rootFolder = [xcodeIpaBuildPath stringByDeletingLastPathComponent];
		LoggerApp(4, @"RootFolder=%@",rootFolder);
		
		//confirm it is below T folder the path we are gonna remove
		if ([[rootFolder lastPathComponent] isEqualToString:@"T"]) {
			LoggerApp(4, @"Below T Folder");
			
			BOOL cleaningXcodeBuildFolderSuccess = [FileManager removeFile:[NSURL fileURLWithPath:xcodeIpaBuildPath] withError:&error];
			if (!cleaningXcodeBuildFolderSuccess) {
				LoggerFile(0, @"Cleaning failure of xcode temporary build folder of %@ - %@", xcodeIpaBuildPath, error);
				return NO;
			}
			else {
				LoggerFile(1, @"Cleaning success of xcode temporary build folder %@", xcodeIpaBuildPath);
				return YES;
			}
		}
		
	}
	
	return NO;
}



#pragma mark - Filemanagement
+ (NSString *) findLastModifiedArchiveFilePath {
	NSString *documentsDirectory = [self archiveFolderPath];
	NSArray *docFileList = [[NSFileManager defaultManager] subpathsAtPath:documentsDirectory];
	NSEnumerator *docEnumerator = [docFileList objectEnumerator];
	NSString *docFilePath;
	NSDate *lastModifiedDate = [NSDate dateWithTimeIntervalSince1970:0];
	NSString *lastModifiedFilePath = @"";
	
	while ((docFilePath = [docEnumerator nextObject])) {
		NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:docFilePath];
		if ([FileManager isXCarchive:[NSURL fileURLWithPath:fullPath]]) {
			NSDictionary *fileAttributes = [[NSFileManager defaultManager]  attributesOfItemAtPath:fullPath error:nil];
			NSDate * currentModifiedDate = [fileAttributes fileModificationDate];
			
			if ([lastModifiedDate compare:currentModifiedDate]==NSOrderedAscending) {
				lastModifiedDate = currentModifiedDate;
				lastModifiedFilePath = fullPath;
			}
		}
	}
	
	LoggerFile(4,@"lastModifiedFilePath=%@",lastModifiedFilePath );
	return lastModifiedFilePath;
}

///@return the absolute path to the archive folder (warning : this could be change in XCode, just using the default)
+ (NSString *) archiveFolderPath {
	return [FileManager absolutePathFromHomeWithPath:kArchiveFolderPath];
}


+ (NSURL*) pathToEmbeddedProfileFromArchiveAppFolder:(NSURL*)path {
    NSAssert(!IsEmpty(path), @"pathToEmbeddedProfileFromArchiveAppFolder - path is empty");
    NSURL * embeddedProvisionningURL = [path URLByAppendingPathComponent:kEmbeddedProvisionningFileName ];
    return embeddedProvisionningURL;
}

//@param ipaPath the path where the ipa file
//@return path to the subroot folder where all the file are stored
+ (NSURL *) pathToAppFolderFromIpa:(NSURL*)ipaPath bundleName:(NSString*)bundle {
    NSURL * url =  nil;
    BOOL isIpa = YES;
    
    NSAssert(!IsEmpty(ipaPath), @"ipa path is missing");
    if (IsEmpty(ipaPath)) return nil;
    if (isIpa) {
        url = [[ipaPath URLByAppendingPathComponent:kPlayloadFolder] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.app", bundle]];
    }
    else {
        NSAssert(true, @"Not implemented");
    }
    return url;
}

+ (NSURL *) pathToEmbeddedProfile:ipaPath bundleName:(NSString*)bundle {
    NSURL * appPath = [IOSManager pathToAppFolderFromIpa:ipaPath bundleName:bundle];
    return [IOSManager pathToEmbeddedProfileFromArchiveAppFolder:appPath];
}


+ (NSString *) ipaUnzipAndReadCodeSign:(NSURL*)ipaURL withBundle:(NSString*)bundle {
	NSString * outputCodeSign = nil;
	NSURL * destinationURL = [FileManager createTempFolderWithFolderName:kFolderPrefixTempZipExtract];
	NSString * output = [[[TaskManager alloc] init] executeUnzipFile:ipaURL.path toDestination:destinationURL.path];
	if (!IsEmpty(output)) {
        NSURL * appURL = [IOSManager pathToAppFolderFromIpa:destinationURL bundleName:bundle];
		outputCodeSign = [[[TaskManager alloc] init] executeCodeSignWithPath:appURL.path];
		LoggerData(1, @"outputCodeSign=%@",outputCodeSign);
    }
	[FileManager removeFile:destinationURL withError:nil];
	//[[NSWorkspace sharedWorkspace] openFile:destinationURL.path];
	
	return outputCodeSign;
}

//@param url to the unzip ipa folder
//@return the output content text to analyze
+ (NSString *) readSecurityContentFromIPA:(NSURL*)ipaURL {
    NSURL * embeededProfile = [IOSManager pathToEmbeddedProfileFromArchiveAppFolder:ipaURL];
    if (IsEmpty(embeededProfile)) { LoggerApp(0, @"Cant find embbededprofile"); return nil;}
    NSString * outputProvisionning = nil;
    outputProvisionning = [[[TaskManager alloc] init] executeSecurityWithProvisionning:embeededProfile.path];
    LoggerData(1, @"outputProvisionning=%@",outputProvisionning);
    return outputProvisionning;
}

/** @return the content of the security information about the embbeded provisionning profile */
//deprecated
+ (NSString*) ipaUnzipAndReadSecurityContentOfEmbeddedProfile:(NSURL*)ipaURL withBundle:(NSString*)bundle {

    NSString * outputProvisionning = nil;
    NSURL * destinationURL = [FileManager createTempFolderWithFolderName:kFolderPrefixTempZipExtract];
    NSString * output = [[[TaskManager alloc] init] executeUnzipFile:ipaURL.path toDestination:destinationURL.path];
    if (!IsEmpty(output)) {
        outputProvisionning = [IOSManager readSecurityContentFromIPA:ipaURL];
    }
    //[FileManager removeFile:destinationURL withError:nil];
    //[[NSWorkspace sharedWorkspace] openFile:destinationURL.path];
    
    return outputProvisionning;
}

+ (NSURL *) ipaUnzip:(NSURL*)ipaURL withBundle:(NSString*)bundle {
	NSURL * destinationURL = [FileManager createTempFolderWithFolderName:kFolderPrefixTempZipExtract];
	NSString * output = [[[TaskManager alloc] init] executeUnzipFile:ipaURL.path toDestination:destinationURL.path];
	if (!IsEmpty(output)) {
		return destinationURL;
	}
	
	return nil;
}

+ (NSDictionary *) fetchEntitlementsInformation:(NSURL*)archiveAppFolder {
    NSString * entitlements = nil;
    if ([FileManager isReadblePath:archiveAppFolder]) {
        entitlements = [[[TaskManager alloc] init] executeCodeSignWithPath:archiveAppFolder.path];
    }
    
    NSDictionary * plist = nil;
    
    if (!IsEmpty(entitlements)) {
        NSError * error=nil;
        NSPropertyListFormat format;
        NSData *plistData = [entitlements dataUsingEncoding:NSUTF8StringEncoding];
        plist = [NSPropertyListSerialization propertyListWithData:plistData options:NSPropertyListImmutable format:&format error:&error];
        
        if (error) {
            LoggerError(0, @"Can't read content of plist in the ipa file");
        }
    }
    return plist;
}

@end
