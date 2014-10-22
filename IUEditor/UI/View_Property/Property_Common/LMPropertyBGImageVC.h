//
//  LMPropertyBGImageVC.h
//  IUEditor
//
//  Created by JD on 4/5/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LMDefaultPropertyVC.h"
#import "IUResourceManager.h"
#import "JDOutlineCellView.h"

@interface LMPropertyBGImageVC : LMDefaultPropertyVC <NSComboBoxDelegate>

@property (weak) IUResourceManager     *resourceManager;

@end