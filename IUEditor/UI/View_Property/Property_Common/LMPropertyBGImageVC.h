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
#import "LMJSManager.h"

@interface LMPropertyBGImageVC : LMDefaultPropertyVC <NSComboBoxDelegate>

@property (weak) IUResourceManager     *resourceManager;
@property (weak) LMJSManager *jsManager;

@end