#import "AndroidManager.h"
#import "TemplateGeneration.h"
#import <SBYZipArchive/SBYZipArchive.h>
#import "ConfigurationManager.h"

@implementation AndroidManager

+ (NSData*) imageDataFromAPK:(NSURL*)apkURL {
	return [AndroidManager imageDataFromAPK:apkURL withFileName:ANDROID_LAUNCHER_FILE_NAME];
}

+ (NSData*) imageDataFromAPK:(NSURL*)apkURL withFileName:(NSString*)imageName {
	
	NSError * error=nil;
	SBYZipArchive *archive = [[SBYZipArchive alloc] initWithContentsOfURL:apkURL error:&error];
	
	if (error != nil) {
		LoggerError(0, @"APK format failure. Exit %@",error);
		return nil;
	}
	else {
		
		[archive loadEntriesWithError:&error];
		if (error!=nil) {
			LoggerError(0, @"Reading apk failure. Exit %@",error);
			return nil;
		}
		
		if ([archive.entries count]>0) {
			SBYZipEntry * imageEntry = nil;
			
			LoggerData(1, @"targetName = %@",imageName);
			
			for (SBYZipEntry * entry in archive.entries) {
				NSString * fullfilename = [NSString stringWithFormat:@"/%@",entry.fileName ];
				NSString * filename = [fullfilename lastPathComponent];
				//LoggerData(1, @"entry=%@ - (%@)",fullfilename, filename);
		
				if (([fullfilename containsString:@"drawable"] || [fullfilename containsString:@"mipmap"] )&& [filename isEqualToString:ANDROID_LAUNCHER_FILE_NAME]) {
					LoggerData(1, @"entry=%@ FOUND!!!",fullfilename);
					imageEntry = entry;
					if ([fullfilename containsString:@"drawable-xxxhdpi"]) {
						imageEntry = entry;
						break;
					}
					else if ([fullfilename containsString:@"drawable-xxhdpi"]) {
						imageEntry = entry;
						break;
					}
					else if ([fullfilename containsString:@"drawable-xhdpi"]) {
						imageEntry = entry;
						break;
					}
					//break; if not found will be a drawable standart image
				}
			}
			LoggerData(1, @"END");

 
			if (imageEntry == nil) {
				LoggerError(0, @"Error - no image found in APK");
				return nil;
			}
			
			NSData *image = [imageEntry dataWithError:&error];
			if (error) {
				LoggerError(0, @"Can't read image of apk file");
				return nil;
			}

			return image;
		}
		
	}
	return nil;
}


