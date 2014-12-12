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

@interface BBStructureToolBarVC : NSViewController <NSPathControlDelegate>

@property (nonatomic) IUController *iuController;
@property (nonatomic) IUSheetController *pageController;
@property (nonatomic) IUSheetController *classController;

@end

