#import "NetworkSettingVC.h"
#import "ConfigurationManager.h"
#import "TaskManager.h"
#import "NSWindow+popup.h"
#import "SoundHelper.h"

//This screen allow to check the network configuration and edit them
//TODO: missing a loader for network connection


@interface NetworkSettingVC ()


//Header
@property (weak) IBOutlet NSPopUpButton *serverConfigurationPopUpButton;
@property (weak) IBOutlet NSButton *addNewButton;
@property (weak) IBOutlet NSButton *deleteButton;

//Panel info
@property (weak) IBOutlet NSTextField *label;
@property (weak) IBOutlet NSTextField *labelError;
@property (strong) IBOutlet NSTextField *key;
@property (weak) IBOutlet NSTextField *labelKeyError;

//Upload method panel
@property (weak) IBOutlet NSPopUpButton *uploadMethodPopup;
@property (weak) IBOutlet NSTextField *server;
@property (weak) IBOutlet NSTextField *username;
@property (weak) IBOutlet NSSecureTextField *securePassword;
@property (weak) IBOutlet NSProgressIndicator *progressIndicatorNetworkTest;
@property (weak) IBOutlet NSTextField *remotepath;
@property (weak) IBOutlet NSButton *testButton;

@property (weak) IBOutlet NSTextField *serverLabel;
@property (weak) IBOutlet NSTextField *usernameLabel;
@property (weak) IBOutlet NSTextField *securedPasswordLabel;
@property (weak) IBOutlet NSTextField *remotePathLabel;


//Download access
@property (weak) IBOutlet NSTextField *httpsurl;
@property (weak) IBOutlet NSTextField *publicUrl;

//Other
@property (strong) ServerModel * currentServer;
@property (nonatomic) BOOL isTestingConnection;


@end



@implementation NetworkSettingVC

-(NSString*)identifier{
	return NSStringFromClass(self.class);
}
-(NSImage*)toolbarItemImage{
	return [NSImage imageNamed:@"ftp"];
}
-(NSString*)toolbarItemLabel{
	return NSLocalizedString(@"Deploy", @"DeployToolbarItemLabel");
}

//-(NSView*)initialKeyView{
//	return self.ftpAddressTF;
//}

//-(void)viewWillDisappear {
//	[super viewWillDisappear];
//	[Preference savePwd:[self.securePassword stringValue]];
//}





#pragma mark - Lifecycle

- (void) viewDidLoad {
	[super viewDidLoad];
	self.isTestingConnection = NO;
    self.progressIndicatorNetworkTest.hidden=YES;
}


-  (void)viewWillAppear {
	[self populateConfigAndSelectFirstItem];
}


- (void) viewWillDisappear {
	[self updateCurrentConfigurationWithData];
}



#pragma mark - GUI

- (void) updateUIWithCurrentData {
	self.progressIndicatorNetworkTest.hidden = !self.isTestingConnection;
	if ([self.serverConfigurationPopUpButton numberOfItems] <= 1) {
		self.deleteButton.enabled = NO;
	}
	else self.deleteButton.enabled = YES;
	
	//Default config specific
	if (self.currentServer.isDefaultConfig) {
		self.deleteButton.enabled = NO;
        self.label.enabled = NO;
        self.key.enabled = NO;
        self.uploadMethodPopup.enabled=NO;
        self.httpsurl.enabled=NO;
        self.publicUrl.enabled=NO;
	}
	else {
		self.deleteButton.enabled = YES;
        self.label.enabled = YES;
        self.key.enabled = YES;
        self.uploadMethodPopup.enabled=YES;
        self.httpsurl.enabled=YES;
        self.publicUrl.enabled=YES;
	}

	
    if (![[ConfigurationManager sharedManager] isServerConfigLabelIsUnique:self.currentServer]) {
        self.labelError.hidden = NO;
    }
    else {
        self.labelError.hidden = YES;
    }
    
    if (![[ConfigurationManager sharedManager] isServerConfigKeyIsUnique:self.currentServer]) {
        self.labelKeyError.hidden = NO;
    }
    else {
        self.labelKeyError.hidden = YES;
    }
	
	[self selectItemUploadMethod:self.currentServer.type];
	[self updateUIByUploadMethod:self.currentServer.type];
}


#pragma mark - Actions

