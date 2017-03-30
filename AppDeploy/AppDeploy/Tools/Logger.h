#import "LoggerClient.h"
#import "LamFunkyHelpers.h"

#ifndef DEBUG
 	#undef LoggerError
	#undef LoggerData
	#undef LoggerModel
	#undef LoggerNetwork
	#undef LoggerView
	#undef LoggerService
	#undef LoggerApp
	#undef LoggerFile
	#undef NSLog

	//#define NSLog(...)                      LogMessageCompat(__VA_ARGS__)
	#define LoggerError(level,...)                NSLog(__VA_ARGS__) //while(0) {}
	#define LoggerApp(level, ...)           	  NSLog(__VA_ARGS__) //NSLog(__VA_ARGS__)
	#define LoggerView(level,...)                 NSLog(__VA_ARGS__)
	#define LoggerService(level,...)              NSLog(__VA_ARGS__)
	#define LoggerModel(level,...)                NSLog(__VA_ARGS__)
	#define LoggerData(level,...)                 NSLog(__VA_ARGS__)
	#define LoggerNetwork(level,...)              NSLog(__VA_ARGS__)
	#define LoggerFile(level,...)                 NSLog(__VA_ARGS__)
	#define LoggerConfig(level,...)               NSLog(__VA_ARGS__)
#endif



#ifdef DEBUG
	#define LoggerConfig(level, ...)           	LogMessageF(__FILE__, __LINE__, __FUNCTION__, @"Config", level, __VA_ARGS__)
	#define LoggerTask(level, ...)           	LogMessageF(__FILE__, __LINE__, __FUNCTION__, @"Tasks", level, __VA_ARGS__)
#else
	#define LoggerConfig(...)                 	while(0) {}
	#define LoggerTask(...)                	 	while(0) {}
#endif
