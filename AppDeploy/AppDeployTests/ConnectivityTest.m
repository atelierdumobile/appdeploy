#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "Logger.h"
#import "TemplateGeneration.h"
#import "HipChatManager.h"
#import "FileManager.h"
#import "HeaderTests.h"
#import "FTPManager.h"
#import "TaskManager.h"
#import "ConstantsSecured.h"

@interface ConnectivityTest : XCTestCase

@end


@implementation ConnectivityTest

- (void)setUp {
	[super setUp];
	// Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
	// Put teardown code here. This method is called after the invocation of each test method in the class.
	[super tearDown];
}

- (void)testOVHConnection {
	NSString * SERVER = kFTPServer;
	NSString * USER = kFTPUser;
    NSString * PWD = kFTPPassword;
    NSString * ROOT_PATH = kFTPDestination;

	FTPManager * ssh = [[FTPManager alloc]init] ;
	NSString * outputError;

	SFTPConnectionStatus result = [ssh testConnectionWithServer:SERVER
										ftpUser:USER
										ftpPass:PWD
                                       rootPath:ROOT_PATH
										  error:&outputError];
	
	XCTAssertTrue(result != SFTPConnectionSuccess,@"Couln't connect to %@", SERVER);
	
}
- (void)testICConnection {
	NSString * SERVER = kICServer;
	NSString * USER = kICUser;
	NSString * PWD = kICPassword;
    NSString * ROOT_PATH = kICDestination;

	NSString * outputError;
	BOOL result = [[[FTPManager alloc]init ] testConnectionWithServer:SERVER
															  ftpUser:USER
															  ftpPass:PWD
                                                             rootPath:ROOT_PATH
																error:&outputError];
	
	XCTAssertTrue(result != SFTPConnectionSuccess,@"Couln't connect to %@", SERVER);
	
}

- (void)testSSHConnectionFailure {
	NSString * USER = kICUser;
	NSString * SERVER = kICServer;
	NSString * DEST = kICDestination;
	NSString * outputError;
	NSString * outputString;
	int result = [[[TaskManager alloc]init] executeSCPToServer:SERVER
												  sourceFolder:kSourceFileCopy
													  username:USER
												 toDestination:DEST
												  outputString:&outputString
												   errorString:&outputError];
	
	
	XCTAssertTrue(result!=0,@"Could connect whereas it should not be able to connect (not in knownserver) to %@ - code=%d - Error=\"%@\"", SERVER,result,outputError);
	
}

- (void)testSSHConnectionSuccess {
	NSString * SERVER = kFTPServer;
	NSString * USER = kFTPUser;
	NSString * DEST = kServerOutputDestination;
	NSString * outputError;
	NSString * outputString;
	
	int result = [[[TaskManager alloc]init]executeSCPToServer:SERVER
												 sourceFolder:kSourceFileCopy
													 username:USER
												toDestination:DEST
												 outputString:&outputString
												  errorString:&outputError ];
	
	
	XCTAssertTrue(result==0,@"Couln't connect to %@ - code=%d - Error=\"%@\"", SERVER,result,outputError);
	
}








@end
