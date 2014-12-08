//
//  BBExpandableView.h
//  IUEditor
//
//  Created by seungmi on 2014. 12. 8..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 @brief BBExpandableView supports expandable view
 */
@interface BBExpandableView : NSView


//parent View is always shown, folded state & expanded state
@property (weak) IBOutlet NSView *parentView;
//child View is only shown at expanded state
@property (weak) IBOutlet NSView *childView;
//closure button change view state (folded <-> expanded)
@property (weak, nonatomic) IBOutlet NSButton *closureButton;
//view delegate - redraw changed view
@property (weak) IBOutlet id delegate;

- (IBAction)clickExpandableButton:(id)sender;
- (CGFloat)currentHeight;

@end
