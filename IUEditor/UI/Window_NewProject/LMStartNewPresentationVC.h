//
//  LMStartNewPresentationVC.h
//  IUEditor
//
//  Created by jw on 5/3/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class LMStartNewVC;

@interface LMStartNewPresentationVC : NSViewController
@property (weak) NSButton *nextB;
@property (weak) NSButton *prevB;

- (void)show;
@property (weak)  LMStartNewVC    *parentVC;

@end
