#import "IntegrationSettingVC.h"
#import "AppDelegate.h"
#import "SoundHelper.h"

#define delegate ((AppDelegate *)[NSApplication sharedApplication].delegate)

@interface IntegrationSettingVC ()
@property (weak) IBOutlet NSButton *prowlEnableCheckBox;
@property (weak) IBOutlet NSButton *hipchatEnableCheckBox;
@property (weak) IBOutlet NSButton *prowlTestButton;
@property (weak) IBOutlet NSButton *hipchatTestButton;
@property (strong) IBOutlet NSTextField *prowlApiKey;

@end

@implementation IntegrationSettingVC


-(NSString*)identifier{
	return NSStringFromClass(self.class);
}
-(NSImage*)toolbarItemImage{
	return [NSImage imageNamed:@"prowl"];
}
-(NSString*)toolbarItemLabel{
	return NSLocalizedString(@"Integration", @"IntegrationToolbarItemLabel");
}

//-(NSView*)initialKeyView{
//	return self.ftpAddressTF;
//}

- (void)awakeFromNib {
	
	//init prowl action
	[self prowlActivation:nil];
	[self hipchatActivation:nil];
}

#pragma mark - prowl
- (BOOL) isProwlSettingEnabled {
	
	if ([(NSButton*)self.prowlEnableCheckBox state] == NSOnState && !IsEmpty([Preference prowlApiKey]) ) return YES;
	return NO;
}

//when user do an action disable or enable the prowl actions
- (IBAction)prowlActivation:(id)sender {
	if ([self isProwlSettingEnabled]) {
		self.prowlTestButton.enabled = YES;
	}
	else {
		self.prowlTestButton.enabled = NO;
	}
}

- (void)controlTextDidEndEditing:(NSNotification *)aNotification {
    
    NSTextField* textField = (NSTextField *)[aNotification object];
    if (textField == self.prowlApiKey) {
        //LoggerConfig(1, @"NetworkSettingVC.controlTextDidEndEditing label end of edition");
        [self prowlActivation:nil];
    }
    else {
        [self hipchatActivation:nil];
    }
}


- (IBAction)testProwlMessageAction:(id)sender {
	[BBlock dispatchOnHighPriorityConcurrentQueue:^{
		NSString * message = [NSString stringWithFormat:@"New build test %@ - %@(%@)", [delegate.application name], [delegate.application versionFonctionnal], [delegate.application versionTechnical]];
		NSError * error=nil;
		
		if (IsEmpty(delegate.application)) {
			message = @"Test prowl configuration with an url";
			[ProwlManager sendMessage:message withBuildURL:@"http://atelierdumobile.com/" error:&error];
		}
		else {
			[ProwlManager sendMessage:message withBuildURL:[delegate.application.urlToApp absoluteString] error:&error];
		}
		
		if (error !=nil) {
			NSString * errorMessage = [NSString stringWithFormat:@"Test failure with error %@", error];
			[BBlock dispatchOnMainThread:^{
				[self showMessage:errorMessage withTitle:@"Failure"];
			}];
            [SoundHelper bipError];
		}
        else {
            [SoundHelper bip];
        }
	}];
}



#pragma mark - hipchat

- (IBAction)hipchatActivation:(id)sender {
	if ([self isHipchatSettingEnabled]) {
		self.hipchatTestButton.enabled = YES;
	}
	else {
		self.hipchatTestButton.enabled = NO;
	}
}

- (BOOL) isHipchatSettingEnabled {
	
	if ([(NSButton*)self.hipchatEnableCheckBox state] == NSOnState && !IsEmpty([Preference hipchatAuthToken]) && !IsEmpty([Preference hipchatRoomID]) ) return YES;
	return NO;
}

- (IBAction)testHipChatMessageAction:(id)sender {
	[BBlock dispatchOnHighPriorityConcurrentQueue:^{
		NSString * message = [NSString stringWithFormat:@"New build test %@ - %@(%@) - %@", [delegate.application name], [delegate.application versionFonctionnal], [delegate.application versionTechnical], delegate.application.urlToApp];
		NSError * error=nil;

		if (IsEmpty(delegate.application)) {
			message = @"Test hipchat configuration http://atelierdumobile.com";
			[HipChatManager sendMessage:message withSuccess:YES error:&error];
		}
		else {
			[HipChatManager sendMessage:message withSuccess:NO error:&error];
		}
		
		if (error !=nil) {
			NSString * errorMessage = [NSString stringWithFormat:@"Test failure with error %@", error.description];
			[BBlock dispatchOnMainThread:^{
				[self showMessage:errorMessage withTitle:@"Failure"];
			}];
            [SoundHelper bipError];
		}
        else {
            [SoundHelper bip];
        }
    }];
}


@end
