#import "TemplateSettingVC.h"
#import "TemplateModel.h"
#import "ConfigurationManager.h"
#import "TemplateGeneration.h"
#import "SoundHelper.h"

@interface TemplateSettingVC ()
@property (weak) IBOutlet NSTextField *templateDefaultConfigName;
@property (weak) IBOutlet NSPopUpButton *htmlList;
@property (weak) IBOutlet NSPopUpButton *dateFormat;
@property (weak) IBOutlet NSPopUpButton *templateList;
@property (weak) IBOutlet NSTextField *label;
@property (weak) IBOutlet NSButton *deleteButton;
@property (strong) NSMutableArray * htmlFileAvailable;//NSURL objects
@property (strong) TemplateModel * currentTemplate;
@property (weak) IBOutlet NSButton *refreshButton;
@property (weak) IBOutlet NSTextField *logoTextField;
@property (strong) IBOutlet NSTextField *key;

@end

//TODO: is the template selection safe ?
@implementation TemplateSettingVC

#pragma mark - INIT

-(NSString*)identifier{
	return NSStringFromClass(self.class);
}
-(NSImage*)toolbarItemImage{
	return [NSImage imageNamed:@"templateHtmlLogo"];
}
-(NSString*)toolbarItemLabel{
	return NSLocalizedString(@"Template", @"TemplateToolbarItemLabel");
}

- (void)viewWillAppear {
	[super viewWillAppear];
	[self htmlListInit];
	[self populateTemplateAndSelectFirstItem];
}

- (void) viewWillDisappear {
	[self saveTemplateData:self.currentTemplate];//backup when leaving
}


#pragma mark - Template population
- (void) populateTemplateAndSelectFirstItem {
	[self populateTemplateList];
	self.currentTemplate = [self currentModelItem];
	[self displayData];
	[self updateUIWithCurrentData];
}

- (void) populateTemplateAndSelectLastItem {
	[self populateTemplateList];
	NSMenuItem * lastItem = [self.templateList lastItem];
	[self.templateList selectItem:lastItem];
	self.currentTemplate = [self currentModelItem];
	[self displayData];
	[self updateUIWithCurrentData];
}

- (TemplateModel *) currentModelItem {
	NSUInteger index = self.templateList.indexOfSelectedItem;
	TemplateModel * model = [[ConfigurationManager sharedManager] templateModelAtIndex:index];
	return model;
}


#pragma mark - GUI

- (void) updateUIWithCurrentData {
	
	//Default config specific
	if ([self.currentTemplate isDefaultConfig]) {
		self.deleteButton.enabled = NO;
		self.label.enabled = NO;
		self.templateDefaultConfigName.hidden = NO;
        self.key.enabled=NO;
        
		self.htmlList.enabled = NO;
		self.htmlList.hidden = YES;
		self.refreshButton.hidden = YES;
		self.dateFormat.enabled = NO;
		self.logoTextField.enabled = NO;
	}
	else {
		self.deleteButton.enabled = YES;
		self.label.enabled = YES;
		self.templateDefaultConfigName.hidden = YES;
		self.refreshButton.hidden = NO;
        self.key.enabled=YES;
		
		self.htmlList.enabled = YES;
		self.htmlList.hidden = NO;
		self.dateFormat.enabled = YES;
		self.logoTextField.enabled = YES;
	}
	
    if (![[ConfigurationManager sharedManager] isTemplateConfigLabelIsUnique:self.currentTemplate]) {
        self.label.textColor = [NSColor redColor];
    }
    else {
        self.label.textColor = [NSColor blackColor];
    }
    
    if (![[ConfigurationManager sharedManager] isTemplateConfigKeyIsUnique:self.currentTemplate]) {
        self.key.textColor = [NSColor redColor];
    }
    else {
        self.key.textColor = [NSColor blackColor];
    }
}



- (void) displayData {
	TemplateModel * template = self.currentTemplate;
	if (template != nil) {
		//self.template.stringValue = notEmptyString(template.key);
		self.label.stringValue = notEmptyString(template.label);
		self.logoTextField.stringValue = notEmptyString(template.logo);
        //LoggerError(0, @"Date should be : %ld",template.dateFormat);
        self.key.stringValue=notEmptyString(template.key);
        if (template.isDefaultConfig) {
            self.templateDefaultConfigName.stringValue = notEmptyString(template.fileName);
        }
        else {
            [self.dateFormat selectItemAtIndex:template.dateFormat];
            NSInteger templateIndex = [self htmlIndexToSelectForTemplate:template];
            [self.htmlList selectItemAtIndex:templateIndex];
        }
    }
    else {
		LoggerError(0, @"Error template to display is empty");
	}
}


