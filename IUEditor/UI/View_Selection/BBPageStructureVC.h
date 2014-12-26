//
//  BBPageStructureVC.h
//  IUEditor
//
//  Created by seungmi on 2014. 12. 4..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IUController.h"

@interface BBPageStructureVC : NSViewController <NSOutlineViewDelegate, NSOutlineViewDataSource>

@property (nonatomic, weak) IUController *iuController;

@end
