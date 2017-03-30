//
//  PreferenceWindow.m
//  AppBuilder
//
//  Created by Nicolas Lauquin on 19/09/2014.
//  Copyright (c) 2014 ADM. All rights reserved.
//

#import "PreferenceWindow.h"
#import "AppDelegate.h"
#import "MainNSWindow.h"
#import "SoundHelper.h"
#import "Preference.h"
#import "ProwlManager.h"

#define delegate ((AppDelegate *)[NSApplication sharedApplication].delegate)


@interface PreferenceWindow()

//Settings
@property (weak) IBOutlet NSButton *prowlTestButton;

@property (weak) IBOutlet NSButtonCell *prowlEnableCheckBox;
@property (weak) IBOutlet NSTextFieldCell *apiKeyTextField;

@end



@implementation PreferenceWindow



- (void)awakeFromNib {
	
	//init prowl action
	[self prowlActivation:nil];
	
}


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

#pragma mark - Settings

- (IBAction)testProwlMessageAction:(id)sender {
	[BBlock dispatchOnHighPriorityConcurrentQueue:^{
		NSString * message = [NSString stringWithFormat:@"New build test %@ - %@(%@)", [delegate.application name], [delegate.application versionFonctionnal], [delegate.application versionTechnical]];
        [ProwlManager sendMessage:message withBuildURL:@"http://atelierdumobile.com/" error:nil];
		[SoundHelper bip];
	}];
}

- (IBAction)openTemporaryFolder:(id)sender {
	[[NSWorkspace sharedWorkspace] openFile:NSTemporaryDirectory()];
}


@end
