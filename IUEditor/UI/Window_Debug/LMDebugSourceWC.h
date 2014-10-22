//
//  LMDebugSourceWC.h
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 6. 3..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LMCanvasVC.h"

@interface LMDebugSourceWC : NSWindowController

@property LMCanvasVC *canvasVC;


- (void)setCurrentSource:(NSString *)source;

@end