#define kParsingSecurityMaxCaracter 50
+ (BOOL) parseAPKWithAAPT:(NSURL*)apkFilePath application:(ABApplication*)application aaptPath:(NSURL*)aaptPath{
	BOOL success=YES;
	if (![FileManager isReadblePath:apkFilePath]) {
		LoggerApp(0,@"Can't find apk %@", apkFilePath.absoluteString);
		return NO;
	}
	
	NSString * output = [[[TaskManager alloc]init]executeCommand:aaptPath.path withArguments:@[@"d", @"badging", apkFilePath.path]];
	LoggerData(3, @"Data found %@", output);
    
    //PackageName
	NSString * packageName = [AndroidManager findAndReplaceString:output withPattern:@"package: name=\'([a-zA-Z0-9._]*)\'.*" substitution:@"$1"];
	LoggerData(1, @"packageName=%@",packageName);
	if (IsEmpty(packageName) || [packageName length]> kParsingSecurityMaxCaracter) {
		LoggerData(0, @"packageName is empty or not conformed. Length=%ld",[packageName length]);
		packageName=@"";
		success=NO;
	}
	else {
		application.bundleIdentifier=packageName;
	}
	
    //VersionCode
	NSString * versionCode = [AndroidManager findAndReplaceString:output withPattern:@".*versionCode=\'([0-9]*)\'.*" substitution:@"$1"];
	LoggerData(1, @"versionCode=%@",versionCode);
	if (IsEmpty(versionCode) || [versionCode length]> kParsingSecurityMaxCaracter) {
		LoggerData(0, @"versionCode is empty or not conformed");
		versionCode=@"";
		success=NO;
	}
	else {
		application.versionTechnical=versionCode;
	}
    
    //VersionName
	NSString * versionName = [AndroidManager findAndReplaceString:output withPattern:@".*versionName=\'([0-9.a-zA-Z_-]*)\'.*" substitution:@"$1"];
	LoggerData(1, @"versionName=%@",versionName);
	if (IsEmpty(versionName) || [versionName length]> kParsingSecurityMaxCaracter) {
		LoggerData(0, @"versionName is empty or not conformed");
		versionName=@"";
		success=NO;
	}
	else {
		application.versionFonctionnal=versionName;
	}
	
	//correspondond to minSdkVersion
	NSString * sdkVersion = [AndroidManager findAndReplaceString:output withPattern:@".*sdkVersion:\'([0-9a-zA-Z._-]*)\'.*" substitution:@"$1"];
	LoggerData(1, @"sdkVersion=%@",sdkVersion);
	if (IsEmpty(sdkVersion) || [sdkVersion length]> kParsingSecurityMaxCaracter) {
		LoggerData(0, @"sdkVersion is empty or not conformed");
		sdkVersion=@"";
	}
	else {
		application.minimumOS=sdkVersion;
	}
	
	NSString * targetSdkVersion = [AndroidManager findAndReplaceString:output withPattern:@".*targetSdkVersion:\'([0-9a-zA-Z. _-]*)\'.*" substitution:@"$1"];
	LoggerData(1, @"targetSdkVersion=%@",targetSdkVersion);
	if (IsEmpty(targetSdkVersion) || [targetSdkVersion length]> kParsingSecurityMaxCaracter) {
		LoggerData(0, @"targetSdkVersion is empty or not conformed");
		targetSdkVersion=@"";
	}
	else {
		application.sdk=targetSdkVersion;
	}
    
    //permissions
    NSString * permissions = [AndroidManager findMultipleResult:output withPattern:@"uses-permission: name=\'([0-9a-zA-Z. _-]*)\'"];
    LoggerData(1, @"permissions=%@",permissions);
    if (IsEmpty(permissions)) {
        LoggerData(0, @"permission is empty or not conformed");
        permissions=@"";
    }
    else {
        application.permissions=permissions;
    }
    
    //supports-screens
    NSString * supportsScreens = [AndroidManager findAndReplaceString:output withPattern:@"(.*)supports-screens:[ ]+([a-zA-Z' ]*)(.*)" substitution:@"$2"];
    LoggerData(1, @"supportsScreens=%@",supportsScreens);
    if (IsEmpty(supportsScreens)|| [supportsScreens length]> 2*kParsingSecurityMaxCaracter ) {
        LoggerData(0, @"supportsScreens is empty or not conformed");
        supportsScreens=@"";
    }
    else {
        application.screens=supportsScreens;
    }
    
    //native-code
    NSString * nativeCode = [AndroidManager findAndReplaceString:output withPattern:@"(.*)native-code:[ ]+([a-zA-Z' -_]*)(.*)" substitution:@"$2"];
    LoggerData(1, @"native-code=%@",nativeCode);
    if (IsEmpty(nativeCode)|| [nativeCode length]> 2*kParsingSecurityMaxCaracter ) {
        LoggerData(0, @"nativeCode is empty or not conformed");
        nativeCode=@"";
    }
    else {
        application.architecture=nativeCode;
    }
    
    //locale-code
    NSString * locales = [AndroidManager findAndReplaceString:output withPattern:@"(.*)locales:[ ]+([a-zA-Z' -_]*)(.*)" substitution:@"$2"];
    LoggerData(1, @"locales=%@",locales);
    if (IsEmpty(locales)|| [locales length]> 8*kParsingSecurityMaxCaracter ) {
        LoggerData(0, @"locales is empty or not conformed");
        locales=@"";
    }
    else {
        application.locales=locales;
    }
    
    //densities
    NSString * densities = [AndroidManager findAndReplaceString:output withPattern:@"(.*)densities:[ ]+([0-9' ]*)(.*)" substitution:@"$2"];
    LoggerData(1, @"densities=%@",densities);
    if (IsEmpty(densities)|| [densities length]> 2*kParsingSecurityMaxCaracter ) {
        LoggerData(0, @"densities is empty or not conformed");
        densities=@"";
    }
    else {
        application.densities=densities;
    }

    
	//buildVersionName
	NSString * platformBuildVersionName = [AndroidManager findAndReplaceString:output withPattern:@".*platformBuildVersionName=\'([a-zA-Z0-9. _-]*)\'.*" substitution:@"$1"];
	LoggerData(1, @"platformBuildVersionName=%@",platformBuildVersionName);
	if (IsEmpty(platformBuildVersionName) || [platformBuildVersionName length]> kParsingSecurityMaxCaracter) {
		LoggerData(0, @"platformBuildVersionName is empty or not conformed");
		platformBuildVersionName=@"";
	}
	else {
		[application.icVariablesDict setValue:platformBuildVersionName forKey:@"PLATFORM_BUILD_VERSION_NAME"];
	}
	
	NSString * outputWithoutLineReturn=[output stringByReplacingOccurrencesOfString:@"\\n" withString:@""];//one of our app contains a \n in the name on android
	NSString * label = [AndroidManager findAndReplaceString:outputWithoutLineReturn withPattern:@".*application-label([a-zA-Z-_]*):\'([a-zA-Z0-9. _\\n-\'\"]*)\'.*" substitution:@"$2"];
	LoggerData(1, @"Label test#1 - label=%@",label);
    
    if (IsEmpty(label) || [label length]> kParsingSecurityMaxCaracter) {
        //Fallback to get a name
        label = [AndroidManager findAndReplaceString:outputWithoutLineReturn withPattern:@".*launchable-activity: name='([a-zA-Z0-9._-]*)'([ ]*)label=\'([a-zA-Z0-9. _-]*)\' icon=\'.*" substitution:@"$3"];
        LoggerData(1, @"Label test#2 - label=%@",label);
    }
    
	if (IsEmpty(label) || [label length]> kParsingSecurityMaxCaracter) {
		LoggerData(0, @"Label is not conformed");
		label=@"";
		success=NO;
	}
	else {
		application.name=label;
	}
		
	return success;
}


