#import <Foundation/Foundation.h>

@interface AndroidManager : NSObject

+ (NSData*) imageDataFromAPK:(NSURL*)apkURL withFileName:(NSString*)imageName;
+ (NSData*) imageDataFromAPK:(NSURL*)apkURL;
+ (BOOL) isAAPTAvailable;
+ (BOOL) parseAPKWithAAPT:(NSURL*)apkFilePath application:(ABApplication*)application aaptPath:(NSURL*)path;
+ (NSString *) findAAPTFromAndroidRootFolder:(NSURL*)path;

@end
