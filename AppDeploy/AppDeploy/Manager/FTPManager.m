// Two connection way, if pwd provided using the shell solution, if not using the NMSSH solution

#import "FTPManager.h"
#import "TaskManager.h"


@interface FTPManager ()

//NMSSH
@property (strong) NMSSHSession * session;
@property (nonatomic) BOOL stopTransfert;

//Batch part
@property (strong) TaskManager * sshTask;

@end

@implementation FTPManager

#pragma mark - Wrapper

- (BOOL)uploadFolder:(NSURL*)folderURL
			  server:(NSString*)server
			  ftpUrl:(NSURL*)ftpURL
			 ftpUser:(NSString*)user
			 ftpPass:(NSString*)pass
  withRootFolderName:(NSString*)rootFolderName
			   error:(NSString**)errorString {
	
	LoggerNetwork(4, @"SFTP - %@@%@:%@ rootfolder=%@ with Local folder data=%@", user, server, ftpURL, rootFolderName, folderURL);
	
	//Use password less connection
	if (IsEmpty(pass)) {
		NSString * outputString;
		LoggerNetwork(4, @"SFTP - %@@%@:%@ rootfolder=%@ with Local folder data=%@", user, server, ftpURL, rootFolderName, folderURL);
		
		
		TaskManager * task = [[TaskManager alloc] init];
		self.sshTask = task;
		
		int result = [task executeSCPToServer:server
								 sourceFolder:folderURL.path
									 username:user
								toDestination:[NSString stringWithFormat:@"%@/%@",ftpURL, rootFolderName]
								 outputString:&outputString
								  errorString:errorString];
		
		if (result == 0) return YES;
		else return NO;
	}
	//Use password solution with NMSSH
	else {
		SFTPConnectionStatus status =  [self uploadFolderWithNMSSH:folderURL
															server:server
															ftpUrl:ftpURL
														   ftpUser:user
														   ftpPass:pass
												withRootFolderName:rootFolderName
															 error:errorString];
		
		
		return (status == SFTPCopySuccess);
	}
}


#pragma mark - NMSSH solution (with pwd)



//@param withRootFolderName: optional set nil to ignore
//@return YES in success upload, NO in case of any error
- (SFTPConnectionStatus)uploadFolderWithNMSSH:(NSURL*)folderURL
									   server:(NSString*)server
									   ftpUrl:(NSURL*)ftpURL
									  ftpUser:(NSString*)user
									  ftpPass:(NSString*)pass
						   withRootFolderName:(NSString*)rootFolderName
										error:(NSString**)errorString {
	self.stopTransfert = NO;
	SFTPConnectionStatus connectionStatus = SFTPOtherError;
	
	@try {
		if (self.session != nil) {
			if ([self.session isConnected]) {
				LoggerNetwork(2, @"disconnect existing session");
				@try {
					[self.session disconnect];}
				@catch(NSException *exception) {
				}
			}
		}
		//if (self.session == nil) {
		self.session = [NMSSHSession connectToHost:server withUsername:user];
		//}
		if (!self.session.isConnected) {
			LoggerNetwork(2, @"!isConnected connecting");
			
			[self.session connect];
		}
		
		if (!self.session.isConnected) {
			LoggerNetwork(0, @"!isConnected error=%@", self.session.lastError);
			connectionStatus = SFTPConnectionFailure;
			*errorString = @"Can't connect to server";
		}
		
		if (self.session.isConnected && !self.session.isAuthorized) {
			LoggerNetwork(2, @"Authentication !isAuthorized");
			BOOL authByPwd = [self.session authenticateByPassword:pass];
			if (!authByPwd) {
				connectionStatus = SFTPAuthenticationFailure;
				LoggerError(0, @"AuthentificaByPassword issue host %@ - LastError=%@", server, self.session.lastError);
				*errorString = @"Can't authenticate with server";
			}
		}
		
		
		if (self.session.isConnected && self.session.isAuthorized) {
			LoggerNetwork(2, @"Authentication succeeded");
			connectionStatus = SFTPAuthenticationSuccess;
			//NSError *error = nil;
			//NSString *response = [self.session.channel execute:@"ls -l www/temp/appdeploy/" error:&error];
			//NSLog(@"List of my sites: %@", response);
			
			
			//NMSFTP * nsmsftp = [[NMSFTP alloc] initWithSession:self.session];
			//[nsmsftp writeFileAtPath:[folderURL absoluteString] toFileAtPath:[ftpURL absoluteString]];
			
			
			
			NSURL * sourceFolder = folderURL;
			if ([folderURL isFileURL]) {
				//sourceFolder = folderURL.path;//[NSURL file:folderURL.path];//protection if we get a path url
				sourceFolder = [NSURL URLWithString:folderURL.path];//protection if we get a path url
				LoggerData(1, @"Path : %@",[folderURL.absoluteString stringByStandardizingPath]);
			}
			else {
				sourceFolder = folderURL;
			}
			NSAssert(!IsEmpty(sourceFolder), @"Source folder is empty %@", sourceFolder);
			//LoggerApp(1, @"url.path=%@ absoluteURL=%@", folderURL.path, [folderURL.absoluteURL absoluteString]);
			
			BOOL resultUpload = [self uploadFolder:sourceFolder withSession:self.session to:ftpURL withRootFolderName:rootFolderName error:errorString];
			if (resultUpload) {
				connectionStatus = SFTPCopySuccess;
				LoggerNetwork(1,@"FTP Folder content transfered with success result %d", resultUpload);
			}
			else {
				connectionStatus = SFTPCopyFailure;
				LoggerNetwork(0,@"FTP Folder transfert failure %@", [folderURL absoluteString]);
				if (IsEmpty(*errorString)) *errorString = @"Error file copy.";
			}
		}
	}
	@catch(NSException* ex) {
		LoggerError(0, @"FTP exception %@", ex);
		connectionStatus = SFTPOtherError;
		*errorString = [ex description];
	}
	@finally {
		[self.session disconnect];
		self.session = nil;
	}
	return connectionStatus;
}




