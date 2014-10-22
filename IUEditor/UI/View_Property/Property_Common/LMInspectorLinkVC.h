//
//  LMPropertyIUBoxVC.h
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 4. 18..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LMDefaultPropertyVC.h"

@interface LMInspectorLinkVC : LMDefaultPropertyVC <NSTextFieldDelegate>

- (void)setProject:(IUProject*)project;

@end
