#import "FileManager.h"

@implementation FileManager




+ (FileManager*)sharedManager {
	static FileManager *sharedMyManager = nil;
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
	}
	
	return self;
}


+ (BOOL) copyFile:(NSURL*)source toURL:(NSURL*)destination error:(NSError**)error {
	FileManager* manager = [FileManager sharedManager];
	
	if ([manager isReadableFileAtPath:source.path] ) {
		BOOL success = [manager copyItemAtPath:source.path toPath:destination.path error:error];
		if (!success) {
			LoggerFile(0, @"Can't copy %@  to %@ - Error = %@",source.path, destination.path, *error);
		}
		return success;
	}
	else {
		LoggerFile(0, @"File source %@ is not readable", source);
	}
	return NO;
}


+ (BOOL) isReadblePath:(NSURL*)source {
	FileManager* manager = [FileManager sharedManager];
	BOOL isReadable = [manager isReadableFileAtPath:source.path];
	return isReadable;
}

+ (BOOL) moveFile:(NSURL*)source toURL:(NSURL*)destination error:(NSError**)error {
	FileManager* manager = [FileManager sharedManager];
	
	if (! [manager isReadableFileAtPath:source.path] ) {
		LoggerFile(0, @"File to move source %@ is not readable", source);
		return NO;
	}
	
	NSURL * destinationForMove = [destination URLByAppendingPathComponent:[source lastPathComponent] isDirectory:YES];
	BOOL success = [manager moveItemAtPath:source.path toPath:destinationForMove.path error:error];
	if (!success) {
		LoggerFile(0, @"Can't move %@  to %@ - Error = %@",source.path, destinationForMove.path, *error);
	}
	return success;
}

//TODO: file manager overrright
- (BOOL) fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error copyingItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL {
	if ([error code] == NSFileWriteFileExistsError) //error code for: The operation couldn’t be completed. File exists
		return YES;
	else {
		LoggerError(0, @"Should proceedAfterError:%@", error);
		return NO;
	}
}

