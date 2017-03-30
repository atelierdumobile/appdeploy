#import <Foundation/Foundation.h>
#import "TemplateModel.h"
#import "MappingModel.h"
#import "ServerModel.h"
#import "FileManager.h"


@interface ConfigurationManager : NSObject

@property (nonatomic, strong) NSMutableArray * templateModels;
@property (nonatomic, strong) NSMutableArray * mappingModels;
@property (nonatomic, strong) NSMutableArray * serverConfigModels;


@property (nonatomic) BOOL isAutoScanArchiveEnabled;
@property (nonatomic) BOOL isCleanAfterBuildEnabled;
@property (nonatomic) BOOL isCustomTemplateFolderEnabled;
@property (nonatomic) BOOL isAutomaticOpenBuildFolderEnabled;
@property (strong) NSURL* customTemplateFolder;
@property (strong) NSURL* aaptTool;
@property (strong) NSURL* sdkAndroid;


+ (ConfigurationManager*)sharedManager;
- (BOOL) readConfigurationWithFile:(NSString*)file;
- (TemplateModel *) templateForBundle:(NSString*)bundle;
- (BOOL) loadConfiguration;


- (BOOL) saveConfiguration;


//ServerModel
- (ServerModel*) serverModelAtIndex:(NSInteger)index;
- (BOOL) isServerConfigLabelIsUnique:(ServerModel*)model;
- (BOOL) isServerConfigKeyIsUnique:(ServerModel*)model;
- (BOOL) isTemplateConfigLabelIsUnique:(TemplateModel*)model;
- (BOOL) isTemplateConfigKeyIsUnique:(TemplateModel*)model;
- (ServerModel*)serverConfigWithKey:(NSString*)key;

//TemplateModel
- (TemplateModel*)templateModelAtIndex:(NSInteger)index;
- (TemplateModel*)templateWithKey:(NSString*)key;


+ (NSURL*) configurationFolder;
+ (NSString *) configurationFile;

//Exposed for unittest
+ (NSString *) stringConfigurationFolder;

@end
