//
//  LMStartNewDjangoVC.h
//  IUEditor
//
//  Created by jw on 5/3/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class LMStartNewVC;

__attribute__((deprecated))
@interface LMStartNewDjangoVC : NSViewController
@property (weak) NSButton *nextB;
@property (weak) NSButton *prevB;


//Dir 설정
@property (weak)  LMStartNewVC    *parentVC;

- (void)show;

@end