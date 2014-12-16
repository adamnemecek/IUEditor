//
//  BBClassNavigationVC.h
//  IUEditor
//
//  Created by seungmi on 2014. 12. 4..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IUSheetController.h"

@interface BBClassNavigationVC : NSViewController <NSOutlineViewDelegate>

@property (nonatomic, weak) IUSheetController *classController;


@end
