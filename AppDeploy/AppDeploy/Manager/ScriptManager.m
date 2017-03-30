#import "ScriptManager.h"
#import "ServerModel.h"
#import "ConfigurationManager.h"

@implementation ScriptManager
#define delegate ((AppDelegate *)[NSApplication sharedApplication].delegate)

-(void) commandLineSupport {
    BOOL isFTP = NO;
    BOOL isFindLastArchive = NO;
    BOOL isProwl = NO;
    BOOL isHipchat = NO;
    BOOL isHelp = NO;
    BOOL hasFile = NO;
    NSString * identifier = nil;
    NSString * templatekey = nil;
    NSString * serverkey = nil;
    NSString * buildNumber = nil;
    NSString * outputPath = nil;
    
    NSURL * pathURL = nil;
    NSMutableDictionary * integrationContinuousKey = [NSMutableDictionary dictionary];
    
    NSArray *commandLineArguments = [[NSProcessInfo processInfo] arguments];
    if (commandLineArguments && [commandLineArguments count] > 0) {
        NSString * path=nil;// = commandLineArguments[1];
        
        for (NSString * arg in commandLineArguments) {
            LoggerApp(2, @"Arg=%@", arg);
            
            if ([@"--help" isEqualToString:arg]) {
                self.commandLineMode = YES;
                isHelp = YES;
            }
            else if ([arg containsString:@"--file"]) {
                self.commandLineMode = YES;
                //NSArray * pathWithParameter = [arg componentsSeparatedByString:@"--archivepath="];
                path = [arg  stringByReplacingOccurrencesOfString:@"--file=" withString:@""];
                
                if (IsEmpty(path)) {
                    LoggerApp(0, @"Invalide path paramater : \"%@\"", arg);
                    [self commandLineHelp];
                    exit(SHELL_FAILURE_CODE);
                }
                else {
                    pathURL = [NSURL fileURLWithPath:path];
                    hasFile = YES;
                }
            }
            else if ([@"--findLastArchive" isEqualToString:arg]) {
                self.commandLineMode = YES;
                isFindLastArchive = YES;
            }
            else if ([@"--prowl" isEqualToString:arg]) {
                self.commandLineMode = YES;
                isProwl = YES;
            }
            else if ([@"--hipchat" isEqualToString:arg]) {
                self.commandLineMode = YES;
                isHipchat = YES;
            }
            else if ([arg hasPrefix:@"--identifier"]) {
                self.commandLineMode = YES;
                identifier = [arg  stringByReplacingOccurrencesOfString:@"--identifier=" withString:@""];
            }
            else if ([arg hasPrefix:@"--templatekey"]) {
                self.commandLineMode = YES;
                templatekey = [arg  stringByReplacingOccurrencesOfString:@"--templatekey=" withString:@""];
                LoggerData(3,@"****** Debug templatekey=%@", templatekey);
            }
            else if ([arg hasPrefix:@"--serverkey"]) {
                self.commandLineMode = YES;
                serverkey = [arg  stringByReplacingOccurrencesOfString:@"--serverkey=" withString:@""];
                LoggerApp(3,@"****** Debug serverkey=%@", serverkey);
            }
            else if ([@"--ftp" isEqualToString:arg]) {
                self.commandLineMode = YES;
                isFTP = YES;
            }
            else if ([arg hasPrefix:@"--build_number"]) {
                self.commandLineMode = YES;
                buildNumber = [arg  stringByReplacingOccurrencesOfString:@"--build_number=" withString:@""];
            }
            else if ([arg hasPrefix:@"--export"]) {
                self.commandLineMode = YES;
                outputPath = [arg  stringByReplacingOccurrencesOfString:@"--export=" withString:@""];
            }
            //Handle the ic_KEY=VALUE param from integration continues to easily add and remove params
            else if ([arg hasPrefix:@"--ic_"]) {
                self.commandLineMode = YES;
                LoggerData(1,@"****** Handeling arg=%@", arg);
                NSError *regexError = nil;
                NSRegularExpressionOptions options = 0;
                NSString *pattern = @"--ic_.*=";
                NSString *substitution = @"";
                
                NSRegularExpression *expressionValue = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&regexError];
                
                NSRange range = NSMakeRange(0,[arg length]);
                NSString *value = [expressionValue stringByReplacingMatchesInString:arg options:0 range:range withTemplate:substitution];
                
                NSString *pattern2 = @"--ic_(.*)=(.*)";
                NSString *substitution2 = @"$1";
                
                NSRegularExpression *expressionKey = [NSRegularExpression regularExpressionWithPattern:pattern2 options:options error:&regexError];
                
                NSRange range2 = NSMakeRange(0,[arg length]);
                NSString *key = [expressionKey stringByReplacingMatchesInString:arg options:0 range:range2 withTemplate:substitution2];
                
                if (!IsEmpty(key)) {
                    [integrationContinuousKey setValue:value forKey:key];
                }
            }
            
        }
        
        LoggerData(1, @"Integraction continuous Data %@", integrationContinuousKey);
        
        
        if (self.commandLineMode) {
            
            if (isHelp ) {
                [self commandLineHelp];
                exit(1);
            }
            
            if (!hasFile && !isFindLastArchive) {
                LoggerApp(0, @"Missing parameters");
                [self commandLineHelp];
                exit(1);
            }
            
            
            //if identifier not provided take the filename
            if (IsEmpty(identifier)) {
                identifier = pathURL.lastPathComponent;
            }
            
            ABApplication * app = nil;
            //**************************** AUTO SEARCH XCARCHIVE ****************************
            if (isFindLastArchive) {
                app = [IOSManager findLastArchive];
                
                if (IsEmpty(app)) {
                    LoggerApp(0, @"****** Last archive not found ******");
                    
                    exit(SHELL_FAILURE_CODE);
                }
                else {
                    LoggerApp(1, @"****** Last archive found %@ ******", [app.xcarchive relativeString]);
                }
                
            }
            //**************************** READ FILE and init ABApplication object ****************************
            else {
                app = [MainNSWindow handleFileIfSupported:path];
            }
            
            if (!app) {
                LoggerApp(0, @"Path provided is not valid %@", identifier);
                [ABApplication notifyServicesForApplication:app withIdentifier:identifier buildResult:NO prowl:isProwl hipchat:isHipchat];
                exit(SHELL_FAILURE_CODE);
            }
            
            [app.icVariablesDict setValuesForKeysWithDictionary:integrationContinuousKey];
            app.build_number=buildNumber;
            
            //**************************** HANDLE BUILD ****************************
            //Loading template configuration
            if (IsEmpty(templatekey)) {
                templatekey = kDefaultTemplateModel1Key;
                LoggerApp(1, @"Setting default template %@", templatekey);
                
            }
            app.templateConfig = [[ConfigurationManager sharedManager] templateWithKey:templatekey];
            if (IsEmpty(app.templateConfig)) {
                LoggerApp(0, @"TemplateConfig is invalid %@", templatekey);
                [ABApplication notifyServicesForApplication:app withIdentifier:identifier buildResult:NO prowl:isProwl hipchat:isHipchat];
                exit(SHELL_FAILURE_CODE);
            }
            
            //Loading server configuration
            if (IsEmpty(serverkey)) {
                serverkey = nil;
                LoggerApp(0, @"serverkey not defined");
            }
            else {
                app.serverConfig = [[ConfigurationManager sharedManager] serverConfigWithKey:serverkey];
                if (IsEmpty(app.serverConfig)) {
                    LoggerApp(0, @"serverkey is invalid for %@", serverkey);
                    [ABApplication notifyServicesForApplication:app withIdentifier:identifier buildResult:NO prowl:isProwl hipchat:isHipchat];
                    exit(SHELL_FAILURE_CODE);
                }
                LoggerApp(1, @"serverkey defined is %@", app.serverConfig);
            }
            
            
            
            //IMAGE RECOVERY FROM ARCHIVE
            //TODO:quickfix. TO factorize
            NSData * imageData=nil;
            if (app.isIpa && !IsEmpty(app.iconeName)) {
                imageData = [IOSManager imageFromIPAFile:app.ipaURL withFileName:app.iconeName];
            }
            else if (app.isApk) {
                imageData = [AndroidManager imageDataFromAPK:app.xcarchive withFileName:app.iconeName];
            }
            
            if (imageData !=nil) {
                NSImageView * imageView = [[NSImageView alloc] init];
                imageView.image = [[NSImage alloc] initWithData:imageData];
                app.appIcone = imageView;
            }
            
            
            NSURL * buildFolder = nil;
            if (app!=nil) {
                TaskManager * task = [[TaskManager alloc]init];
                buildFolder = [app handleBuildWithTask:&task];
                
                if (!IsEmpty(buildFolder)) {
                    LoggerApp(1, @"Build Success");
                    #ifdef DEBUG
                    if (kScriptOpenTemplateAppFolder && [FileManager isFileExistAtPath:buildFolder]) {
                     //  [[NSWorkspace sharedWorkspace] openFile:buildFolder.path];
                    }
					#endif
                }
                else {
                    LoggerApp(0, @"Handle build Failure");
                    [ABApplication notifyServicesForApplication:app withIdentifier:identifier buildResult:NO prowl:isProwl hipchat:isHipchat];
                    exit(SHELL_FAILURE_CODE);
                }
            }
            
            //**************************** DEPLOY BUILD ****************************
            NSURL * urlToApp = nil;
            if (isFTP) {
                
                NSString * errorString = nil;
                urlToApp = [ABApplication pushApplication:app withBuildFolder:buildFolder errorString:&errorString FTPManager:nil];
                if (IsEmpty(urlToApp)) {
                    LoggerApp(0, @"****** Upload issue ******");
                    exit(SHELL_FAILURE_CODE);
                }
                else {
                    //[self notificationForApp:app buildType:BUILD_TYPE_UPLOAD withbuildResult:YES];
                    LoggerApp(1, @"Upload successfull");
                }
            }
            
            //we move it (after ftp)
            if (!IsEmpty(buildFolder)) {
                urlToApp = [ABApplication moveTemplateToOutputForApp:app withFolderDestination:app.buildFolderPath];
                if (IsEmpty(urlToApp)) {
                    LoggerApp(0, @"****** App deploy to download folder issue ******");
                    exit(SHELL_FAILURE_CODE);
                }
                else {
                    //    [self notificationForApp:app buildType:BUILD_TYPE_UPLOAD withbuildResult:YES];
                    LoggerApp(1, @"App deploy to download folder successfull");
                }
            }
            
            //**************************** Export data to .proprerties files ****************************

            //Export app info to a file
            [self exportAppInfo:app toFile:outputPath];
            
            //**************************** Notification ****************************

            [ABApplication notifyServicesForApplication:app withIdentifier:identifier buildResult:!IsEmpty(urlToApp) prowl:isProwl hipchat:isHipchat];
            LoggerApp(4, @"App can be download at url=\"%@\"", app.urlToApp);
            
            LoggerApp(1, @"****** Action successed ******");
            
            //Success
            exit(SHELL_SUCCESS_CODE);
        }
    }
}

