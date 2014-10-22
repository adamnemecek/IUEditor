//
//  LMPropertyIUMovieVC.h
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 4. 18..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LMDefaultPropertyVC.h"
#import "IUResourceManager.h"

@interface LMPropertyIUMovieVC : LMDefaultPropertyVC <NSComboBoxDelegate>

@property (nonatomic, weak) IUResourceManager *resourceManager;

@end
