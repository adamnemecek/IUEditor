//
//  SizeView.h
//  IUCanvas
//
//  Created by ChoiSeungmi on 2014. 4. 1..
//  Copyright (c) 2014년 ChoiSeungmi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "InnerSizeBox.h"
#import "IUCanvasController.h"

#if 0

/**
 @brief Deprecated 141029
 */
__attribute__((deprecated))
@interface SizeImageView : NSImageView

@end


/**
 @brief Deprecated 141029
 */
__attribute__((deprecated))
@interface SizeTextField : NSTextField

@end

/**
 @brief Deprecated 141029
 */
__attribute__((deprecated))
@interface SizeView : NSView

@property (nonatomic) id<IUCanvasController>  controller;

//addFrameSize
@property (weak) IBOutlet NSButton *addBtn;
@property (weak) IBOutlet NSPopover *addFramePopover;
@property (weak) IBOutlet NSTextField *addFrameSizeField;

- (IBAction)addSizeBtnClick:(id)sender;
- (IBAction)addSizeOKBtn:(id)sender;

- (NSInteger)nextSmallSize:(NSInteger)size;

- (void)selectBox:(InnerSizeBox *)selectBox;

- (void)addFrame:(NSInteger)width;
- (void)removeFrame:(NSInteger)width;

//scroll by canvasV
- (void)moveSizeView:(NSPoint)point withWidth:(CGFloat)width;

@property NSMutableArray *sizeArray;
- (NSArray *)sortedArray;


@end

#endif
