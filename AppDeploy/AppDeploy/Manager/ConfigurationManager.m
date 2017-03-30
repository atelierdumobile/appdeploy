#import "ConfigurationManager.h"
#import "Constants.h"

@interface ConfigurationManager()


@end

@implementation ConfigurationManager


#define kKeyServer @"Server"
#define kKeyMapping @"Mapping"
#define kKeyTemplate @"Template"
#define kKeyGeneralSettings @"GeneralSettings"

//General
#define kKeyAutomaticArchiveScan @"archiveScanAtStartup"
#define kKeyAndroidSDKPath @"sdkAndroidFolder"
#define kKeyAutomaticOpenBuildFolderEnabled @"openBuildFolder"
#define kKeyCleanAfterBuildEnabled @"cleanBuildDataEnabled"
#define kKeyOutputFolderEnabled @"ouputFolderEnabled"
#define kKeyOutputFolder @"outputFolder"


#pragma mark - Init

+ (ConfigurationManager*)sharedManager {
	static ConfigurationManager *sharedMyManager = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedMyManager = [[self alloc]init];
	});
	return sharedMyManager;
}


- (id)init {
	self = [super init];
	if (self) {
		//	self.delegate=self;
		self.templateModels = [NSMutableArray array];
		self.mappingModels = [NSMutableArray array];
		self.serverConfigModels = [NSMutableArray array];
	}
	return self;
}



#pragma mark - Read & save configuration
-(NSDictionary*) exportData {
	
	NSMutableDictionary * globalConfiguration = [NSMutableDictionary dictionary];

	//General
	NSMutableDictionary * generalSettingDict = [NSMutableDictionary dictionary];
	[generalSettingDict setObject:@(self.isAutoScanArchiveEnabled) forKey:kKeyAutomaticArchiveScan];
	[generalSettingDict setObject:@(self.isAutomaticOpenBuildFolderEnabled) forKey:kKeyAutomaticOpenBuildFolderEnabled];
	[generalSettingDict setObject:@(self.isCleanAfterBuildEnabled) forKey:kKeyCleanAfterBuildEnabled];
	[generalSettingDict setObject:@(self.isCustomTemplateFolderEnabled) forKey:kKeyOutputFolderEnabled];
	if (!IsEmpty(self.customTemplateFolder)) {
		[generalSettingDict setObject:self.customTemplateFolder.path forKey:kKeyOutputFolder];
	}
	else {
		[generalSettingDict setObject:[NSNull null] forKey:kKeyOutputFolder];
	}
	
	if (!IsEmpty(self.sdkAndroid)) {
		[generalSettingDict setObject:self.sdkAndroid.path forKey:kKeyAndroidSDKPath];
	}
	else {
		[generalSettingDict setObject:[NSNull null] forKey:kKeyAndroidSDKPath];
	}
	
	[globalConfiguration setObject:generalSettingDict forKey:kKeyGeneralSettings];
	
	//Server
	NSMutableArray * serverArray = [NSMutableArray array];
	for (ServerModel * server in self.serverConfigModels) {
		if (!server.isDefaultConfig)  [serverArray addObject:[server exportData]];
	}
	[globalConfiguration setObject:serverArray forKey:kKeyServer];
	
	//Template
	NSMutableArray * templateArray = [NSMutableArray array];
	for (TemplateModel * temp in self.templateModels) {
		if (!temp.isDefaultConfig) [templateArray addObject:[temp exportData]];
	}
	[globalConfiguration setObject:templateArray forKey:kKeyTemplate];
	
	//Mapping
	NSMutableArray * mappingArray = [NSMutableArray array];
	for (MappingModel * temp in self.mappingModels) {
		[mappingArray addObject:[temp exportData]];
	}
	[globalConfiguration setObject:mappingArray forKey:kKeyMapping];
	
	return globalConfiguration;
}


- (BOOL) saveConfiguration{
	return [self saveConfiguration:self];
}