+ (NSString*)findMultipleResult:(NSString*)sampleText withPattern:(NSString*)pattern {
    NSError *regexError = nil;
    NSRegularExpressionOptions options = NSRegularExpressionDotMatchesLineSeparators;

    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern options:options error:&regexError];
    
    NSMutableString * outputString = [NSMutableString string];
    
    __block int row=0;
    [expression enumerateMatchesInString:sampleText options:0 range:NSMakeRange(0, [sampleText length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        NSRange range = [result rangeAtIndex:1];
        NSString * tempString = [sampleText substringWithRange:range];
        if (!IsEmpty(tempString)) {
            if (row != 0) [outputString appendString:@"\n"];
            [outputString appendString:tempString];
            row++;
        }
    }];
    
    LoggerData(1, @"outputString=%@", outputString);
    
    
    return outputString;
}

+ (NSString*)findAndReplaceString:(NSString*)sampleText withPattern:(NSString*)pattern substitution:(NSString*)substitution{
	NSError *regexError = nil;
	NSRegularExpressionOptions options = NSRegularExpressionDotMatchesLineSeparators;
	//NSString *pattern = @"package: name=\'([a-zA-Z.]*)\'(.*)";
	
	NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern options:options error:&regexError];
    
	NSRange range = NSMakeRange(0,[sampleText length]);
	NSString *modifiedString = [expression stringByReplacingMatchesInString:sampleText options:0 range:range withTemplate:substitution];
    
	return modifiedString;
}

// @"/Users/gros/Dev/Android/android-sdk-mac_x86/build-tools/22.0.1/aapt";

+ (BOOL) isAAPTAvailable {
	NSURL * cmd = [ConfigurationManager sharedManager].aaptTool;
	if (![FileManager isReadblePath:cmd]) {
		LoggerApp(0,@"parseAPKWithURL- Can't find tool %@. Check your settings", cmd);
		return NO;
	}
	return YES;
}


+ (NSString *) findAAPTFromAndroidRootFolder:(NSURL*)path {
    if (path == nil) return nil;
    NSString * aaptFound = [[[TaskManager alloc] init] executeCommand:@"/usr/bin/find" withArguments:@[path.path, @"-name", kAaptToolName, @"-maxdepth", @"3"]];
    NSArray* lines = [aaptFound componentsSeparatedByString: @"\n"];
    //LoggerData(1, @"Total lines found %ld - %@", [lines count], lines);
    
    unsigned long numberOfLine = [lines count];
   /* 
    //Debug
    int i=1;
    for (NSString * cmd in lines) {
        LoggerData(1, @"Iteration result %@ %d", cmd, i);
        i++;
    }
    */
    
    NSString * aaptLineFound = @"";
    if (aaptFound != nil && numberOfLine > 2) {
        aaptLineFound = lines[numberOfLine-2];
    }
    
    BOOL contains = [aaptLineFound containsString:kAaptToolName];
    if (!contains)
        LoggerData(1, @"aapt most recent found = %@",aaptLineFound);
    return aaptLineFound;
}



@end
