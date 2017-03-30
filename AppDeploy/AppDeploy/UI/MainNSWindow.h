#import <Cocoa/Cocoa.h>
#import "BackgroundView.h"
#import "ABApplication.h"

@interface MainNSWindow : NSWindow

//- (void) setApplication:(ABApplication*)application;
//- (void) displayApplicationView;
- (void) displayInfoApplication:(ABApplication*)application;
+ (ABApplication *) handleFileIfSupported:(NSString*)path displayErrorMessageToWindow:(MainNSWindow*)window;
+ (ABApplication *) handleFileIfSupported:(NSString*)path;
- (IBAction)signAndTemplate:(id)sender;
- (IBAction)signAndPush:(id)sender;
- (void)refreshData;//call after a setting change for exemple

@end