- (BOOL) saveConfiguration:(ConfigurationManager *) configuration {
	NSURL * libraryURL = [NSURL fileURLWithPath:[FileManager preference]];
	NSString* bundleID = [[NSBundle mainBundle] bundleIdentifier];
	NSURL * defaultConfigFolder = [libraryURL URLByAppendingPathComponent:bundleID];
	
	if (![FileManager isFileExistAtPath:defaultConfigFolder]) {
		NSError * error = nil;
		BOOL creationConfigFolder = [FileManager createFolder:defaultConfigFolder intermediateCreation:YES error:&error];
		
		if (!creationConfigFolder) {
			LoggerError(0, @"Error=%@", error);
		}
	}

	NSURL * defaultConfigFile = [defaultConfigFolder URLByAppendingPathComponent:kConfigJsonFile];
	
	NSDictionary * data = [self exportData];
	NSString * dataJson = [ConfigurationManager generateJSON:data];
	
	NSError * error = nil;
	BOOL writeConfigFileResult = [dataJson writeToURL:defaultConfigFile atomically:YES  encoding:NSUTF8StringEncoding error:&error];

	//BOOL writeConfigFileResult = [data writeToFile:defaultConfigFile.path atomically:YES];
	if (!writeConfigFileResult) { LoggerConfig(0, @"Configuration file write with result:%d to path %@, error=%@",writeConfigFileResult,defaultConfigFile,error);}
	else { LoggerConfig(1, @"Save configuration with success to %@", defaultConfigFile);}
	
	return writeConfigFileResult;
}



+ (NSString*)generateJSON:(id)object {
	NSError *writeError = nil;
	
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&writeError];
	
	NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
	//LoggerConfig(1, @"Generate JSON=%@",jsonString);
	return jsonString;
}

- (BOOL) loadConfiguration {
	BOOL success = false;
	NSString * filePath = [ConfigurationManager configurationFile];
	BOOL configExist = [FileManager isFileExistAtPath:[NSURL fileURLWithPath:filePath]];
	
	LoggerConfig(1, @"IsConfigurationFileExist %@ ? answer=%d", filePath, configExist);
	if (configExist) {
		
		@try {
			success = [self readConfigurationWithFile:filePath];
			
			if (!success) {
				LoggerConfig(2, @"Loading configuration failure with path %@", filePath);
			}
		}
		@catch (NSException *exception) {
			LoggerConfig(2, @"Loading configuration failure with path %@ - %@", filePath,exception);
		}
	}
    
    NSString * aapt = [AndroidManager findAAPTFromAndroidRootFolder:[ConfigurationManager sharedManager].sdkAndroid];
    [ConfigurationManager sharedManager].aaptTool= [NSURL URLWithString:aapt];

    [self insertDefaultData];
	return success;
}


