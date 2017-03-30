//For development settings
#ifdef DEBUG
	#define kEnableProwl				YES
	#define kHipChatEnabled				YES
	#define kCleanTempFolderAtStartup	NO
#else
	#define kEnableProwl				YES
	#define kHipChatEnabled				YES
	#define kCleanTempFolderAtStartup	YES
#endif
#define kPlaySound YES

//Configuration
#define kConfigFolder 					@"com.atelierdumobile.AppDeploy"
#define kConfigJsonFile 				@"config.json"

//Temporary Folders
#define kFolderPrefixTempZipExtract 	@"TEMP_ZIP_Extract"
#define kMainTemporaryFolder 			@"/APPDEPLOY_TEMP/"
#define kTemporaryPreviewSubFolder 		@"AppDeployPreview"
#define TEMP_FOLDER_PREFIX 				@"BUILD_"

//File detection latency
#define ARCHIVE_LATENCY					((NSTimeInterval)4.0)

//Terminal
#define kTerminalPath 					@"/Applications/Utilities/Terminal.app"
#define kCommandLineHelpOutput 			@"/Contents/MacOS/AppDeploy --help"
#define SHELL_SUCCESS_CODE 				0
#define SHELL_FAILURE_CODE				1
#define kICConsantPrefix				@"appdeploy_"

//IOS
#define kPlayloadFolder 				@"Payload/"
#define kEmbeddedProvisionningFileName 	@"embedded.mobileprovision"
#define kArchiveFolderPath 				@"/Library/Developer/Xcode/Archives"
#define kDefaultProvisioningName 		@""
#define kIOSPlateforme 					@"ios"
#define kIOSXCArchiveExtension 			@".xcarchive"
#define kIOSIPAExtension 				@".ipa"

//Android
#define ANDROID_LAUNCHER_FILE_NAME 		@"ic_launcher.png"
#define kAaptToolName 					@"aapt"
#define kPlistFileName  				@"Info.plist"
#define KProductFolder 					@"Products"
#define kAndroidPlateforme 				@"Android"
#define kAndroidPackageExtension 		@".apk"


//Template
#define kAndroidSuffix 					@"_android"
#define kIOSSuffix 						@"_ios"

//Template 1
#define kDefaultTemplateModel1File 		@"defaultCompany.html"
#define kDefaultTemplateModel1Label		@"🔒 Builtin - logo company"
#define kDefaultTemplateModel1Logo		@"http://atelierdumobile.com/images/companyLogo.png"
#define kDefaultTemplateModel1Key		@"defaultCompany"

#define kDefaultTemplateModel2File 		@"defaultAppIcone.html"
#define kDefaultTemplateModel2Label		@"🔒 Builtin - app icone"
#define kDefaultTemplateModel2Logo		@""
#define kDefaultTemplateModel2Key		@"defaultAppIcone"


//Network
#define kNotificationUploadProgress 	@"NotificationUploadProgress"
//#define kTimeoutConnection 15

//Scripting
#define kScriptDefaultConfig 			kDefaultTemplateModel1Key
#define kScriptOpenTemplateAppFolder	YES
