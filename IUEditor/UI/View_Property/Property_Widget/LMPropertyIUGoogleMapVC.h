//
//  LMPropertyIUGoogleMapVC.h
//  IUEditor
//
//  Created by seungmi on 2014. 8. 7..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IUResourceManager.h"
#import "LMDefaultPropertyVC.h"


@interface LMPropertyIUGoogleMapVC : LMDefaultPropertyVC <NSComboBoxDelegate>

@property (nonatomic, weak) IUResourceManager *resourceManager;


@end
