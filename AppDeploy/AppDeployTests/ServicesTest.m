#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "ConstantsSecured.h"

@interface ServicesTest : XCTestCase

@end

@implementation ServicesTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


#pragma mark - SERVICES

- (void) testHipChatSucess {
	NSString * message = @"Build success";
	NSError * error = nil;
	BOOL sendResult = [HipChatManager sendMessage:message color:@"green" authToken:HIPCHAT_TOKEN roomID:HIPCHAT_ROOM error:&error];
	
	XCTAssertTrue(sendResult, @"Send failure");
	XCTAssertNil(error);
}

- (void) testHipChatBuildFailure{
	NSString * message = @"Build failure AppName";
	NSError * error = nil;
	BOOL sendResult = [HipChatManager sendMessage:message color:@"red" authToken:HIPCHAT_TOKEN roomID:HIPCHAT_ROOM error:&error];
	
	XCTAssertTrue(sendResult, @"Send failure");
	XCTAssertNil(error);
}



@end
