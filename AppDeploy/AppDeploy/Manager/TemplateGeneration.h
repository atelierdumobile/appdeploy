#import <Foundation/Foundation.h>
#import "Preference.h"
#import "ABApplication.h"
#import "TemplateModel.h"

@interface TemplateGeneration : NSObject

+ (NSString *) generateHTMLDownloadPage:(ABApplication *) application
						 withDateFormat:(TemplateDateFormatType)dateFormat
								  error:(NSError**)error;
+ (NSString *) generateHTMLRootRedirectPage:(ABApplication *)application
									  error:(NSError**)error;

+ (BOOL) createTemplateForApplication:(ABApplication*)application
								toURL:(NSURL*)folder
						   binaryMode:(BOOL)isBinaryMode
					versionFolderMode:(BOOL)isVersionFolderMode;
+ (NSURL*) previewTemplateWithTemplate:(TemplateModel*)template application:(ABApplication*)application versioned:(BOOL)isVersionned;
+ (NSURL*) previewTemplateWithFakeApp:(TemplateModel*)template;

@end
