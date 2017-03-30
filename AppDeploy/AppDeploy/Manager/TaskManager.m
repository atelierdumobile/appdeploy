#import "TaskManager.h"

//http://stackoverflow.com/questions/4911711/cocoa-question-nstask-isnt-working


#define failureStatusCode -666

@interface TaskManager()

@property (strong) NSTask *task;

@end


@implementation TaskManager

#pragma mark Lifecycle
- (void) stopCurrentTask {
	if (self.task != nil) {
		if (self.task.isRunning) {
			LoggerTask(1, @"W - Canceling task");
			[self.task interrupt];
			self.task = nil;
		}
	}
}


#pragma mark Core

//@return int status code
- (int) executeCommand:(NSString *)command
		 withArguments:(NSArray*)arguments
		  outputString:(NSString**)outputString
				 errorString:(NSString**)errorString
  currentDirectoryPath:(NSString*)currentPath
		  environement:(NSDictionary*)environment{
	@try {
		LoggerTask(4,@"Script start");
		
		NSString * workingPath = @"/tmp";
		if (!IsEmpty(currentPath)) {
			workingPath = currentPath;
		}
		
		LoggerTask(3, @"Executing command \"%@\" - with arguments \"%@\" with tmp= \"%@\"", command, arguments, workingPath);
		LoggerTask(1, @"Executing command in terminal with working path %@: %@", workingPath, [self displayCommandLine:command withArguments:arguments]);
		
		if (self.task != nil && self.task.isRunning) {
			LoggerTask(0, @"Task is already running warning !!!!");
		}
		
		NSTask * task = [[NSTask alloc] init];
		self.task = task;
		
		[task setCurrentDirectoryPath:workingPath];
		[task setLaunchPath:command];
		[task setArguments:arguments];
		
		NSDictionary* env = nil;
		if (environment!=nil) {
			env = environment;
		}
		else {
			//Usefull when performing from Xcode
			env = [[NSProcessInfo processInfo] environment];
			LoggerTask(4, @"Environement %@", env);
		}
		[task setEnvironment:env];
		
		NSPipe *outputPipe = [NSPipe pipe];
		[task setStandardInput:[NSFileHandle fileHandleWithNullDevice]];
		[task setStandardOutput:outputPipe];
		
		NSPipe *errorPipe = [NSPipe pipe];
		[task setStandardError:errorPipe];
		
		[task launch];
		
		//task.terminationHandler = ^(NSTask *task) {
		//	LoggerTask(3, @"Ended command \"%@\" - with arguments \"%@\"", command, arguments);
		//};
		
		//check output even if status is successfull
		NSData *outputData = [[outputPipe fileHandleForReading] readDataToEndOfFile];
		NSData *errorData = [[errorPipe fileHandleForReading] readDataToEndOfFile];
		*outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
		
		*errorString = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
		
		[task waitUntilExit];
		
		int status = [task terminationStatus];
		
		if (status == 0) {
			if (!IsEmpty(*errorString)) {
				LoggerTask(0, @"Command success \"%@\" \n\"%@\" with error=\"%@\"", command, *outputString, *errorString);
			}
			else {
				LoggerTask(1, @"Command success \"%@\" \n\"%@\"", command, *outputString);
			}
			return status;
		}
		else {
			LoggerTask(0,@"Command Failed \"%@\" \nResult error=\"%@\"",command,  *errorString);
			return status;
		}
		
	}
	@catch (NSException *exception) {
		LoggerTask(0, @"Problem Running Task: \"%@\"", [exception description]);
	}
	@finally {
		LoggerTask(4,@"Script end");
		self.task = nil;
	}
	
	return failureStatusCode;
}


//default encoding is NSUTF8StringEncoding
- (NSString*) executeCommand:(NSString *)command withArguments:(NSArray*)arguments {
	NSString * outputString;
	NSString * errorString;
	int status = [self executeCommand:command
						withArguments:arguments
						 outputString:&outputString
						  errorString:&errorString];
	if (status == 0) return outputString;
	else return nil;
}


- (NSString *) displayCommandLine:(NSString *)command
					withArguments:(NSArray*)arguments  {
	NSMutableString * fullCommandLine = [NSMutableString string];
	[fullCommandLine appendString:command];
	for (NSString * arg in arguments) {
		[fullCommandLine appendFormat:@" \"%@\"",arg];
	}
	return fullCommandLine;
}