- (IBAction)addNewConfigurationAction:(id)sender {
	ServerModel * newServer = [[ServerModel alloc]init];
	self.currentServer = newServer;
	newServer.label = @"New configuration";
	
	if ([[ConfigurationManager sharedManager ] isServerConfigLabelIsUnique:newServer]) {//uniquness of label
		[[ConfigurationManager sharedManager].serverConfigModels addObject:newServer];
		
		//refresh list
		[self populateConfigAndSelectLastItem];
	}
}

- (IBAction)deleteConfigurationAction:(id)sender {
	if (self.currentServer != nil && ! self.currentServer.isDefaultConfig) {
		LoggerData(0, @"Will remove config at index %ld", self.serverConfigurationPopUpButton.indexOfSelectedItem);
		[[ConfigurationManager sharedManager].serverConfigModels removeObjectAtIndex:self.serverConfigurationPopUpButton.indexOfSelectedItem];
		self.currentServer = nil;
		[self populateConfigAndSelectFirstItem];
	}
	//LoggerConfig(1, @"Delete current config %@", current.label);
}


- (IBAction)configurationChangeAction:(id)sender {
	
	[self saveConfigurationData:self.currentServer];//save previous template
	self.currentServer = [self currentServerConfiguration];
	[self refreshServerConfigItemName];
	[self displayDataConfiguration];
	[self updateUIWithCurrentData];
	
	
	////TODO for test, to remove
	//[[ConfigurationManager sharedManager] saveConfiguration];
}

- (void)controlTextDidEndEditing:(NSNotification *)aNotification {
	LoggerConfig(1, @"Configuration end editing");
	//if([notification object] == self.securePassword) {
	//
	//	[Preference savePwd:[self.securePassword stringValue]];
	//	NSLog(@"The contents of the text field changed");
	//}
	[self updateCurrentConfigurationWithData];
	
	NSTextField* textField = (NSTextField *)[aNotification object];
	if (textField == self.label) {
		//LoggerConfig(1, @"NetworkSettingVC.controlTextDidEndEditing label end of edition");
		[self refreshServerConfigItemName];
	}
	
	[self updateUIWithCurrentData];
}

#pragma mark - Update UI


- (void)saveConfigurationData:(ServerModel*)currentServerConfiguration {
	currentServerConfiguration.server = self.server.stringValue;
	currentServerConfiguration.username = self.username.stringValue;
	currentServerConfiguration.password = self.securePassword.stringValue;
	currentServerConfiguration.publicUrl = self.publicUrl.stringValue;
	currentServerConfiguration.httpsUrl = self.httpsurl.stringValue;
	currentServerConfiguration.remotePath = self.remotepath.stringValue;
	currentServerConfiguration.label = self.label.stringValue;
    currentServerConfiguration.type = self.uploadMethodPopup.selectedTag;
    currentServerConfiguration.key = self.key.stringValue;
	NSLog(@"Saving configuration %d", (int)currentServerConfiguration.type);
}



- (void) displayDataConfiguration {
	ServerModel * currentServerConfiguration = [self currentServerConfiguration];
	if (currentServerConfiguration != nil) {
		self.server.stringValue = notEmptyString(currentServerConfiguration.server);
		self.username.stringValue = notEmptyString(currentServerConfiguration.username);
		self.securePassword.stringValue = notEmptyString(currentServerConfiguration.password);
		self.publicUrl.stringValue = notEmptyString(currentServerConfiguration.publicUrl);
		self.httpsurl.stringValue = notEmptyString(currentServerConfiguration.httpsUrl);
		self.remotepath.stringValue = notEmptyString(currentServerConfiguration.remotePath);
        self.label.stringValue = notEmptyString(currentServerConfiguration.label);
        self.key.stringValue = notEmptyString(currentServerConfiguration.key);
	}
}

- (void) updateCurrentConfigurationWithData {
	ServerModel * config = [self currentServerConfiguration];
	[self saveConfigurationData:config];
}




#pragma mark - serverConfiguration


- (void) populateConfigAndSelectFirstItem {
	[self populateServerConfigPopupButton];
	self.currentServer = [self currentServerConfiguration];
	[self displayDataConfiguration];
	[self updateUIWithCurrentData];
}