- (BOOL) readConfigurationWithFile:(NSString*)file {
	
	//NSString* path  = [[NSBundle mainBundle] pathForResource:file ofType:@"json"];
	NSError * error;
	NSString* jsonString = [[NSString alloc] initWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&error];
	if (error !=nil) {
		LoggerError(0, @"Can't find configuration file %@ - error %@", file, error);
		return NO;
	}
	
	NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
	
	NSError *jsonError;
	id allKeys = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&jsonError];
	if (jsonError!=nil) {
		LoggerError(0, @"Can't parse configuration file %@ - error %@", file, jsonError);

		return NO;
	}
	
	//GENERAL
	NSArray * generalSettingDict = [allKeys objectForKey:kKeyGeneralSettings];

	NSNumber * archiveScan = [generalSettingDict valueForKey:kKeyAutomaticArchiveScan];
	if (archiveScan != nil) {
		self.isAutoScanArchiveEnabled = [archiveScan boolValue];
	}
	
	NSNumber * openBuild = [generalSettingDict valueForKey:kKeyAutomaticOpenBuildFolderEnabled];
	if (openBuild != nil) {
		self.isAutomaticOpenBuildFolderEnabled = [openBuild boolValue];
	}
	
	NSNumber * clean = [generalSettingDict valueForKey:kKeyCleanAfterBuildEnabled];
	if (clean != nil) {
		self.isCleanAfterBuildEnabled = [clean boolValue];
	}
	
	NSNumber * outputFolderEnabled = [generalSettingDict valueForKey:kKeyOutputFolderEnabled];
	if (outputFolderEnabled != nil) {
		self.isCustomTemplateFolderEnabled = [outputFolderEnabled boolValue];
	}
	
	NSString * customTemplateFolder = [generalSettingDict valueForKey:kKeyOutputFolder];
	if ( customTemplateFolder== nil || [customTemplateFolder isEqualTo:[NSNull null]] ) {
		self.customTemplateFolder = nil;
		self.isCustomTemplateFolderEnabled = NO;
	}
	else {
		self.customTemplateFolder = [NSURL fileURLWithPath:customTemplateFolder];
	}
	
	NSString * sdkAndroidPathString = [generalSettingDict valueForKey:kKeyAndroidSDKPath];
	if ( sdkAndroidPathString== nil || [sdkAndroidPathString isEqualTo:[NSNull null]] ) {
		self.sdkAndroid = nil;
	}
	else {
		self.sdkAndroid = [NSURL fileURLWithPath:sdkAndroidPathString];
	}
	
	//TEMPLATE
	NSArray * template = [allKeys objectForKey:kKeyTemplate];
	for (NSDictionary * aTemplate in template) {
		TemplateModel * tempModel = [[TemplateModel alloc] initWithDictionary:aTemplate];
		if (!IsEmpty(tempModel)) { // && [tempModel isValid]) {
			LoggerConfig(2, @"aTemplate =%@", aTemplate);

			[self.templateModels addObject:tempModel];
		}
		else {
			LoggerConfig(0, @"KO aTemplate =%@", aTemplate);

		}
	}
	
	//SERVER
	NSArray * serversConfig = [allKeys objectForKey:kKeyServer];
	for (NSDictionary * aServerConfig in serversConfig) {
		
		ServerModel * serverModel = [[ServerModel alloc] initWithDictionary:aServerConfig];
		if (!IsEmpty(serverModel) /*&& [serverModel isValid] */ ) {//TODO: do we need full data… no
			LoggerConfig(2, @"aServerModel=%@",serverModel);
			[self.serverConfigModels addObject:serverModel];
		}
		else {
			LoggerConfig(0, @"KO aServerModel=%@", serverModel);
		}
	}
	
	
	//MAPPING
	NSArray * mapping = [allKeys objectForKey:kKeyMapping];
	for (NSDictionary * aMapping in mapping) {
		
		MappingModel * mappingModel = [[MappingModel alloc] initWithDictionary:aMapping];
		if (!IsEmpty(mappingModel) && [mappingModel isValid]) {
			LoggerConfig(2, @"aMapping=%@",aMapping);
			[self.mappingModels addObject:mappingModel];
		}
		else {
			LoggerConfig(0, @"KO aMapping =%@", aMapping);
		}
	}
	

	NSMutableArray * mappingModelToRemove = [NSMutableArray array];
	//associate the mapping & the template
	for (MappingModel * model in self.mappingModels) {
		model.model = [self templateModelForKey:model.templateKey];
		if (model.model == nil) {
			LoggerError(0, @"Model templateKey %@ not found removing", model.templateKey);
			[mappingModelToRemove removeObject:model];
		}
	}
	
	[self.mappingModels removeObjectsInArray:mappingModelToRemove];
	
	LoggerConfig(1, @"Read %d template and %d mapping", (int) [self.templateModels count], (int)[self.mappingModels count]);

	return YES;
}


- (BOOL) isServerConfigLabelIsUnique:(ServerModel*)model {
	for (ServerModel * currentModel in self.serverConfigModels) {
		if (currentModel != model) {
			if ([currentModel.label isEqualTo:model.label]) return NO;
		}
	}
	
	return YES;
}
- (BOOL) isServerConfigKeyIsUnique:(ServerModel*)model {
    for (ServerModel * currentModel in self.serverConfigModels) {
        if (currentModel != model) {
            if ([currentModel.key isEqualTo:model.key]) return NO;
        }
    }
    
    return YES;
}

