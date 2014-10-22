//
//  LMPropertyIURenderVC.h
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 4. 18..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LMDefaultPropertyVC.h"

@interface LMPropertyIUImportVC : LMDefaultPropertyVC


@property (weak) IUSheet *selectedClass;

- (void)setProject:(IUProject*)project;

@end
