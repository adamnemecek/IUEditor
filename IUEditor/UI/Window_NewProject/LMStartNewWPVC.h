//
//  LMStartNewWPVC.h
//  IUEditor
//
//  Created by jd on 2014. 8. 9..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class LMStartNewVC;

@interface LMStartNewWPVC : NSViewController
@property (weak) NSButton *nextB;
@property (weak) NSButton *prevB;

- (void)show;
@property  (weak) LMStartNewVC    *parentVC;

@end
