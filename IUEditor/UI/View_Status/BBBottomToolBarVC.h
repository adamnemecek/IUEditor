//
//  BBBottomToolBarVC.h
//  IUEditor
//
//  Created by seungmi on 2014. 12. 19..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IUSheetController.h"

@interface BBBottomToolBarVC : NSViewController

@property (weak) IUSheetController *pageController;
@property (weak) IUSheetController *classController;

@end
