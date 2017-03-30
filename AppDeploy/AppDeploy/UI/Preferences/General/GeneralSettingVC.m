#import "GeneralSettingVC.h"
#import "ConfigurationManager.h"

@interface GeneralSettingVC ()
@property (weak) IBOutlet NSPathControl *buildDirectory;
@property (weak) IBOutlet NSButton *customizeTemplateFolderButton;
@property (weak) IBOutlet NSButton *findAutomaticallyArchive;
@property (weak) IBOutlet NSButton *automaticallyOpenBuildFolder;

@end

@implementation GeneralSettingVC



- (void)viewDidAppear {
	[super viewDidAppear];
	
	self.buildDirectory.URL = [[ConfigurationManager sharedManager] customTemplateFolder];
	self.findAutomaticallyArchive.state = [ConfigurationManager sharedManager].isAutoScanArchiveEnabled;
	
	self.automaticallyOpenBuildFolder.state = [ConfigurationManager sharedManager].isAutomaticOpenBuildFolderEnabled;
	
	if ([ConfigurationManager sharedManager].isCustomTemplateFolderEnabled) {
		self.customizeTemplateFolderButton.state = YES;
		self.buildDirectory.enabled=YES;
	}
	else {
		self.customizeTemplateFolderButton.state = NO;
		self.buildDirectory.enabled=NO;
	}
}

-(NSString*)identifier{
	return NSStringFromClass(self.class);
}
-(NSImage*)toolbarItemImage{
	return [NSImage imageNamed:@"general"];
}
-(NSString*)toolbarItemLabel{
	return NSLocalizedString(@"General", @"GeneralToolbarItemLabel");
}

#pragma mark - Actions



- (IBAction)clickFindAutomaticallyArchive:(id)sender {
	
	if ([((NSButton*)sender) state] == NSOnState) {
		[ConfigurationManager sharedManager].isAutoScanArchiveEnabled = YES;
	}
	else {
		[ConfigurationManager sharedManager].isAutoScanArchiveEnabled = NO;
	}
	
}

- (IBAction)clickAutomaticallyOpenTemplate:(id)sender {
	if ([((NSButton*)sender) state] == NSOnState) {
		[ConfigurationManager sharedManager].isAutomaticOpenBuildFolderEnabled = YES;
	}
	else {
		[ConfigurationManager sharedManager].isAutomaticOpenBuildFolderEnabled = NO;
	}
}


- (IBAction)clickCustomizeTemplateFolder:(id)sender {
	[self customizeOutputFolderState];
}

- (IBAction)changeOutputFolder:(id)sender {
	[[ConfigurationManager sharedManager] setCustomTemplateFolder:self.buildDirectory.URL];
}

#pragma mark - output folder state
- (void) customizeOutputFolderState {
	if ([self.customizeTemplateFolderButton state] == NSOnState) {
		self.buildDirectory.enabled = YES;
		[ConfigurationManager sharedManager].isCustomTemplateFolderEnabled = YES;
	}
	else {
		self.buildDirectory.enabled = NO;
		[ConfigurationManager sharedManager].isCustomTemplateFolderEnabled = NO;
	}
}

//-(NSView*)initialKeyView{
//	return self.ftpAddressTF;
//}

//
//- (IBAction)choosePath:(id)sender {
//	NSOpenPanel *panel = [NSOpenPanel openPanel];
//	[panel setCanChooseFiles:NO];
//	[panel setCanChooseDirectories:YES];
//	[panel setAllowsMultipleSelection:NO]; // yes if more than one dir is allowed
//	
//	NSInteger clicked = [panel runModal];
//	
//	if (clicked == NSFileHandlingPanelOKButton) {
//		for (NSURL *url in [panel URLs]) {
//			LoggerApp(1, @"Here are the files %@", url);
//			[self.buildDirectory setURL:url];
//		}
//	}
//}
//


- (IBAction)openTemporaryFolder:(id)sender {
	if ([ConfigurationManager sharedManager].isCustomTemplateFolderEnabled) {
		[[NSWorkspace sharedWorkspace] openFile:[ConfigurationManager sharedManager].customTemplateFolder.path];
	}
	else {
		[[NSWorkspace sharedWorkspace] openFile:[FileManager temporaryFolder]];
	}
}

@end
