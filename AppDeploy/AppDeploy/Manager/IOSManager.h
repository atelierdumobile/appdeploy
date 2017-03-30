#import <Foundation/Foundation.h>
#import "FTPManager.h"
#import "FileManager.h"
#import "MainNSWindow.h"
#import "TaskManager.h"

@interface IOSManager : NSObject


+ (ABApplication *) findLastArchive;
+ (NSString *) archiveFolderPath;
+ (NSDictionary*) plistFromIPAFile:(NSURL*)ipaURL;

+ (NSData*) imageFromIPAFile:(NSURL*)ipaURL withFileName:(NSString*)imageName;

+ (BOOL) createIPAWithApplication:(ABApplication *)application
                         toFolder:(NSURL*)emptyFolderPath
                    provisionning:(NSString*)provisionningName
             defaultProvisionning:(NSString*)provisionningByDefault
                         withTask:(TaskManager**)task;
+ (NSDictionary *) createManifest:(ABApplication *) application ;
+ (NSString *) ipaUnzipAndReadCodeSign:(NSURL*)ipaURL withBundle:(NSString*)bundle;
+ (NSURL *) ipaUnzip:(NSURL*)ipaURL withBundle:(NSString*)bundle;
+ (NSURL*) pathToEmbeddedProfileFromArchiveAppFolder:(NSURL*)path;
+ (NSString *) readSecurityContentFromIPA:(NSURL*)ipaURL;
+ (NSURL *) pathToAppFolderFromIpa:(NSURL*)ipaPath bundleName:(NSString*)bundle;
+ (NSDictionary *) fetchEntitlementsInformation:(NSURL*)archiveAppFolder;

@end
