//
//  BBTracingPropertyVC.h
//  IUEditor
//
//  Created by seungmi on 2014. 12. 8..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IUResource.h"
#import "IUSheetController.h"

@interface BBTracingPropertyVC : NSViewController <NSComboBoxDelegate>

@property (nonatomic, weak) IUResourceRootItem *resourceRootItem;
@property (weak) IUSheetController *pageController, *classController;

@end
