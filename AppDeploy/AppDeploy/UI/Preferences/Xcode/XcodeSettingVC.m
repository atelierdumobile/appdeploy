#import "XcodeSettingVC.h"
#import "TaskManager.h"
#import "ConfigurationManager.h"

@interface XcodeSettingVC ()
//@property (weak) IBOutlet NSTextField *outputresult;
@property (unsafe_unretained) IBOutlet NSTextView *xcodeOutput;

@property (unsafe_unretained) IBOutlet NSTextView *outputresult;
@end

@implementation XcodeSettingVC


-(NSString*)identifier{
	return NSStringFromClass(self.class);
}
-(NSImage*)toolbarItemImage{
	return [NSImage imageNamed:@"Xcode"];
}
-(NSString*)toolbarItemLabel{
	return NSLocalizedString(@"iOS", @"iOSToolbarItemLabel");
}

- (void)awakeFromNib {

	NSString * xcodeSelectVersion = [[[TaskManager alloc] init] executeCommand:@"/usr/bin/xcode-select" withArguments:@[@"-p"]];
	NSString * xcodeBuildVersion = [[[TaskManager alloc] init] executeCommand:@"/usr/bin/xcodebuild" withArguments:@[@"-version"]];
	NSString * xcodeInstalled = [[[TaskManager alloc] init] executeCommand:@"/usr/bin/find" withArguments:@[@"/Applications", @"-name", @"Xcode*.app", @"-maxdepth", @"1"]];
	
	xcodeBuildVersion= [xcodeBuildVersion stringByReplacingOccurrencesOfString:@"\n" withString:@" - "];
	
	NSString * output = [NSString stringWithFormat:@"%@%@", xcodeSelectVersion, xcodeBuildVersion];
	
	if (!IsEmpty(output)) self.outputresult.string = output;
	if (!IsEmpty(xcodeInstalled)) self.xcodeOutput.string = xcodeInstalled;
}

@end
