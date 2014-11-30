//
//  LMPropertyIUcarousel.h
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 4. 18..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LMDefaultPropertyVC.h"


@interface LMPropertyIUCarouselVC : LMDefaultPropertyVC <NSOutlineViewDataSource, NSOutlineViewDelegate>

@property (nonatomic) NSArray *imageArray;

@end
