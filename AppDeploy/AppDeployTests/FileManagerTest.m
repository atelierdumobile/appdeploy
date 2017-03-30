#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "Logger.h"
#import "TemplateGeneration.h"
#import "HipChatManager.h"
#import "FileManager.h"
#import "HeaderTests.h"

//TODO: to clean find a way to generate test data and reproductible
@interface FileManagerTest : XCTestCase

@end

@implementation FileManagerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



#pragma mark - File management

//TODO: load ressource from test target
- (void) testFileSize {
	NSString * path = [NSString stringWithFormat:@"%@Test 09-05-2014 12.22.xcarchive", TEST_FOLDER];
	NSString * fileSize =[FileManager readableSizeForPath:path];
	XCTAssertNotNil(fileSize, @"%@ size is wrong", path);
	LoggerData(1, @"size xcarchive = %@ - %@", fileSize, path);
	
	path =  [NSString stringWithFormat:@"%@7HugsPOC.ipa", TEST_FOLDER];
	fileSize =[FileManager readableSizeForPath:path];
	XCTAssertNotNil(fileSize, @"%@ size is wrong", path);
	LoggerData(1, @"size xcarchive = %@ - %@", fileSize, path);
}


- (void) testCreateFolder {
	
	NSError * error ;
	BOOL result = [FileManager createFolder:[NSURL fileURLWithPath:@"/tmp/toto"] intermediateCreation:YES error:&error];
	XCTAssertTrue(result);
	XCTAssertNil(error);
	
}


- (void) diasabledTestCopy {
	NSURL * source = [NSURL fileURLWithPath:@"/apps/apptesticone_ios.ipa"];
	NSURL * destination = [NSURL fileURLWithPath:@"/apps/apptesticone_ios/apptesticone_ios.ipa"];
	NSError * error = nil;
    
    XCTAssertNotNil(source, @"Source path is nil");
    XCTAssertNotNil(destination, @"Destination path is nil");
	
	BOOL res1 = [FileManager copyFile:source toURL:destination error:&error];
	XCTAssertTrue(res1, @"Error:%@",error);
	
	BOOL res2 = [FileManager copyFile:source toURL:destination error:&error];
	
	XCTAssertTrue(res2, @"Error:%@",error);
	
}

#define SourceFolderName @"source"
#define DestinationFolderName @"destination"

- (void) testFileIsExist {
	NSURL * source = [NSURL fileURLWithPath:TEST_FOLDER];
	BOOL res = [FileManager isFileExistAtPath:source];
	XCTAssertTrue(res, @"File doesn't exist");
}


- (void) debugPathAbsolutString {
	NSString * path =  [NSString stringWithFormat:@"%@/%@", TEST_FOLDER, SourceFolderName];
	NSURL * urlPath = [NSURL fileURLWithPath:path];
	LoggerApp(0, @"path=%@, absoluteString=%@", urlPath.path, urlPath.absoluteString);
	XCTAssertNotEqualObjects(urlPath.path, urlPath.absoluteString);
	
}
- (void) testFileIsReadable {
	NSString * path =  [NSString stringWithFormat:@"%@/%@", TEST_FOLDER, SourceFolderName];
	NSURL * urlPath = [NSURL fileURLWithPath:path];

	BOOL res = [[FileManager sharedManager] isReadableFileAtPath:urlPath.path];
	XCTAssertTrue(res, @"File doesn't exist : %@", path);
}

- (void) testFileIsReadableDestination {
	NSString * path =  [NSString stringWithFormat:@"%@/%@", TEST_FOLDER, DestinationFolderName];
	NSURL * urlPath = [NSURL fileURLWithPath:path];
	BOOL res = [[FileManager sharedManager] isReadableFileAtPath:urlPath.path];
	XCTAssertTrue(res, @"File doesn't exist : %@", path);
}

//copy apk file to destination folder
- (void) disabletestCopyFileSimple {
	NSURL * source = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", TEST_FOLDER, ANDROID_FILE_NAME]];
	NSURL * destination = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@/%@", TEST_FOLDER, DestinationFolderName,ANDROID_FILE_NAME]];
	NSError * error = nil;
	
	
	LoggerApp(1, @"Executing command : cp \"%@\" \"%@\"", source, destination);
	
	XCTAssertNotNil(source, @"Source path is nil");
	XCTAssertNotNil(destination, @"Destination path is nil");
	
	
	XCTAssertTrue([FileManager isFileExistAtPath:source]);
	XCTAssertTrue([FileManager isFileExistAtPath:[destination URLByDeletingLastPathComponent]]);
	
	XCTAssertTrue([[FileManager sharedManager] isReadableFileAtPath:source.path], @"Source path is nil");
	XCTAssertTrue([[FileManager sharedManager] isReadableFileAtPath:[destination URLByDeletingLastPathComponent].path], @"Source path is nil");
	
	
	BOOL res1 = [FileManager copyFile:source toURL:destination error:&error];
	XCTAssertTrue(res1, @"Error can't copy %@ to %@ :%@", source, destination, error);
}

