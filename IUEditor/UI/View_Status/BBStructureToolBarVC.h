//
//  BBStructureToolBarVC.h
//  IUEditor
//
//  Created by seungmi on 2014. 12. 5..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IUController.h"
#import "IUSheetController.h"
#import "JDMemoryCheckVC.h"

@interface BBStructureToolBarVC : JDMemoryCheckVC <NSPathControlDelegate>

@property (nonatomic, weak) IUController *iuController;
@property (nonatomic, weak) IUSheetController *pageController;
@property (nonatomic, weak) IUSheetController *classController;

@end

