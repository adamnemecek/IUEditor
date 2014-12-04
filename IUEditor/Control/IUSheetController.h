//
//  IUSheetController.h
//  IUEditor
//
//  Created by JD on 3/17/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IUProject.h"
#import "IUSheet.h"


@interface IUSheetController : NSTreeController

- (id)initWithSheetGroup:(IUSheetGroup *)sheetGroup;

-(IUProject *)project;


@end