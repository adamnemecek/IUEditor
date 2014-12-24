//
//  BBTopToolBarVC.h
//  IUEditor
//
//  Created by seungmi on 2014. 12. 3..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JDMemoryCheck.h"
#import "IUSheetController.h"
#import "IUController.h"

@interface BBTopToolBarVC : JDMemoryCheckVC

/**
 @brief connection between BBWC's sourceManager & BBTopToolBarVC's children VCs
 */

- (void)setSourceManager:(id)sourceManager;
- (void)setProject:(id)project;
@property (weak, nonatomic) IUSheetController *pageController;
@property (weak, nonatomic) IUSheetController *classController;
@property (weak, nonatomic) IUController *iuController;

@end