- (BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error copyingItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath{
	if ([error code] == NSFileWriteFileExistsError) { //error code for: The operation couldn’t be completed. File exists
		return YES;
	}
	else {
		LoggerError(0, @"Should proceedAfterError:%@", error);
		return NO;
	}
}


- (BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error movingItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL {
	if ([error code] == NSFileWriteFileExistsError) { //error code for: The operation couldn’t be completed. File exists
		return YES;
	}
	else {
		LoggerError(0, @"Should proceedAfterError:%@", error);
		return NO;
	}
}


- (BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error movingItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath {
	if ([error code] == NSFileWriteFileExistsError) { //error code for: The operation couldn’t be completed. File exists
		return YES;
	}
	else {
		LoggerError(0, @"Should proceedAfterError:%@", error);
		return NO;
	}
}



+ (BOOL) openURL:(NSURL*)url {
	return [[NSWorkspace sharedWorkspace] openURL:url];
}


//create folder without the intermediate directories
+ (BOOL) createFolder:(NSURL *)directoryURL {
	return [FileManager createFolder:directoryURL intermediateCreation:NO error:nil];
}


+ (BOOL) createFolder:(NSURL *)directoryURL intermediateCreation:(BOOL)intermediate error:(NSError**)error {
	BOOL isDir;
	
	NSFileManager *fileManager = [FileManager sharedManager];
	
	if(![fileManager fileExistsAtPath:[directoryURL path] isDirectory:&isDir]) {
		if (![fileManager createDirectoryAtURL:directoryURL withIntermediateDirectories:intermediate attributes:nil error:error]) {
			LoggerError(0,@"Error: Create folder failed %@ %@", directoryURL, *error);
			return NO;
		}
		else {
			LoggerFile(2,@"Created folder succeded %@", directoryURL);
			return YES;
		}
	}
	return YES;
}


//+ (NSURL*) createFolder:(NSString *)name inFolder:(NSString *)rootFolder {
//	NSURL * pathURL = [NSURL fileURLWithPath:rootFolder];
//	
//	if (pathURL!=nil && [FileManager isFileExist:pathURL]) {
//		NSURL * targetPath = [pathURL  URLByAppendingPathComponent:name isDirectory:YES];
//		NSError * error = nil;
//		BOOL result = [[NSFileManager defaultManager] createDirectoryAtURL:pathURL withIntermediateDirectories:YES attributes:nil error:&error];
//		if (result && !error) {
//			LoggerFile(3,@"createFolder %@ with success=%@", targetPath);
//			return targetPath;
//		}
//		else {
//			LoggerFile(0,@"createFolder %@ error %@", name, error );
//		}
//	}
//	
//	return nil;
//}

+ (BOOL) isFileExistAtPath:(NSURL *)pathURL {
	NSFileManager *fileManager = [FileManager sharedManager];
	BOOL isDir;
	
	return [fileManager fileExistsAtPath:[pathURL path] isDirectory:&isDir];
}


+ (BOOL) isURLDirectory:(NSURL*)url {
	NSNumber *isDirectory;
	
	// this method allows us to get more information about an URL.
	// We're passing NSURLIsDirectoryKey as key because that's the info we want to know.
	// Also, we pass a reference to isDirectory variable, so it can be modified to have the return value
	BOOL success = [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
	
	// If we could read the information and it's indeed a directory
	if (success && [isDirectory boolValue] ) {
		return YES;
	}
	
	return NO;
}

+ (NSString *) temporaryFolder {
	return [NSTemporaryDirectory() stringByAppendingString:kMainTemporaryFolder];
}


+ (NSString *) home {
	return NSHomeDirectory();
	//return [[[NSProcessInfo processInfo] environment] objectForKey:@"HOME"];
}

+ (NSString *) library {
	return [NSString stringWithFormat:@"%@/Library/", [FileManager home] ];
}

+ (NSString *) preference {
	return [NSString stringWithFormat:@"%@/Library/Preferences/", [FileManager home] ];
}


+ (NSString *) desktop {
	return [NSString stringWithFormat:@"%@/Desktop/", [FileManager home] ];
}

//we should move this methods
+ (BOOL) isIPA:(NSURL*) url {
	if ([[url lastPathComponent] hasSuffix:kIOSIPAExtension]) {
		return YES;
	}
	return NO;
}

+ (BOOL) isXCarchive:(NSURL*) url {
	//NSLog(@"last = %@ - %@",url, [url lastPathComponent] );
	if ([[url lastPathComponent] hasSuffix:kIOSXCArchiveExtension]) {
		return YES;
	}
	return NO;
}

+ (BOOL) isAndroidFile:(NSURL*) url {
	//NSLog(@"last = %@ - %@",url, [url lastPathComponent] );
	if ([[url lastPathComponent] hasSuffix:kAndroidPackageExtension]) {
		return YES;
	}
	return NO;
}

+ (NSURL*) createTempFolderPreview {
	//return [FileManager createTempFolderWithFolderName:kTempPreviewFolderName];
	NSError * error = nil;
	NSString * emptyPath = [[FileManager temporaryFolder] stringByAppendingPathComponent:kTemporaryPreviewSubFolder];
	NSURL * pathURL = [NSURL fileURLWithPath:emptyPath];
	
	BOOL result = [[FileManager sharedManager] createDirectoryAtURL:pathURL withIntermediateDirectories:YES attributes:nil error:&error];
	if (result && !error) {
		LoggerFile(3,@"createTempFolder with success=%@", emptyPath);
		return pathURL;
	}
	else {
		LoggerFile(0,@"createTempFolder error %@", error );
	}

	return nil;
}

+ (NSURL*) createTempFolderWithFolderName:(NSString *)folderName {
	
	NSString * emptyPath = [FileManager pathForTemporaryFileWithPrefix:folderName];
	NSURL * pathURL = [NSURL fileURLWithPath:emptyPath];
	
	if (pathURL!=nil) {
		NSError * error = nil;
		BOOL result = [[FileManager sharedManager] createDirectoryAtURL:pathURL withIntermediateDirectories:YES attributes:nil error:&error];
		if (result && !error) {
			LoggerFile(3,@"createTempFolder with success=%@", emptyPath);
			return pathURL;
		}
		else {
			LoggerFile(0,@"createTempFolder error %@", error );
		}
	}
	
	return nil;
}

//@param prefix to add can be nil
//@return prefix-UniqueID
+ (NSString *)pathForTemporaryFileWithPrefix:(NSString *)prefix {
	NSString *  result;
	CFUUIDRef   uuid;
	CFStringRef uuidStr;
	
	uuid = CFUUIDCreate(NULL);
	assert(uuid != NULL);
	
	uuidStr = CFUUIDCreateString(NULL, uuid);
	assert(uuidStr != NULL);
	
	NSString * pathComponent = nil;
	if (!IsEmpty(prefix)) {
		pathComponent = [NSString stringWithFormat:@"%@-%@", prefix, uuidStr];
	}
	else {
		pathComponent = [NSString stringWithFormat:@"%@", uuidStr];
	}
	result = [[FileManager temporaryFolder] stringByAppendingPathComponent:pathComponent];
	assert(result != nil);
	
	CFRelease(uuidStr);
	CFRelease(uuid);
	
	return result;
}


+ (NSString *) absolutePathFromHomeWithPath:(NSString*)path {
	NSURL *homeURL = [NSURL URLWithString:NSHomeDirectory()];
	NSURL * contactURL = [homeURL URLByAppendingPathComponent:path];
	return [contactURL absoluteString];
}

+ (BOOL) removeFile:(NSURL*)path  withError:(NSError**) error {
	NSFileManager *manager = [FileManager sharedManager];
	return [manager removeItemAtPath:[path path] error:error];
}


//+ (NSString *)readableSizeOfFile:(NSString *)filePath {
//	NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
//	NSInteger fileSize = [[fileAttributes objectForKey:NSFileSize] longLongValue];
//	NSString *fileSizeStr = [NSByteCountFormatter stringFromByteCount:fileSize countStyle:NSByteCountFormatterCountStyleFile];
//	return fileSizeStr;
//}
//
//+ (unsigned long long) sizeOfFile:(NSString *)filePath {
//	NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
//	return [[fileAttributes objectForKey:NSFileSize] longLongValue];
//}


+ (NSString*) readableSizeForPath:(NSString *)path {
	unsigned long long size = [FileManager sizeWithPath:path];
	NSString *folderSizeStr = [NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleFile];
	return folderSizeStr;
}

+ (unsigned long long)sizeWithPath:(NSString *)path {
	if (IsEmpty(path)) return 0;
	
	NSFileManager *fm = [FileManager sharedManager];;
	NSArray *filesArray = [fm subpathsOfDirectoryAtPath:path error:nil];
	unsigned long long fileSize = 0;
	
	NSError *error;

	
	//if folder
	if ([filesArray count]>0) {
		for (NSString *fileName in filesArray) {
			error = nil;
			NSDictionary *fileAttributes = [fm attributesOfItemAtPath:[path stringByAppendingPathComponent:fileName] error:&error];
			if (!error) {
				fileSize += [fileAttributes fileSize];
				//LoggerData(0,@"fileSize=%llu",fileSize);
			}else{
				NSLog(@"ERROR: %@", error);
			}
		}
	}
	else {//if a file
		NSDictionary *fileAttributes = [fm attributesOfItemAtPath:path error:&error];
		if (!error) {
			fileSize += [fileAttributes fileSize];
			//LoggerData(0,@"fileSize=%llu",fileSize);
		}else{
			NSLog(@"ERROR: %@", error);
		}
	}
	
	return fileSize;
}

+ (NSDate*) creationDateForPath:(NSString*)path {
	NSError * error;
	NSDictionary* fileAttribs = [[FileManager sharedManager] attributesOfItemAtPath:path error:&error];
	NSDate *date = [fileAttribs objectForKey:NSFileCreationDate]; //or NSFileModificationDate
	if (error !=nil) {
		LoggerError(0, @"creationDateForPath error %@ for path %@", error, path);
	}
 return date;
}

+ (NSDate*) modificationDateForPath:(NSString*)path {
	NSDictionary* fileAttribs = [[FileManager sharedManager] attributesOfItemAtPath:path error:nil];
	NSDate *date = [fileAttribs objectForKey:NSFileModificationDate];
 return date;
}


//TODO: move in a image manipulation manager/helper
//new way : http://stackoverflow.com/questions/5264993/resize-and-save-nsimage
+ (BOOL) saveImageFromImagePath:(NSURL *)imageURL withScale:(float)scale toURL:(NSURL *)targetURL {
	LoggerApp(4,@"Converting : %@ to %@ with scale %.3f", imageURL, targetURL, scale);
	NSImage *sourceImage = [[NSImage alloc]initWithContentsOfURL:imageURL];
	
	NSInteger originalWidth = 0;
	NSInteger originalHeight = 0;
	
	//http://stackoverflow.com/questions/9264051/nsimage-size-not-real-size-with-some-pictures
	NSArray * imageReps = [sourceImage representations];
	for (NSImageRep * imageRep in imageReps) {
		if ([imageRep pixelsWide] > originalWidth) originalWidth = [imageRep pixelsWide];
		if ([imageRep pixelsHigh] > originalHeight) originalHeight = [imageRep pixelsHigh];
	}
	//LoggerApp(4,@"original image size : %ld %ld", (long)originalWidth, (long)originalHeight);
	
	//make it work on mac retina :p
	//CGFloat screenScale = [[NSScreen mainScreen] backingScaleFactor];
	
	//NSRect sourceRect = NSMakeRect(0, 0, sourceImage.size.width, sourceImage.size.height);
	float scaledWidth = originalWidth*scale;
	float scaledHeight = originalHeight*scale;
	
	NSRect targetRect = NSMakeRect(0, 0, scaledWidth, scaledHeight);
	//LoggerApp(4,@"scaled image size : %f %f", targetRect.size.width, targetRect.size.height);
	
	NSImageView* kView = [[NSImageView alloc] initWithFrame:targetRect];
	[kView setImageScaling:NSImageScaleProportionallyUpOrDown];
	[kView setImage:sourceImage];
	
	
	NSRect kRect = kView.frame;
	NSBitmapImageRep* kRep = [kView bitmapImageRepForCachingDisplayInRect:kRect];
	[kView cacheDisplayInRect:kRect toBitmapImageRep:kRep];
	
	NSData* kData = nil;
	if ([[imageURL path] containsString:@".jpeg"] || [[imageURL path] containsString:@".jpg"]) {
        kData = [kRep representationUsingType:NSJPEGFileType properties:@{}];
	}
	else if([[imageURL path] containsString:@".png"]) {
        kData = [kRep representationUsingType: NSPNGFileType properties: @{}];
	}
	return [kData writeToFile:[targetURL path] atomically:NO];
}



+ (BOOL) saveImage:(NSImage *)sourceImage withScale:(float)scale toURL:(NSURL *)targetURL {
	//LoggerApp(4,@"Converting to %@ with scale %.3f", targetURL, scale);
	
	NSInteger originalWidth = 0;
	NSInteger originalHeight = 0;
	
	//http://stackoverflow.com/questions/9264051/nsimage-size-not-real-size-with-some-pictures
	NSArray * imageReps = [sourceImage representations];
	for (NSImageRep * imageRep in imageReps) {
		if ([imageRep pixelsWide] > originalWidth) originalWidth = [imageRep pixelsWide];
		if ([imageRep pixelsHigh] > originalHeight) originalHeight = [imageRep pixelsHigh];
	}
	//LoggerApp(4,@"original image size : %ld %ld", (long)originalWidth, (long)originalHeight);
	
	//make it work on mac retina :p
	//CGFloat screenScale = [[NSScreen mainScreen] backingScaleFactor];
	
	//NSRect sourceRect = NSMakeRect(0, 0, sourceImage.size.width, sourceImage.size.height);
	float scaledWidth = originalWidth*scale;
	float scaledHeight = originalHeight*scale;
	
	NSRect targetRect = NSMakeRect(0, 0, scaledWidth, scaledHeight);
	//LoggerApp(4,@"scaled image size : %f %f", targetRect.size.width, targetRect.size.height);
	
	NSImageView* kView = [[NSImageView alloc] initWithFrame:targetRect];
	[kView setImageScaling:NSImageScaleProportionallyUpOrDown];
	[kView setImage:sourceImage];
	
	
	NSRect kRect = kView.frame;
	NSBitmapImageRep* kRep = [kView bitmapImageRepForCachingDisplayInRect:kRect];
	[kView cacheDisplayInRect:kRect toBitmapImageRep:kRep];
	
	NSData* kData = nil;
	/*if ([[imageURL path] containsString:@".jpeg"] || [[imageURL path] containsString:@".jpg"]) {
		kData = [kRep representationUsingType:NSJPEGFileType properties:nil];
	}
	else if([[imageURL path] containsString:@".png"]) {
		*/
    kData = [kRep representationUsingType: NSPNGFileType properties: @{}];
	//}
	return [kData writeToFile:[targetURL path] atomically:NO];
}


+ (BOOL) cleanTemporaryData {
    NSString * pathFolder = [FileManager temporaryFolder];
    NSURL * tempFolder = [NSURL fileURLWithPath:pathFolder];
    NSError * error;
    BOOL cleaning = [FileManager removeFile:tempFolder withError:&error];
    return cleaning;
}


@end
