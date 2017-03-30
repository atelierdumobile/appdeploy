#import "NSViewController+popup.h"

@implementation NSViewController (popup)


- (void) showMessage:(NSString*)message withTitle:(NSString*)title {
    NSAlert *alert = [[NSAlert alloc]init];
    alert.informativeText=message;
    [alert addButtonWithTitle:@"OK"];
    alert.messageText=title;
    [alert beginSheetModalForWindow:self.view.window completionHandler:NULL];
}


@end