- (int) executeCommand:(NSString *)command
		 withArguments:(NSArray*)arguments
		  outputString:(NSString**)outputString
				 errorString:(NSString**)errorString {
	
	return [self executeCommand:command
				  withArguments:arguments
				   outputString:outputString
					errorString:errorString
		   currentDirectoryPath:nil
				   environement:nil];
}


#pragma mark - Specific commands


//ONLY WORKING WITH NO PASSWORD AUTH
- (int) executeSSHToServer:(NSString*)server
				  username:(NSString*)username
			  outputString:(NSString**)outputString
			   errorString:(NSString**)errorString  {
	
	NSArray * arguments = @[@"-oBatchMode=yes", @"-t", @"-t", [NSString stringWithFormat:@"%@@%@", username, server], @"exit"];
	
	NSString * commandLine = @"/usr/bin/ssh";
	
	
	//NSString * outputString;
	//NSString * errorString;
	
	
	int codeResult =  [self executeCommand:commandLine
							 withArguments:arguments
							  outputString:outputString
							   errorString:errorString
					  currentDirectoryPath:nil
							  environement:nil ];
	
	
	return codeResult;
}


//ONLY WORKING WITH NO PASSWORD AUTH
- (int) executeSCPToServer:(NSString*)server
			  sourceFolder:(NSString*)source
				  username:(NSString*)username
			 toDestination:(NSString*)destination
			  outputString:(NSString**)outputString
			   errorString:(NSString**)errorString {
	
	NSURL * sourceURL = [NSURL fileURLWithPath:source];
	
	
	if ([FileManager isURLDirectory:sourceURL]) {
		sourceURL = [sourceURL URLByAppendingPathComponent:@"/."];//this is a fix to create the folder if not existing or updating if not
	}
	
	//scp -r /Users/gros/Desktop/testNLA xxxx@ftp.cluster.ovh.net:www/temp/testNLAss
	NSArray * arguments = @[@"-rB", sourceURL.path, [NSString stringWithFormat:@"%@@%@:%@", username, server, destination]];
	
	NSString * commandLine = @"/usr/bin/scp";
	
	
	//NSString * outputString;
	//NSString * errorString;
	
	
	int codeResult =  [self executeCommand:commandLine
							 withArguments:arguments
							  outputString:outputString
							   errorString:errorString
					  currentDirectoryPath:nil
							  environement:nil ];
	
	
	return codeResult;
}


- (int) executeXcodeBuildForArchive:(NSString*)archivePath
						 toDestinationIPA:(NSString*)destination
						withProvisionning:(NSString*)provisionning
							 outputString:(NSString**)outputString
						errorString:(NSString**)errorString
				   workingDirectory:(NSString*)workingDirectory {
	
	NSArray * arguments = @[@"-exportArchive", @"-exportFormat", @"ipa",@"-archivePath",archivePath, @"-exportPath", destination,
							//@"-exportProvisioningProfile",provisionning
							 @"-exportWithOriginalSigningIdentity"
							];
	NSString * commandLine = @"/usr/bin/xcodebuild";
	
	
	//NSString * outputString;
	//NSString * errorString;
	
	int codeResult =  [self executeCommand:commandLine
							 withArguments:arguments
							  outputString:outputString
							   errorString:errorString
					  currentDirectoryPath:workingDirectory
							  environement:nil ];
	
	
	return codeResult;
}


- (NSString*) executeUnzipFile:(NSString*)source toDestination:(NSString*)destination {
	if (!IsEmpty(source)
		&& !IsEmpty(destination)
		&& [FileManager isFileExistAtPath:[NSURL fileURLWithPath:source]]
		&& [FileManager isFileExistAtPath:[NSURL fileURLWithPath:destination]]) {
		
		return [self executeCommand:@"/usr/bin/unzip"
					  withArguments:@[source, @"-d", destination] ];
	}
	else {
		LoggerTask(0, @"executeUnzipFile with empty path");
		return nil;
	}
}


- (NSString *) executeCodeSignWithPath:(NSString*)path  {
    if (!IsEmpty(path)) {
        return [self executeCommand:@"/usr/bin/codesign"
                      withArguments:@[@"-v", @"-d", @"--entitlements", @":-", path]];
    }
    else {
        LoggerTask(0, @"executeCodeSignWithPath with empty path");
        return nil;
    }
}
- (NSString *) executeSecurityWithProvisionning:(NSString*)path  {
    if (!IsEmpty(path)) {
        
        return [self executeCommand:@"/usr/bin/security"
                      withArguments:@[@"cms", @"-D", @"-i", path]];

    }
    else {
        LoggerTask(0, @"executeCodeSignWithPath with empty path");
        return nil;
    }
}





@end
