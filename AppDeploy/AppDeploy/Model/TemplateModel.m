#import "TemplateModel.h"
#import "FileManager.h" 
#import "ConfigurationManager.h"
#import "Constants.h"

#define kKey @"key"
#define kLabel @"label"
#define kFileName @"fileName"
#define kLogo @"logo"
#define kDateFormat @"dateFormat"






#define kTemplateDateFormatNoDateFormat @"nodate"
#define kTemplateDateFormatDateOnlyFormat @"date"
#define kTemplateDateFormatDateTimeFormat @"datetime"


@implementation TemplateModel


- (BOOL) isValid {
	if (IsEmpty(self.label) || IsEmpty(self.fileName)  || ![self isExist] ) {
		return NO;
	}
	return YES;
}

-(id)initWithDictionary:(NSDictionary *)dict {
	self = [super init];
	if (self!=nil) {
		self.key = [dict objectForKey:kKey];
		self.label = [dict objectForKey:kLabel];
		self.fileName = [dict objectForKey:kFileName];
		self.logo = [dict objectForKey:kLogo];
		NSString * dateFormat = [dict valueForKey:kDateFormat];
		if (!IsEmpty(dateFormat)) {
			if ([dateFormat isEqualTo:kTemplateDateFormatNoDateFormat]) {
				self.dateFormat = TemplateDateFormatNoDate;
			}
			else if ([dateFormat isEqualTo:kTemplateDateFormatDateTimeFormat]) {
				self.dateFormat = TemplateDateFormatDateTime;
			}
			else if ([dateFormat isEqualTo:kTemplateDateFormatDateOnlyFormat]) {
				self.dateFormat = TemplateDateFormatDateOnly;
			}
			else  {
				self.dateFormat = TemplateDateFormatNoDate;
			}
		}
	}
	return self;
}

- (id) initWithDefaultDataTemplateOne {
	self = [super init];
	if (self!=nil) {
		//self.key = [dict objectForKey:kKey];
		//self.label = [dict objectForKey:kLabel];
        self.fileName = kDefaultTemplateModel1File;
        self.label = kDefaultTemplateModel1Label;
		self.logo = kDefaultTemplateModel1Logo;
        self.key = kDefaultTemplateModel1Key;
		self.dateFormat = TemplateDateFormatDateOnly;
		self.isDefaultConfig = YES;
	}
	return self;
}

- (id) initWithDefaultDataTemplateTwo {
	self = [super init];
	if (self!=nil) {
		//self.key = [dict objectForKey:kKey];
		//self.label = [dict objectForKey:kLabel];
        self.fileName = kDefaultTemplateModel2File;
		self.label = kDefaultTemplateModel2Label;
		self.dateFormat = TemplateDateFormatDateOnly;
        self.logo = kDefaultTemplateModel2Logo;
        self.key = kDefaultTemplateModel2Key;
		self.isDefaultConfig = YES;
	}
	return self;
	
}

- (BOOL) isExist {
	
	NSURL * path = [self path];
	BOOL result = [FileManager isFileExistAtPath:path];
	
	//LoggerFile(1, @"IsFileExist %@ ? answer=%d", path, result);

	
	if (!result) {
		LoggerError(0, @"Template %@ path is not valid : %@", self.label, path);
		return NO;
	}
	else {
		return YES;
	}
}


- (NSString *) exportDateFormat{
	switch (self.dateFormat) {
  case TemplateDateFormatNoDate:
			return kTemplateDateFormatNoDateFormat;
			break;
			
		case TemplateDateFormatDateOnly:
			return kTemplateDateFormatDateOnlyFormat;
			
			break;
		case TemplateDateFormatDateTime:
			return kTemplateDateFormatDateTimeFormat;
			break;
	}
}

- (NSDictionary *) exportData {
	NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
	if (!IsEmpty(self.key)) { [dictionary setObject:self.key forKey:kKey];}
	if (!IsEmpty(self.label)) { [dictionary setObject:self.label forKey:kLabel]; }
	if (!IsEmpty(self.fileName)) { [dictionary setObject:self.fileName forKey:kFileName]; }
	if (!IsEmpty(self.logo)) { [dictionary setObject:self.logo forKey:kLogo]; }
	[dictionary setObject:self.exportDateFormat forKey:kDateFormat];
	
	return dictionary;
}

- (NSString*) description {
	return [NSString stringWithFormat:@"key=\"%@\" label=%@ fileName=%@ DateFormat=%ld Logo=%@",
			self.key,
			self.label,
			self.fileName,
			self.dateFormat,
			self.logo];
}


- (NSURL*) path {
	NSURL * path = nil;
	if (IsEmpty(self.fileName)) return nil;
	
	if (self.isDefaultConfig) {
		//local path
		NSString * pathString = [[NSBundle mainBundle] pathForResource:self.fileNameWithoutExtension ofType:@"html"];
		if (pathString != nil) {
			return [NSURL fileURLWithPath:pathString];
		}
	}
	else {
		path = [[ConfigurationManager configurationFolder] URLByAppendingPathComponent:self.fileName];
	}
	return path;
}

- (NSString*)fileNameWithoutExtension {
	return [self.fileName stringByReplacingOccurrencesOfString:@".html" withString:@""];
}


#pragma mark - Find files

+ (NSArray*) findUserHtmlTemplate {
	
	NSURL * folder = [ConfigurationManager configurationFolder];
	NSError * error = nil;
	NSArray * dirContents = [[FileManager sharedManager] contentsOfDirectoryAtURL:folder
													   includingPropertiesForKeys:@[]
																		  options:NSDirectoryEnumerationSkipsHiddenFiles
																			error:&error];
	if (error !=nil) {
		LoggerError(0, @"Find html file available error : %@", error);
	}
	
	NSPredicate * fltr = [NSPredicate predicateWithFormat:@"pathExtension='html'"];
	NSArray * onlyHTMLs = [dirContents filteredArrayUsingPredicate:fltr];
	
	return onlyHTMLs;
}



@end
