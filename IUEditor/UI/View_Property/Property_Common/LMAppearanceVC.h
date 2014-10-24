//
//  LMAppearanceVC.h
//  IUEditor
//
//  Created by ChoiSeungmi on 2014. 4. 16..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IUController.h"
#import "LMPropertyBGImageVC.h"
#import "LMJSManager.h"

@interface LMAppearanceVC : NSViewController <NSOutlineViewDataSource, NSOutlineViewDelegate>

@property (nonatomic, weak) IUController      *controller;
@property (nonatomic, weak) IUResourceManager *resourceManager;
@property (nonatomic, weak) LMJSManager     *jsManager;

- (void)prepareDealloc;
@end
