//
//  NSAlert+Blocks.h
//  Cloud Backup Agent
//
//  Created by Andreas Zöllner on 07.08.15.
//  Copyright (c) 2015 Studio Istanbul Medya Hiz. Tic. Ltd. Sti. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSAlert (BBlock)
-(void)beginSheetModalForWindow:(NSWindow *)window completionHandler:(void (^)(NSInteger returnCode))handler contextInfo:(void *)contextInfo;
@end