- (void) populateConfigAndSelectLastItem {
	[self populateServerConfigPopupButton];
	NSMenuItem * lastItem = [self.serverConfigurationPopUpButton lastItem];
	[self.serverConfigurationPopUpButton selectItem:lastItem];
	self.currentServer = [self currentServerConfiguration];
	[self displayDataConfiguration];
	[self updateUIWithCurrentData];
}


- (NSArray*)titlesOfList {
	NSArray * serverConfig = [ConfigurationManager sharedManager].serverConfigModels;
	NSMutableArray * titles = [NSMutableArray array];
	for (ServerModel * aServerConfig in serverConfig) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self BEGINSWITH %@", aServerConfig.label];
		NSArray *filteredArray = [titles filteredArrayUsingPredicate:predicate];
		NSUInteger nbreDuplication = [filteredArray count];
		if (nbreDuplication>0) {
			[titles addObject:[NSString stringWithFormat:@"%@ (%ld)",aServerConfig.label,nbreDuplication]];
		}
		else {
			[titles addObject:aServerConfig.label];
		}
	}
	return titles;
}

- (void) populateServerConfigPopupButton {
	[[self.serverConfigurationPopUpButton menu] removeAllItems];
	
	NSArray * titles = [self titlesOfList];
	[self.serverConfigurationPopUpButton addItemsWithTitles:titles];
}

//usefull when user update the label
- (void) refreshServerConfigItemName {
	NSArray * serverConfig = [ConfigurationManager sharedManager].serverConfigModels;
	NSArray * titles = [self titlesOfList];
	
	
	if ([titles count] == [self.serverConfigurationPopUpButton numberOfItems]) {
		for (int i = 0; i<[self.serverConfigurationPopUpButton numberOfItems];i++) {
			NSMenuItem * item = [self.serverConfigurationPopUpButton itemAtIndex:i];
			item.title = titles[i];
		}
	}
	else {
		NSInteger itemSelected = self.serverConfigurationPopUpButton.indexOfSelectedItem;
		LoggerData(0, @"ItemSelected = %ld - number of items %ld - number of configs %ld", itemSelected, self.serverConfigurationPopUpButton.numberOfItems, [serverConfig count]);
	}
}

- (ServerModel *) currentServerConfiguration {
	NSUInteger index = self.serverConfigurationPopUpButton.indexOfSelectedItem;
	ServerModel * server = [[ConfigurationManager sharedManager] serverModelAtIndex:index];
	return server;
}



#pragma mark - Network actions



#pragma mark - upload method

- (void) selectItemUploadMethod:(ServerModelType)type {
	[self.uploadMethodPopup selectItemWithTag:type];
	/*switch(type) {
		case ServerModelSFTP:
			break;
		case ServerModelSCP:
			break;
		case ServerModelLocal:
			break;
		case ServerModelDropbox:
			break;*/
}

- (IBAction)uploadMethodChange:(id)sender {
	NSPopUpButton * popUpButton=  (NSPopUpButton *) sender;
	switch(popUpButton.selectedTag) {
		case 0://SFTP
			NSLog(@"SFTP");
			[self updateUIByUploadMethod:ServerModelSFTP];
			break;
		case 1://SSH
			NSLog(@"SSH");
			[self updateUIByUploadMethod:ServerModelSCP];
			break;
		case 2://Folder
			NSLog(@"Output");
			[self updateUIByUploadMethod:ServerModelLocal];

			break;
		case 3://Dropbox
			NSLog(@"Dropbox");
			[self updateUIByUploadMethod:ServerModelDropbox];
			break;
	}
}


- (void) updateUIByUploadMethod:(ServerModelType) type {
	switch(type) {
		case ServerModelSFTP:
			self.username.enabled = YES;
			self.securePassword.enabled = YES;
			self.server.enabled = YES;
			self.remotepath.enabled = YES;
			self.testButton.enabled = YES;
			
			self.serverLabel.textColor = [self setColorEnabled:YES];
			self.usernameLabel.textColor = [self setColorEnabled:YES];
			self.securedPasswordLabel.textColor = [self setColorEnabled:YES];
			self.remotePathLabel.textColor = [self setColorEnabled:YES];
			break;
		case ServerModelSCP:
			self.username.enabled = YES;
			self.securePassword.enabled = NO;
			self.server.enabled = YES;
			self.remotepath.enabled = YES;
			self.testButton.enabled = YES;
			
			self.serverLabel.textColor = [self setColorEnabled:YES];
			self.usernameLabel.textColor = [self setColorEnabled:YES];
			self.securedPasswordLabel.textColor = [self setColorEnabled:NO];
			self.remotePathLabel.textColor = [self setColorEnabled:YES];
			break;
		case ServerModelLocal:
			self.username.enabled = NO;
			self.securePassword.enabled = NO;
			self.server.enabled = NO;
			self.remotepath.enabled = NO;
			self.testButton.enabled = NO;
			self.serverLabel.textColor = [self setColorEnabled:NO];
			self.usernameLabel.textColor = [self setColorEnabled:NO];
			self.securedPasswordLabel.textColor = [self setColorEnabled:NO];
			self.remotePathLabel.textColor = [self setColorEnabled:NO];
			break;
		case ServerModelDropbox:
			break;
	}
}