//@return NO if any problem, YES if full success
//@param rootFolderName if empty take the containing folder of paramter folderURL
- (BOOL) uploadFolder:(NSURL*)folderURL
		  withSession:(NMSSHSession *)session
				   to:(NSURL*)destination
   withRootFolderName:(NSString*)rootFolderName
				error:(NSString**)errorString {
	BOOL result = YES;
	
	if (IsEmpty(folderURL) || IsEmpty(destination)) {
		LoggerError(0, @"FolderURL %@ or destination %@ are empty ", folderURL, destination);
		return NO;
	}
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NMSFTP * nmsftp = [NMSFTP connectWithSession:session];
	NSString *documentsDirectory = [folderURL absoluteString];
	
	
	NSString * containingFolder = rootFolderName;
	if (IsEmpty(containingFolder)) {
		containingFolder = [folderURL lastPathComponent];
	}
	
	if ([fileManager fileExistsAtPath:documentsDirectory]) {//protection
		NSString * rootDestinationDirectory = [[destination absoluteString] stringByAppendingPathComponent:containingFolder];
		//Create root directory
		
		if (![nmsftp directoryExistsAtPath:rootDestinationDirectory]) {
			result = [nmsftp createDirectoryAtPath:rootDestinationDirectory];
			if (result) LoggerFile(3, @"Creating root folder=%@ result=%d",rootDestinationDirectory, result);
            else LoggerFile(0, @"Error creating root folder=%@ result=%d",rootDestinationDirectory, result);
            
            *errorString = [NSString stringWithFormat:@"Can't create folder on server=%@", rootDestinationDirectory];
		}
		
		if (result ) {//protection
			NSArray *docFileList = [fileManager subpathsAtPath:documentsDirectory];
			NSEnumerator *docEnumerator = [docFileList objectEnumerator];
			NSString *docFilePath;
			
			while ((docFilePath = [docEnumerator nextObject])) {
				
				NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:docFilePath];
				LoggerFile(3, @"fullPath=%@",fullPath);
				
				NSDictionary *fileAttributes = [fileManager  attributesOfItemAtPath:fullPath error:nil];
				if (([fileAttributes fileType] != NSFileTypeDirectory) && ![fullPath hasSuffix:@".DS_Store"] ) {//file
					
					//NSString * destinationFolder = [[[destination absoluteString] stringByAppendingPathComponent:docFilePath]];
					NSString * folders = [docFilePath stringByDeletingLastPathComponent];
					NSString *directoryDestination = rootDestinationDirectory;
					
					if (!IsEmpty(folders)) {
						directoryDestination = [directoryDestination stringByAppendingPathComponent:folders];
					}
					
					if (![nmsftp directoryExistsAtPath:directoryDestination]) {
						result = [nmsftp createDirectoryAtPath:directoryDestination];
						
						if (result) {
							LoggerFile(3, @"Create folder=%@ with success",fullPath);
						}
						else {
							LoggerNetwork(0, @"Can't create folder=%@ with failure",fullPath);
							*errorString = [NSString stringWithFormat:@"Can't create folder=%@ with failure",fullPath];
							return NO;
						}
					}
					
					//LoggerFile(3, @"docFilePath=%@, folders=%@, directoryDestination=%@", docFilePath, folders, directoryDestination);
					
					
					//NSString * source = [[NSURL fileURLWithPath:fullPath] path];//Test on encoding of file name
					
					//NSString* escapedUrlString = [fullPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
					
					if (result) {
						LoggerFile(3, @"Source=%@ destionationURL=%@",fullPath, directoryDestination);
						
						directoryDestination = [NSString stringWithFormat:@"%@/",directoryDestination];
						//result = [nmsftp writeFileAtPath:fullPath toFileAtPath:directoryDestination];
						
						
						BOOL isTheBigFile = [fileAttributes fileType] != NSFileTypeDirectory && ([fullPath hasSuffix:@".ipa"] || [fullPath hasSuffix:@".apk"]);
						NSUInteger fileSize = [fileAttributes fileSize];
                        __block double lastPourcentage = 0;
						result = [session.channel uploadFile:fullPath to:directoryDestination  progress:^BOOL(NSUInteger progress) {
							if (isTheBigFile) {//hack we do it only for the big file, don't caculate size of each file
								double pourcentage = (double)progress/(double)fileSize*100;
                                
                                if (lastPourcentage==0 || (pourcentage-lastPourcentage)>=1) {//Avoid spaming log
                                    LoggerNetwork(4, @"Upload %@ - %ld - size=%.0ld - pourcentage=%.1lf%%", fullPath, progress, fileSize, pourcentage);
                                    lastPourcentage=pourcentage;
                                }
                                
								dispatch_async(dispatch_get_main_queue(),^{
									[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUploadProgress object:nil userInfo:@{@"Progression":@(pourcentage)}];
								});
							}
							return !self.stopTransfert;//continue, otherwise aboarding
						}];
						
						if (result) {
							LoggerNetwork(4,@"Upload success for %@ to %@", fullPath , directoryDestination);
						}
						else {
							LoggerNetwork(0,@"Upload failure for %@ to %@", fullPath , directoryDestination);
							*errorString = [NSString stringWithFormat:@"Upload failure for %@ to %@", fullPath , directoryDestination];
							
							return NO;
						}
					}
					else {
						LoggerError(0, @"Skiping uploading file=%@", fullPath);
						*errorString = [NSString stringWithFormat:@"Skiping uploading file=%@", fullPath];
						
						return NO;
					}
				}
			}
		}
	}
	else {
		LoggerError(0, @"Can't read or access local folder %@", [folderURL absoluteString]);
		*errorString = [NSString stringWithFormat:@"Can't read or access local folder %@", [folderURL absoluteString]];
		return NO;
	}
	
	return result;
}