- (void) disabletestCopyFolderSimple {
	NSURL * source = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", TEST_FOLDER, SourceFolderName]];
	NSURL * destination = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@/%@", TEST_FOLDER, DestinationFolderName, SourceFolderName]];
	NSError * error = nil;
	
	
	LoggerApp(1, @"Executing command : cp \"%@\" \"%@\"", source, destination);
	
	XCTAssertNotNil(source, @"Source path is nil");
	XCTAssertNotNil(destination, @"Destination path is nil");
	
	
	XCTAssertTrue([FileManager isFileExistAtPath:source]);
	XCTAssertTrue([FileManager isFileExistAtPath:[destination URLByDeletingLastPathComponent]]);
	
	XCTAssertTrue([[FileManager sharedManager] isReadableFileAtPath:source.path], @"Source path is nil");
	XCTAssertTrue([[FileManager sharedManager] isReadableFileAtPath:[destination URLByDeletingLastPathComponent].path], @"Source path is nil");
	
	
	BOOL res1 = [FileManager copyFile:source toURL:destination error:&error];
	XCTAssertTrue(res1, @"Error can't copy %@ to %@ :%@", source, destination, error);
}


- (void) disabletestMovingSimple {
	NSURL * source = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", TEST_FOLDER, @"Template/APPNAME"]];
	NSURL * destination = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", TEST_FOLDER, @"TemplateOutput"]];
	
	LoggerApp(1, @"Executing command : move \"%@\" \"%@\"", source, destination);
	LoggerApp(1, @"Executing command : move \"%@\" \"%@\"", source.path, destination.path);
	
	XCTAssertNotNil(source, @"Source path is nil");
	XCTAssertNotNil(destination, @"Destination path is nil");
	
	
	XCTAssertTrue([FileManager isFileExistAtPath:source]);
	XCTAssertTrue([FileManager isFileExistAtPath:destination]);
	
	
	XCTAssertTrue([[FileManager sharedManager] isReadableFileAtPath:source.path], @"Source path is nil");
	XCTAssertTrue([[FileManager sharedManager] isReadableFileAtPath:destination.path], @"Destination path is nil");
	
	BOOL result = [FileManager isReadblePath:source];
	XCTAssertTrue(result);
	
	NSError*error;
	BOOL resultMove = [FileManager moveFile:source toURL:[destination URLByAppendingPathComponent:[source lastPathComponent] isDirectory:YES] error:&error];
	XCTAssertTrue(resultMove,@"Basic Move error %@", error);
	
}

//test the move of a template folder, this test is to be enabled on demande because it require data
- (void) testMovingTemplate {
	NSURL * source = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", TEST_FOLDER, @"Template/APPNAME/"]];
	NSURL * destination = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", TEST_FOLDER, @"TemplateOutput/APPNAME/"]];
	NSString * version = @"1.0";
	
	LoggerApp(1, @"Executing command : move \"%@\" \"%@\"", source, destination);
	LoggerApp(1, @"Executing command : move \"%@\" \"%@\"", source.path, destination.path);
	
	XCTAssertNotNil(source, @"Source path is nil");
	XCTAssertNotNil(destination, @"Destination path is nil");
	
	
	XCTAssertTrue([FileManager isFileExistAtPath:source]);
	//XCTAssertTrue([FileManager isFileExistAtPath:destination]);
	
	
	XCTAssertTrue([[FileManager sharedManager] isReadableFileAtPath:source.path], @"Source path is nil");
	//XCTAssertTrue([[FileManager sharedManager] isReadableFileAtPath:destination.path], @"Destination path is nil");
	
	BOOL result = [FileManager isReadblePath:source];
	XCTAssertTrue(result);
	
	NSURL * url = [ABApplication moveSource:source versionSubFolder:version targetDestination:destination];
	XCTAssertTrue(url, @"Intelligent move error");

}




/*
 - (void) testMoveExistingFolderDuplicate {
	NSURL * source = [NSURL fileURLWithPath:@"/apps/test/"];
	NSURL * destination = [NSURL fileURLWithPath:@"/apps/destination/test/"];
	NSError * error = nil;
	
	BOOL res1 = [FileManager moveFile:source toURL:destination error:&error];
	XCTAssertTrue(res1, @"Error:%@",error);
	
	NSError * error2 = nil;
	BOOL res2 = [FileManager moveFile:source toURL:destination error:&error2];
	
	XCTAssertTrue(res2, @"Error:%@",error2);
	
 }
 */



@end
