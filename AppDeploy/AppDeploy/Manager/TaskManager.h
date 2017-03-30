#import <Foundation/Foundation.h>

@interface TaskManager : NSObject

- (void) stopCurrentTask;

- (NSString*) executeCodeSignWithPath:(NSString*)path;
- (NSString *) executeSecurityWithProvisionning:(NSString*)path;

- (NSString*) executeUnzipFile:(NSString*)source toDestination:(NSString*)destination;

- (NSString*) executeCommand:(NSString *)command withArguments:(NSArray*)arguments;

- (int) executeCommand:(NSString *)command
		 withArguments:(NSArray*)arguments
		  outputString:(NSString**)outputString
				 errorString:(NSString**)errorString;

- (int) executeXcodeBuildForArchive:(NSString*)archivePath
						 toDestinationIPA:(NSString*)destination
						withProvisionning:(NSString*)provisionning
							 outputString:(NSString**)outputString
						errorString:(NSString**)errorString
				   workingDirectory:(NSString*)workingDirectory;


- (int) executeSCPToServer:(NSString*)server
			  sourceFolder:(NSString*)source
				  username:(NSString*)username
			 toDestination:(NSString*)destination
			  outputString:(NSString**)outputString
			   errorString:(NSString**)errorString;


- (int) executeSSHToServer:(NSString*)server
				  username:(NSString*)username
			  outputString:(NSString**)outputString
			   errorString:(NSString**)errorString;
@end
