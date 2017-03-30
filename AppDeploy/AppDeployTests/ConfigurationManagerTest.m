#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "Logger.h"
#import "TemplateGeneration.h"
#import "HipChatManager.h"
#import "FileManager.h"
#import "HeaderTests.h"
#import "FTPManager.h"
#import "ConfigurationManager.h"

@interface ConfigurationManagerTest : XCTestCase

@end

@implementation ConfigurationManagerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testReadConfiguration {
	
	NSString * filePath = [ConfigurationManager stringConfigurationFolder];//[NSString stringWithFormat:@"%@/%@", kConfigPath, kConfigJsonFile];
	BOOL result = [[ConfigurationManager sharedManager]readConfigurationWithFile:filePath];
	XCTAssert(result, @"Can't read configuration");
}


@end
