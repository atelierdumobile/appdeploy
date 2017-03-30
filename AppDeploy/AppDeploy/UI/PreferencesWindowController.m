#import "PreferencesWindowController.h"

@implementation PreferencesWindowController


- (void) close {
	[super close];
}

- (void)windowWillClose:(NSNotification *)notification {
	LoggerConfig(4, @"Closing setting, saving configuration");
	[[ConfigurationManager sharedManager] saveConfiguration];
	
	if (self.mainWindow!=nil&& [self.mainWindow respondsToSelector:@selector(refreshData)]) {
		[self.mainWindow refreshData];
	}
	
}

@end
