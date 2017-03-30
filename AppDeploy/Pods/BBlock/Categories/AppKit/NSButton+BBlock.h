//
//  NSButton+BBlock.h
//  BBlock
//
//  Created by David Keegan on 4/10/12.
//  Copyright (c) 2012 David Keegan. All rights reserved.
//

@interface NSButton(BBlock)

typedef void (^BBNSButtonCallback)(NSButton *button);

/// Set the callback block to be called when the mouse **enters** the button.
- (void)setInCallback:(BBNSButtonCallback)block;

/// Set the callback block to be called when the mouse **exits** the button.
- (void)setOutCallback:(BBNSButtonCallback)block;

/// Set both the **enter* and **exit** callback blocks.
- (void)setInCallback:(BBNSButtonCallback)inBlock
       andOutCallback:(BBNSButtonCallback)outBlock;

@end