- (BOOL) isTemplateConfigLabelIsUnique:(TemplateModel*)model {
    for (TemplateModel * currentModel in self.templateModels) {
        if (currentModel != model) {
            if ([currentModel.label isEqualTo:model.label]) return NO;
        }
    }
    
    return YES;
}

- (BOOL) isTemplateConfigKeyIsUnique:(TemplateModel*)model {
    for (TemplateModel * currentModel in self.templateModels) {
        if (currentModel != model) {
            if ([currentModel.key isEqualTo:model.key]) return NO;
        }
    }
    
    return YES;
}


- (TemplateModel * ) templateModelForKey:(NSString*)key {
	for (TemplateModel * obj in self.templateModels) {
		if ([obj.key isEqualToString:key]) {
			return obj;
		}
	}
	return nil;
}

//Always insert that data
- (void) insertDefaultData {
    //Server
	//Only if ADM mode we insert default configuration at top
	ServerModel * betaServerModel = [[ServerModel alloc] initWithDefaultData];
	if (betaServerModel.isDefaultConfig) {
		[self.serverConfigModels insertObject:betaServerModel atIndex:0];
	}
	
    //Templates
	//Always present
	TemplateModel * defaultTemplateModel = [[TemplateModel alloc] initWithDefaultDataTemplateOne];
	[self.templateModels insertObject:defaultTemplateModel atIndex:0];//insert default config on top
	
	TemplateModel * defaultTemplateModel2 = [[TemplateModel alloc] initWithDefaultDataTemplateTwo];
	[self.templateModels insertObject:defaultTemplateModel2 atIndex:0];//insert default config on top
}

- (TemplateModel *) templateForBundle:(NSString*)bundle {
	for (MappingModel * mapping in self.mappingModels) {
		if ([mapping.bundleId isEqualToString:bundle]) {
			return mapping.model;
		}
		
	}
	return nil;
}



- (ServerModel*) serverModelAtIndex:(NSInteger)index {

	if (index >= 0 && index < [self.serverConfigModels count]) {
		return self.serverConfigModels[index];
	}
	else return nil;
	
	
}

- (TemplateModel*) templateModelAtIndex:(NSInteger)index {
	
	if (index >= 0 && index < [self.templateModels count]) {
		return self.templateModels[index];
	}
	else return nil;
	
}

#pragma mark - Configuration Folder & files


+ (NSString *) stringConfigurationFolder {
	NSString * folder = [NSString stringWithFormat:@"%@/%@",[FileManager preference], kConfigFolder];
	return folder;
}

+ (NSURL*) configurationFolder {
	return [NSURL fileURLWithPath:[ConfigurationManager stringConfigurationFolder]];
}
+ (NSString *) configurationFile {
	return [NSString stringWithFormat:@"%@/%@", [ConfigurationManager stringConfigurationFolder], kConfigJsonFile];
}



#pragma mark - general






#pragma mark - Access template

- (TemplateModel*)templateWithKey:(NSString*)key {
	if (key !=nil && self.templateModels !=nil && [self.templateModels count]>0) {
		for (TemplateModel*model in self.templateModels) {
			if ([model.key isEqualToString:key]) {
				return model;
			}
		}
	}
	return nil;
}


- (ServerModel*)serverConfigWithKey:(NSString*)key {
	LoggerData(3, @"Server config to find=\"%@\"", key);

	if (key !=nil && self.serverConfigModels !=nil && [self.serverConfigModels count]>0) {
		for (ServerModel*model in self.serverConfigModels) {
			LoggerData(3, @"Server config found=%@ - \"%@\"", model.label, model.key);
			if ([model.key isEqualToString:key]) {
				return model;
			}
		}
	}
	return nil;
}


@end