- (NSColor*) setColorEnabled:(BOOL)enabled {
	if (enabled) return [NSColor controlTextColor];
	else return [NSColor disabledControlTextColor];
}



- (IBAction)testAccess:(id)sender {

	[self updateCurrentConfigurationWithData];
    
    self.isTestingConnection=YES;
    self.progressIndicatorNetworkTest.hidden = NO;
    [self.progressIndicatorNetworkTest startAnimation:nil];
    
	//First update config settings, as the user can click  and the field is not saved
	
	ServerModel * serverConfig = [self currentServerConfiguration];
	NSString * server = serverConfig.server;
	NSString * login = serverConfig.username;
    NSString * pwd = serverConfig.password;
    NSString * rootFolder = serverConfig.remotePath;

	
	if (!IsEmpty(login) && !IsEmpty(server)) {
		LoggerApp(1, @"Using network configuration");
		
		[BBlock dispatchOnHighPriorityConcurrentQueue:^{
			SFTPConnectionStatus result;
			NSString * errorString = nil;
			result = [[[FTPManager alloc]init] testConnectionWithServer:server
															 ftpUser:login
															 ftpPass:pwd
                                                             rootPath:rootFolder
															   error:&errorString];
			LoggerNetwork(1, @"Connexion test %@ with user %@  resultSuccessCode=%ld", server, login, result);
            BOOL isCheckingPath = serverConfig.type == ServerModelSFTP;
			
			[BBlock dispatchOnMainThread:^{
				NSString * title = nil;
				NSString * message = errorString;
				
				switch (result) {
					case SFTPConnectionFailure:
                        [SoundHelper bipError];
						title = @"Connection failure 👎";
						if (IsEmpty(message)) {
							message = [NSString stringWithFormat:@"Couldn't connect to host %@", server];
						}
						break;
					case SFTPAuthenticationFailure:
                        [SoundHelper bipError];
						title = @"Authentication failure 👎";
						if (IsEmpty(message)) {
							message = @"Please check your login/pwd.";
						}
						break;
                    case SFTPPathNotFound:
                        title = @"Path failure 👎";
                        message = @"Please check your path and that you have write access.";
                        break;
					case SFTPAuthenticationSuccess:
                    case SFTPConnectionSuccess:
                        [SoundHelper bip];
						title = @"Connection success 👍";
                        if (isCheckingPath) {
                            message = @"The authentication was successfull, and root directory exist. Be sure that the path provided is writable.";
                        }
                        else {
                            message = @"The authentication was successfull, be sure that the path provided exist and is writable.";
                        }
						break;
					default:
                        [SoundHelper bipError];
						title = @"Connection failure 👎";
						if (IsEmpty(message)) {
							message = @"Unkown error";
						}
						break;
				}

                [self showMessage:message withTitle:title];
                
                self.progressIndicatorNetworkTest.hidden = YES;
                [self.progressIndicatorNetworkTest stopAnimation:nil];
                self.isTestingConnection=NO;
			}];
			
		}];
		
    }
}

- (IBAction)aboutNetworkTypeAction:(id)sender {
    
    NSString * message = @""
    "You have different kind of connection support. This section is the weak part of the tool:\n\n"
    "• SFTP : requiring pwd and ⚠️ clear storage for now in the settings ⚠️. You have a progress bar during upload in this mode.\n\n"
    "• SCP : using your ~/.ssh/id_rsa.pub to connect to your server using ssh. No password are stored this way.\n\n"
    "• Dropbox : coming soon."
    "";
    [self showMessage:message withTitle:@"Network connexion"];
}

@end