#pragma mark - Test connection

//deprecated
- (SFTPConnectionStatus) testSSHConnectionToServer:(NSString*)server withUserName:(NSString*)user privateKeyPath:(NSString*)privateKeyPath {
	SFTPConnectionStatus connectionStatus;
	NMSSHSession * session = nil;
	@try {
		
		session = [NMSSHSession connectToHost:server withUsername:user];
		
		if (!session.isConnected) {
			LoggerNetwork(2, @"!isConnected connecting");
			
			[session connect];
		}
		
		if (!session.isConnected) {
			connectionStatus = SFTPConnectionFailure;
		}
		else if (!session.isAuthorized) {
			LoggerNetwork(2, @"Authentication !isAuthorized");
			
			LoggerData(1, @"Auth methods: %@", session.supportedAuthenticationMethods);
			
			BOOL authByPwd = [session authenticateByPublicKey:nil privateKey:privateKeyPath andPassword:@"XXX"];
			
			//BOOL authByPwd = [session authenticateByPassword:pass];
			if (!authByPwd) {
				connectionStatus = SFTPAuthenticationFailure;
				
				LoggerError(0, @"AuthentificaByPassword issue host %@ - LastError=%@", server, session.lastError);
			}
		}
		
		if (session.isConnected && session.isAuthorized) {
			LoggerNetwork(2, @"Authentication succeeded");
			connectionStatus = SFTPAuthenticationSuccess;
		}
		else {
			LoggerError(0,@"Authentication failure. Last error:%@",session.lastError);
		}
	}
	@catch(NSException* ex) {
		LoggerError(0, @"FTP exception %@", ex);
		connectionStatus = SFTPOtherError;
	}
	@finally {
		if (session != nil) [session disconnect];
	}
	
	return connectionStatus;
}


