#import "TerminalSettingVC.h"
#import "AppDelegate.h"
#import "MainNSWindow.h"

#define delegate ((AppDelegate *)[NSApplication sharedApplication].delegate)

@interface TerminalSettingVC ()
@property (weak) IBOutlet NSButton *prowlEnableCheckBox;
@property (weak) IBOutlet NSButton *hipchatEnableCheckBox;
@property (weak) IBOutlet NSButton *prowlTestButton;
@property (weak) IBOutlet NSButton *hipchatTestButton;
@property (strong) IBOutlet NSTextField *commandLineDisplay;

@end

@implementation TerminalSettingVC


-(NSString*)identifier{
	return NSStringFromClass(self.class);
}
-(NSImage*)toolbarItemImage{
	return [NSImage imageNamed:@"Terminal"];
}
-(NSString*)toolbarItemLabel{
	return NSLocalizedString(@"Terminal", @"TerminalToolbarItemLabel");
}


- (IBAction)openInTerminalAction:(id)sender {
    [[NSWorkspace sharedWorkspace] openFile: kTerminalPath];
    
    NSString * path = [self commandLine];
    
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] setString:path  forType:NSStringPboardType];
    
    
    LoggerData(3, @"path=%@",path);
}


- (void)awakeFromNib {
    [self.commandLineDisplay setStringValue:[self commandLine]];
}


- (NSString *) commandLine {
        NSString * path = [NSString stringWithFormat:@"%@%@",[[NSBundle mainBundle] bundlePath], kCommandLineHelpOutput];
    return path;
}



@end
