//
//  LMStartNewDefaultVC.h
//  IUEditor
//
//  Created by jd on 5/2/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class LMStartNewVC;

__attribute__((deprecated))
@interface LMStartNewDefaultVC : NSViewController
@property (weak) NSButton *nextB;
@property (weak) NSButton *prevB;

- (void)show;
@property (weak)   LMStartNewVC    *parentVC;

@end