- (void)saveTemplateData:(TemplateModel*)template {
	if (!template.isDefaultConfig) {
		template.label = notEmptyString(self.label.stringValue);
		template.dateFormat = self.dateFormat.indexOfSelectedItem;
		template.fileName = notEmptyString([self htmlPathToCurrentSelection].lastPathComponent);
        template.logo = notEmptyString(self.logoTextField.stringValue);
        template.key = notEmptyString(self.key.stringValue);
	}
	else {
		//LoggerConfig(0, @"Not saving default config");
	}
}


//@return index, otherwise -1 if not found
- (NSInteger) htmlIndexToSelectForTemplate:(TemplateModel*)template {
	NSString * fileName = template.fileName;
	
	int i = 0;
	for (NSURL * currentFile in self.htmlFileAvailable) {
		if ([[currentFile lastPathComponent] isEqualToString:fileName]) {
			return i;
		}
		i++;
	}
	
	return -1;
	
}


- (NSURL*) htmlPathToCurrentSelection {
	
	NSInteger index = self.htmlList.indexOfSelectedItem;
	if (index >= 0 && (index < [self.htmlList numberOfItems])) {
		return self.htmlFileAvailable[self.htmlList.indexOfSelectedItem];
	}
	return nil;
}

- (NSArray*)titlesOfList {
	NSArray * templateModels = [ConfigurationManager sharedManager].templateModels;
	NSMutableArray * titles = [NSMutableArray array];
	for (TemplateModel * aConfig in templateModels) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self BEGINSWITH %@", aConfig.label];
		NSArray *filteredArray = [titles filteredArrayUsingPredicate:predicate];
		NSUInteger nbreDuplication = [filteredArray count];
		if (nbreDuplication>0) {
			[titles addObject:[NSString stringWithFormat:@"%@ (%ld)",aConfig.label,nbreDuplication]];
		}
		else {
			[titles addObject:aConfig.label];
		}
	}
	return titles;
}

- (void) populateTemplateList {
	[[self.templateList menu] removeAllItems];
	NSArray * titles = [self titlesOfList];
	[self.templateList addItemsWithTitles:titles];
}

//usefull when user update the label
- (void) refreshTemplateListItemName {
	NSArray * templates = [ConfigurationManager sharedManager].templateModels;
	NSArray * titles = [self titlesOfList];
	
	if ([titles count] == [self.templateList numberOfItems]) {
		for (int i = 0; i<[self.templateList numberOfItems];i++) {
			NSMenuItem * item = [self.templateList itemAtIndex:i];
			item.title = titles[i];
		}
	}
	else {
		NSInteger itemSelected = self.templateList.indexOfSelectedItem;
		LoggerData(0, @"ItemSelected = %ld - number of items %ld - number of configs %ld", itemSelected, self.templateList.numberOfItems, [templates count]);
	}
}


#pragma mark - Actions

- (IBAction)openLogoURL:(id)sender {
	
	if (self.currentTemplate && !IsEmpty(self.logoTextField.stringValue)) {
		NSURL * url = [NSURL URLWithString:self.logoTextField.stringValue];
		[FileManager openURL:url];
	}
}

- (IBAction)resfreshHTMLList:(id)sender {
	[self htmlListInit];
}

- (IBAction)onDateFormatChange:(id)sender {
	[self saveTemplateData:self.currentTemplate];
}


- (IBAction)clickPreviewTemplate:(id)sender {
    
    TemplateModel * template = [self currentTemplate];
    NSURL * url =  [TemplateGeneration previewTemplateWithFakeApp:template];
    if (url != nil) {
        LoggerData(1,@"URL to preview=%@",url);
        [[NSWorkspace sharedWorkspace] openFile:url.path];
    }
}

- (IBAction)editTemplateAction:(id)sender {
    
    BOOL success = NO;
    TemplateModel * template = [self currentTemplate];
    NSURL * urlRoot = [ConfigurationManager configurationFolder];
    if (template.isDefaultConfig) {//find it in the app bundle
        NSString * path = [NSString stringWithFormat:@"%@%@",[[NSBundle mainBundle] bundlePath], @"/Contents/Resources/"];
        urlRoot = [NSURL fileURLWithPath:path];
    }

    if (urlRoot != nil) {
        NSString * filename = template.fileName;
        if (!IsEmpty(filename)) {
           NSURL * urlWithFilename = [urlRoot URLByAppendingPathComponent:filename];
            LoggerApp(3, @"Opening template file : %@", urlWithFilename);
            //[[NSWorkspace sharedWorkspace] openFile:urlWithFilename.path];
            [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[urlWithFilename]];
            success=YES;
        }
    }
    
    if (!success) [SoundHelper bipError];

}

- (IBAction)openFolder:(id)sender {
	[[NSWorkspace sharedWorkspace] openFile:[ConfigurationManager configurationFolder].path];

}

