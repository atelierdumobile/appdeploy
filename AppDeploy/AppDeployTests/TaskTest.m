#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "Logger.h"
#import "TemplateGeneration.h"
#import "HipChatManager.h"
#import "FileManager.h"
#import "HeaderTests.h"
#import "FTPManager.h"
#import "ConfigurationManager.h"
#import "TaskManager.h"
#import <SBYZipArchive/SBYZipArchive.h>

@interface TaskTest : XCTestCase

@end


#define ipaPath @"/Users/gros/Dev/SCM/mac/AppDeploy/UnitTestFolder/archives/7HugsPOC.ipa"
#define xcarchivePath @"/Users/gros/Dev/SCM/mac/AppDeploy/UnitTestFolder/archives/DiabetoPartner release 16-03-2015 16.14.xcarchive"
#define xcarchiveSubfolder @"/Products/Applications/DiabetoPartner.app"

@implementation TaskTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void) testCodeSign {
	NSString * urlToApp = [NSString stringWithFormat:@"%@/%@", xcarchivePath, xcarchiveSubfolder];
	NSString * output = [[[TaskManager alloc]init]executeCodeSignWithPath:urlToApp];
	XCTAssert(!IsEmpty(output), @"Code sign output is empty=%@",output);
}

- (void) testCodeSignIpaWithUnzip {
	NSURL * fileURL = [NSURL fileURLWithPath:ipaPath];
	
	if ([FileManager isFileExistAtPath:fileURL] && [FileManager isIPA:fileURL]) {
		LoggerFile(2, @"File = %@", fileURL);
		ABApplication * app = [ABApplication applicationIOSWithFile:fileURL];
		
		NSString * outputCodeSign = [IOSManager ipaUnzipAndReadCodeSign:app.ipaURL withBundle:app.bundleIdentifier];
		LoggerData(1, @"outputCodeSign=%@",outputCodeSign);
		XCTAssert(!IsEmpty(outputCodeSign), @"Code sign output is empty=%@",outputCodeSign);
	}
}

- (void) testAndroidAAPTBackup {
	NSString * apkFilePath = ANDROID_FILE_NAME_FULLPATH;
	
	NSString * cmd = @"/Users/gros/Dev/Android/android-sdk-mac_x86/build-tools/22.0.1/aapt";
	if (![[FileManager sharedManager]isReadableFileAtPath:cmd]) {
		XCTFail(@"Can't find command %@", cmd);
	}
	
	if (![[FileManager sharedManager]isReadableFileAtPath:apkFilePath]) {
		XCTFail(@"Can't find apk %@", cmd);
	}
	
	NSString * output = [[[TaskManager alloc]init]executeCommand:cmd withArguments:@[@"d", @"badging", apkFilePath]];
	LoggerData(1, @"Data found %@", output);
	


	NSString * sampleText = output;
	NSError *regexError = nil;
	NSRegularExpressionOptions options = 0;
	NSString *pattern = @"package: name=\'([a-zA-Z.]*)\'";
	
	NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern options:options error:&regexError];

	if (regexError) {
		LoggerError(0, @"Regex output file error = %@", regexError);
	}
	
	NSArray *matches = [expression matchesInString:sampleText  options:0 range:NSMakeRange(0, [sampleText length])];
	for (NSTextCheckingResult * match in matches) {
		NSString* data = [sampleText substringWithRange:match.range];
		LoggerApp(1, @"Brut extract :%@ \n  %@", NSStringFromRange(match.range),data);//xcodeIpaBuildPath);
	}
	
		
	
	
	XCTAssert(!IsEmpty(output), @"APK can't be nill=%@",output);
}



- (void) testAndroidAAPT {
	NSString * apkFilePath = ANDROID_FILE_NAME_FULLPATH_MSD;
	//ok
	//apkFilePath = @"/Users/gros/Dev/SCM/IC/AppTestAndroid/app/build/outputs/apk/app_1.0_1-debug.apk";
	//no retour ligne
	//apkFilePath = @"/Users/gros/Dev/SCM/Android/MSD-Android/Diabete/build/outputs/apk/DiabetoPartner_2.1_10-debug.apk";
	
	NSString * cmd = @"/Users/gros/Dev/Android/android-sdk-mac_x86/build-tools/22.0.1/aapt";
	if (![[FileManager sharedManager]isReadableFileAtPath:cmd]) {
		XCTFail(@"Can't find command %@", cmd);
	}
	
	if (![[FileManager sharedManager]isReadableFileAtPath:apkFilePath]) {
		XCTFail(@"Can't find apk %@", cmd);
	}
	
	NSString * output = [[[TaskManager alloc]init]executeCommand:cmd withArguments:@[@"d", @"badging", apkFilePath]];
	//LoggerData(1, @"Data found %@", output);
	
	NSString * packageName = [self findAndReplaceString:output withPattern:@"package: name=\'([a-zA-Z0-9.]*)\'.*" substitution:@"$1"];
	LoggerData(1, @"packageName=%@",packageName);

	NSString * versionCode = [self findAndReplaceString:output withPattern:@".*versionCode=\'([0-9]*)\'.*" substitution:@"$1"];
	LoggerData(1, @"versionCode=%@",versionCode);
	
	NSString * versionName = [self findAndReplaceString:output withPattern:@".*versionName=\'([0-9.a-zA-Z_-]*)\'.*" substitution:@"$1"];
	LoggerData(1, @"versionName=%@",versionName);
	
	NSString * sdkVersion = [self findAndReplaceString:output withPattern:@".*sdkVersion:\'([0-9a-zA-Z._-]*)\'.*" substitution:@"$1"];
	LoggerData(1, @"sdkVersion=%@",sdkVersion);
	
	NSString * targetSdkVersion = [self findAndReplaceString:output withPattern:@".*targetSdkVersion:\'([0-9a-zA-Z. _-]*)\'.*" substitution:@"$1"];
	LoggerData(1, @"targetSdkVersion=%@",targetSdkVersion);
	
	
	NSString * platformBuildVersionName = [self findAndReplaceString:output withPattern:@".*platformBuildVersionName=\'([a-zA-Z0-9. _-]*)\'.*" substitution:@"$1"];
	LoggerData(1, @"platformBuildVersionName=%@",platformBuildVersionName);
	
	NSString * outputWithoutLineReturn=[output stringByReplacingOccurrencesOfString:@"\\n" withString:@""];//one of our app contains a \n in the name on android
	NSString * label = [self findAndReplaceString:outputWithoutLineReturn withPattern:@".*application-label:\'([a-zA-Z0-9. _\\n-]*)\'.*" substitution:@"$1"];
	LoggerData(1, @"label=%@",label);
	
	
	XCTAssert(!IsEmpty(output), @"APK can't be nill=%@",output);
}

- (NSString*)findAndReplaceString:(NSString*)sampleText withPattern:(NSString*)pattern substitution:(NSString*)substitution{
	NSError *regexError = nil;
	NSRegularExpressionOptions options = NSRegularExpressionDotMatchesLineSeparators;
	//NSString *pattern = @"package: name=\'([a-zA-Z.]*)\'(.*)";
	//NSMatchingOptions matchingOptions = 0;
	
	NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern options:options error:&regexError];
	
	NSRange range = NSMakeRange(0,[sampleText length]);
	NSString *modifiedString = [expression stringByReplacingMatchesInString:sampleText options:0 range:range withTemplate:substitution];
	return modifiedString;
}

@end
