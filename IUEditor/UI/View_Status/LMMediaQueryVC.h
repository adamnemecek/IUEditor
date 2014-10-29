//
//  LMMediaQueryVC.h
//  IUEditor
//
//  Created by seungmi on 2014. 10. 29..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IUCanvasController.h"


@interface LMMediaQueryVC : NSViewController

@property (nonatomic) id<IUCanvasController>  controller;

- (void)loadWithMQWidths:(NSArray *)widthArray;

@end
