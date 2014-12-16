//
//  BBProjectStructureVC.h
//  IUEditor
//
//  Created by seungmi on 2014. 12. 4..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IUSheetController.h"
#import "IUController.h"

@interface BBProjectStructureVC : NSViewController

//Controllers
@property (nonatomic, weak) IUSheetController *pageController;
@property (nonatomic, weak) IUSheetController *classController;
@property (nonatomic, weak) IUController *iuController;

@end
