//
//  BBQuickWidgetVC.h
//  IUEditor
//
//  Created by seungmi on 2014. 12. 5..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IUSheetController.h"
#import "IUController.h"

@interface BBQuickWidgetVC : NSViewController

@property (weak) IUSheetController *pageController;
@property (weak) IUSheetController *classController;
@property (weak) IUController *iuController;

- (void)setQuickWidgetArray:(NSArray *)quickWidgetsArray;

@end