//this the template html file
- (IBAction)onTemplateFileChange:(id)sender {
	[self saveTemplateData:self.currentTemplate];
}

//this is the main template config
- (IBAction)selectTemplateAction:(id)sender {
	
	[self saveTemplateData:self.currentTemplate];//save previous template
	self.currentTemplate = [self currentModelItem];
	LoggerError(0, @"New template selection with path=%@",self.currentTemplate);
	[self refreshTemplateListItemName];//correct for perf ?
	
	[self updateUIWithCurrentData];
	[self displayData];
}


- (IBAction)addNewModelAction:(id)sender {
	TemplateModel * newTemplate = [[TemplateModel alloc]init];
	newTemplate.label = @"new config";
    newTemplate.fileName = @"new.html";
    newTemplate.key = @"";
	[[ConfigurationManager sharedManager].templateModels addObject:newTemplate];
	[self populateTemplateAndSelectLastItem];
}

- (IBAction)deleteTemplateAction:(id)sender {
	//TemplateModel *  current = self.currentTemplate;
	//LoggerData(0, @"Will remove template at index %ld", self.templateList.indexOfSelectedItem);
	[[ConfigurationManager sharedManager].templateModels removeObjectAtIndex:self.templateList.indexOfSelectedItem];
	self.currentTemplate = nil;
	[self populateTemplateAndSelectFirstItem];
	
	//LoggerConfig(1, @"Delete current template %@", current.label);
}



- (void)controlTextDidEndEditing:(NSNotification *)aNotification {
	LoggerConfig(1, @"controlTextDidEndEditing");
	

	//if([notification object] == self.securePassword) {
	//
	//	[Preference savePwd:[self.securePassword stringValue]];
	//	NSLog(@"The contents of the text field changed");
	//}
	[self saveTemplateData:self.currentTemplate];
	
	NSTextField* textField = (NSTextField *)[aNotification object];
	if (textField == self.label) {
		LoggerConfig(1, @"controlTextDidEndEditing label end of edition");
		
		[self refreshTemplateListItemName];
	}
	
	[self updateUIWithCurrentData];
}

- (IBAction)aboutAction:(id)sender {
    
    NSString * message = @""
    "Create a template, copy the one from the app and you can adapt to anything that match your needs:\n"
    "Supported tags:\n"
    "- [[APP_NAME]] - the application name/label\n"
    "- [[RELEASE_TYPE]] - hardcoded to release for now\n"
    "- [PLATEFORME]] - possible value is iOS or Android\n"
    "- [[VERSION_CODE]] - iOS=CFBundleShortVersionString - Android=VersionName\n"
    "- [[VERSION_NAME]] - CFBundleShortVersionString\n"
    "- [[IC_UNIQUE_NUMBER]] - build number (if overrided) otherwise CFBundleVersion/versionCode\n"
    "- [[BINARY_URL]] - the url to download the binary\n"
    "- [[OS_MIN]] - minimum compatibilty sdk\n"
    "- [[SDK]] - the sdk\n"
    "- [[BUNDLE_IDENTIFIER]]\n"
    "- [[LOGO_URL]] - the url your provide\n"
    "- [[APP_ICONE_NAME]] - the app icone\n"
    "- [[SIZE]] - the size of the binary, format is according to the UI defined in the template\n"
    "- [[DATE]] - the date\n"
    "- [[DATE_FULL]] - the full date and time\n"
    "- Extension: if you are using in command line, you can provide parameters ""--ic_XXX=value"" and use the tag in uppercase [XXX] without the 'IC_' part\n"
    "";
    [self showMessage:message withTitle:@"Template info"];
}



#pragma mark - Html lists
- (void) htmlListInit {
	self.htmlFileAvailable = [NSMutableArray array];
	[self findHtmlFilesAvailable];
	[self populateHtmlList];
}


- (void) findHtmlFilesAvailable {
	if (self.htmlFileAvailable !=nil) {
		[self.htmlFileAvailable removeAllObjects];
	}
	//static list
	//[self.htmlFileAvailable addObjectsFromArray:files];
	//List the file in the folder
	NSArray * files = [TemplateModel findUserHtmlTemplate];
	if (files != nil && [files count]>0) {
		LoggerConfig(1, @"Adding : %ld -> %@",[files count], files);
		[self.htmlFileAvailable addObjectsFromArray:files];
	}
}

- (void) populateHtmlList {
	[[self.htmlList menu] removeAllItems];
	
	NSArray * items = self.htmlFileAvailable;
	for (NSString * aFile in items) {
		LoggerData(1, @"Html file available %@ - %@ - lastPath=%@", aFile, aFile.class, aFile.lastPathComponent);
		[self.htmlList addItemWithTitle:aFile.lastPathComponent];
	}
}



@end