- (void) exportAppInfo:(ABApplication*)app toFile:(NSString*)outputPath {
    
    if (IsEmpty(outputPath)) return;
    NSMutableString * data = [NSMutableString stringWithFormat:@"%@os:%@\n", kICConsantPrefix, app.plateforme];
    
    if (app.type == ApplicationTypeIOS) {
        //[data appendFormat:@"architecture:%@\n",app.architecture];
    }
    else if (app.type == ApplicationTypeAndroid) {
        //specific parameter
        NSString * platform = [app.icVariablesDict valueForKey:@"PLATFORM_BUILD_VERSION_NAME"];
        if (!IsEmpty(platform)) {
            [data appendFormat:@"%@platform_build:%@\n",kICConsantPrefix, platform];
        }
    }
    [data appendFormat:@"%@name:%@\n",kICConsantPrefix, app.name];
    [data appendFormat:@"%@sdk:%@\n",kICConsantPrefix, app.sdk];
    [data appendFormat:@"%@osminsupport:%@\n",kICConsantPrefix, app.minimumOS];
    [data appendFormat:@"%@build:%@\n",kICConsantPrefix, app.versionTechnical ];
    [data appendFormat:@"%@version:%@\n",kICConsantPrefix, app.versionFonctionnal ];
    [data appendFormat:@"%@size:%@\n",kICConsantPrefix, app.destFileSize];
    [data appendFormat:@"%@bundleidentifier:%@\n",kICConsantPrefix, app.bundleIdentifier];
    [data appendFormat:@"%@url:%@\n",kICConsantPrefix, app.urlToApp];
    [data appendFormat:@"%@binaryurl:%@\n",kICConsantPrefix, [app binaryUrlWithManifestURL:NO]];
    
    NSError * error = nil;
    [data writeToFile:outputPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error !=nil) {
        LoggerApp(0, @"Cannot write to %@ - %@", outputPath, error);
    }
}

- (void) commandLineHelp {
    LoggerApp(1, @"\nAppDeploy command line usage :\n" \
              "--help\n"\
              
              "Archive to load\n"\
              "--file : the path to the ipa, xcarchive or apk\n" \
              "--findLastArchive : find the last archive from your xcode archive (use with cautiousness)\n"\
              
              "Configuration"
              "--templatekey	: the key of the template to use (defaut is %@)"
              "--serverkey		: the key of the server config to use"
              
              "--ftp : push the app to the ftp server, by default juste generating the template\n\n"\
              
              "Notification\n"\
              "--prowl : send a prowl alert when push success\n"\
              "--hipchat : send a hipchat alert when push success\n"\
              "" \
              "Integration continue tools" \
              "--build_number=xx : use the build number provided and maintened by the integration continue has a subfolder instead of using the technical build number (will avoid overwrite)\n"
              "--ic_XXXX=value  : display argument that you can provide to be dynamically injected in your template.\n"
              "--export : export data with format key:value about the build (version, build version, export url, os)\n", kScriptDefaultConfig
              );
}


@end
