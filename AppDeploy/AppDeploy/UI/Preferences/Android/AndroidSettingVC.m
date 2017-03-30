#import "AndroidSettingVC.h"
#import "TaskManager.h"
#import "ConfigurationManager.h"
#import "FileManager.h"

@interface AndroidSettingVC ()
@property (weak) IBOutlet NSPathControl *sdkAndroidFolder;
@property (strong) IBOutlet NSImageView *buildStatusImage;

@end

@implementation AndroidSettingVC


-(NSString*)identifier{
	return NSStringFromClass(self.class);
}
-(NSImage*)toolbarItemImage{
	return [NSImage imageNamed:@"Android"];
}
-(NSString*)toolbarItemLabel{
	return NSLocalizedString(@"Android", @"XcodeToolbarItemLabel");
}

- (void)awakeFromNib {
    [[self.sdkAndroidFolder cell] setAllowedTypes: [NSArray arrayWithObject: @"public.folder"]];
    NSURL * url = [ConfigurationManager sharedManager].sdkAndroid;
    self.sdkAndroidFolder.URL = url;
    
    [self checkValidAndroidFolderAndAlertUser:NO];
    
}

#pragma mark check


- (NSString *) checkValidAndroidFolderAndAlertUser:(BOOL)isDisplayAlert {
    
    NSString * aaptPathFound = [self checkValidAndroidFolder];
    
    if (IsEmpty(aaptPathFound)&&isDisplayAlert) {
        [self showMessage:@"It appears that the selected folder si not an Android folder. Please select another one."
                withTitle:@"Incorrect SDK Folder"];
    }
    
    if(!IsEmpty(aaptPathFound)) {
        self.buildStatusImage.image = [NSImage imageNamed:@"CheckmarkGreen.png"];
    }
    else {
        self.buildStatusImage.image = [NSImage imageNamed:@"Error.png"];
    }
    return aaptPathFound;
}

- (NSString*) checkValidAndroidFolder {
    BOOL isValidAndroidSDKFolder = YES;
    
    NSURL * path = self.sdkAndroidFolder.URL;
    if (path == nil) isValidAndroidSDKFolder=NO;
    
    NSURL * pathBuildTools = [path URLByAppendingPathComponent:@"build-tools"];
    NSURL * pathPlatformTools = [path URLByAppendingPathComponent:@"platform-tools"];
    
    
    BOOL buildToolsExist = [FileManager isFileExistAtPath:pathBuildTools];
    BOOL plateformToolsExist = [FileManager isFileExistAtPath:pathPlatformTools];
    
    NSString * aaptFinalLine = [AndroidManager findAAPTFromAndroidRootFolder:path];
    
    
    if (isValidAndroidSDKFolder&&buildToolsExist&&plateformToolsExist && !IsEmpty(aaptFinalLine)) {
        return aaptFinalLine;
    }
    else return nil;
}




#pragma check
- (IBAction)changeOutputFolder:(id)sender {
    LoggerData(1, @"URL android sdk = %@",self.sdkAndroidFolder);
    NSString * aapt = [self checkValidAndroidFolderAndAlertUser:YES];
    [ConfigurationManager sharedManager].sdkAndroid= self.sdkAndroidFolder.URL;
    [ConfigurationManager sharedManager].aaptTool = [NSURL URLWithString:aapt];

}

- (IBAction)openAndroidSDKFolder:(id)sender {
    if (!IsEmpty(self.sdkAndroidFolder.URL.path)) {
        [[NSWorkspace sharedWorkspace] openFile:self.sdkAndroidFolder.URL.path];
    }
}

@end
