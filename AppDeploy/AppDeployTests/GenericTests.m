#import <XCTest/XCTest.h>
#import "Logger.h"
#import "TemplateGeneration.h"
#import "HipChatManager.h"
#import "FileManager.h"
#import "HeaderTests.h"
@interface GenericTests : XCTestCase

@end

@implementation GenericTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testNormalizedName {
	NSString * text = @"Are You OK01?";
	NSString * normalized = [text normalizeString];
	NSString * result = @"areyouok01";
	XCTAssert([normalized isEqualToString:result], @"Test failure text not equal");
	//LoggerData(1, @"Result \"%@\"", output);
}



- (void) testValidateTemplateForNoDate {
	ABApplication * app = [ABApplication new];
	app.name = @"MyAppName";
	app.versionFonctionnal = @"1.1";
	app.versionTechnical = @"10";
	app.type = ApplicationTypeIOS;
    app.templateConfig=[[TemplateModel alloc] initWithDefaultDataTemplateOne];
	NSError * error;
	NSString * template = [TemplateGeneration generateHTMLDownloadPage:app withDateFormat:TemplateDateFormatDateOnly error:&error];// generateHTMLDownloadPage:app withDateFormat:1];
	XCTAssertNotNil(template);
	XCTAssertNil(error, @"error=%@", error);
}

@end
