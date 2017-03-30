#import <Foundation/Foundation.h>
#include <NMSSH/NMSSH.h>

//TODO: rename the class to SFTPManager or something better
//TODO: use a singleton for this ? IMpact on multiple document access
@interface FTPManager : NSObject

typedef NS_ENUM(NSInteger,SFTPConnectionStatus) {
	SFTPConnectionSuccess,
	SFTPConnectionFailure,
 	SFTPAuthenticationSuccess,
	SFTPAuthenticationFailure,
	SFTPCopySuccess,
	SFTPCopyFailure,
 	SFTPOtherError
};



- (BOOL)uploadFolder:(NSURL*)folderURL
			  server:(NSString*)server
			  ftpUrl:(NSURL*)ftpURL
			 ftpUser:(NSString*)user
			 ftpPass:(NSString*)pass
  withRootFolderName:(NSString*)rootFolderName
			   error:(NSString**)errorString;

- (SFTPConnectionStatus) testConnectionWithServer:(NSString*)server
										  ftpUser:(NSString*)user
										  ftpPass:(NSString*)pass
											error:(NSString**)outputError;

- (void) stopTransfertAsync;

@end