//@param outputError is mandatory
- (SFTPConnectionStatus) testConnectionWithServer:(NSString*)server
										  ftpUser:(NSString*)user
										  ftpPass:(NSString*)pass
											error:(NSString**)outputError {	
	NSString * outputString = nil;
	
	SFTPConnectionStatus result;
	
	if ( IsEmpty(pass) ) {
		LoggerNetwork(1, @"Passwordless connection to %@@%@", user, server);
		int codeResult = [[[TaskManager alloc] init] executeSSHToServer:server
															   username:user
														   outputString:&outputString
															errorString:outputError
															   ];
		
		//http://support.attachmate.com/techdocs/2116.html
		if (codeResult  == 0) {
		 result = SFTPConnectionSuccess;
		}
		else if (codeResult == 1) {
			result = SFTPOtherError;
			*outputError = @"Generic error, usually because invalid command line options or malformed configuration";
		}
		else if (codeResult == 2 || codeResult == 74 ) {
			result = SFTPConnectionFailure;
		}
		else if (codeResult == 76 ) {//Too many connections
			result = SFTPOtherError;
		}
		else if (codeResult == 79 ) {
			result = SFTPAuthenticationFailure;
		}
		else {
			result = SFTPOtherError;
		}
		
		LoggerNetwork(1, @"Result connection code %d - SFTPConnectionStatus=%ld - outputError=%@", codeResult, result, *outputError);
	}
	else {
		LoggerNetwork(1, @"Password connection to %@@%@", user, server);

		result = [self testConnectionNMSSHWithServer:server
															  ftpUser:user
															  ftpPass:pass
																error:outputError];
		LoggerNetwork(1, @"Result connection SFTPConnectionStatus=%ld - outputError=%@", result, *outputError);
	}

	return result;
}


- (SFTPConnectionStatus) testConnectionNMSSHWithServer:(NSString*)server
											   ftpUser:(NSString*)user
											   ftpPass:(NSString*)pass
												 error:(NSString**)errorString {
	
	SFTPConnectionStatus connectionStatus = SFTPOtherError;
	NMSSHSession * session = nil;
	@try {
		
		session = [NMSSHSession connectToHost:server withUsername:user];
		//session.timeout = @(kTimeoutConnection);
		
		if (!session.isConnected) {
			LoggerNetwork(2, @"!isConnected connecting");
			
			[session connect];
		}
		
		if (!session.isConnected) {
			connectionStatus = SFTPConnectionFailure;
			*errorString = @"Can't connect to server";
		}
		else if (!session.isAuthorized) {
			LoggerNetwork(2, @"Authentication !isAuthorized");
			
			LoggerData(1, @"Auth methods: %@", session.supportedAuthenticationMethods);
			
			//BOOL authByPwd = [session authenticateByPublicKey:nil privateKey:@"/Users/gros/.ssh/id_rsa" andPassword:@"XXXX"];
			
			BOOL authByPwd = [session authenticateByPassword:pass];
			if (!authByPwd) {
				connectionStatus = SFTPAuthenticationFailure;
				*errorString = @"Can't authenticate with server";
				LoggerError(0, @"AuthentificaByPassword issue host %@ - LastError=%@", server, session.lastError);
			}
		}
		
		if (session.isConnected && session.isAuthorized) {
			LoggerNetwork(2, @"Authentication succeeded");
			connectionStatus = SFTPAuthenticationSuccess;
		}
		else {
			LoggerError(0,@"Authentication failure. Last error:%@",session.lastError);
		}
	}
	@catch(NSException* ex) {
		LoggerError(0, @"FTP exception %@", ex);
		connectionStatus = SFTPOtherError;
		*errorString = [ex description];
	}
	@finally {
		if (session != nil) [session disconnect];
	}
	
	return connectionStatus;
}


#pragma mark - Lifecycle

- (void) stopTransfertAsync {
	//canceling of the two methodes used
	[self.sshTask stopCurrentTask];
	//we cannot use disconnect method use this solution which is working great
	self.stopTransfert = YES;
}

@end
