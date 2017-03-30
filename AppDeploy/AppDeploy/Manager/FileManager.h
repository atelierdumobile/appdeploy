@import Foundation;

@interface FileManager : NSFileManager <NSFileManagerDelegate>

+ (FileManager*)sharedManager;

//Creation
+ (BOOL) createFolder:(NSURL *)directoryURL;
+ (BOOL) createFolder:(NSURL *)directoryURL intermediateCreation:(BOOL)intermediate error:(NSError**)error;

+ (NSURL*) createTempFolderWithFolderName:(NSString *)folderName;
+ (NSURL*) createTempFolderPreview;

+ (NSString *) temporaryFolder;//Custom temporary folder to regroup then and facilitate cleaning
+ (NSString *) home;
+ (NSString *) desktop;
+ (NSString *) library;
+ (NSString *) preference;


//Validation
+ (BOOL) isFileExistAtPath:(NSURL *)pathURL;
+ (BOOL) isIPA:(NSURL*) url;
+ (BOOL) isXCarchive:(NSURL*) url;
+ (BOOL) isAndroidFile:(NSURL*) url;
+ (BOOL) isURLDirectory:(NSURL*)url;
+ (NSString *) absolutePathFromHomeWithPath:(NSString*)path;
+ (BOOL) openURL:(NSURL*)url;

//Remove
+ (BOOL) removeFile:(NSURL*)path  withError:(NSError**)error;
+ (BOOL) cleanTemporaryData;

//Copy
+ (BOOL) copyFile:(NSURL*)source toURL:(NSURL*)destination error:(NSError**)error;
+ (BOOL) moveFile:(NSURL*)source toURL:(NSURL*)destination error:(NSError**)error;

+ (BOOL) isReadblePath:(NSURL*)source;

//Size
//+ (unsigned long long) sizeOfFile:(NSString *)filePath;
//+ (unsigned long long)sizeOfFolder:(NSString *)folderPath;

+ (NSString*) readableSizeForPath:(NSString *)path;
+ (unsigned long long)sizeWithPath:(NSString *)path;

+ (NSDate*) creationDateForPath:(NSString*)path;
+ (NSDate*) modificationDateForPath:(NSString*)path;


//Image manipulation TODO move
+ (BOOL) saveImageFromImagePath:(NSURL *)imageURL withScale:(float)scale toURL:(NSURL *)targetURL;
+ (BOOL) saveImage:(NSImage *)sourceImage withScale:(float)scale toURL:(NSURL *)targetURL;

@end
