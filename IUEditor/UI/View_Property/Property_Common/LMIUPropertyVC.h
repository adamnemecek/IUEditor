//
//  LMIUInspectorVC.h
//  IUEditor
//
//  Created by jd on 4/11/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IUController.h"
#import "LMInspectorLinkVC.h"

@protocol IUPropertyDoubleClickReceiver <NSObject>
@required
- (void)performFocus:(NSNotification*)noti;

@end

@interface LMIUPropertyVC : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

- (void)setProject:(IUProject*)project;
- (void)setFocusForDoubleClickAction;
- (void)prepareDealloc;

@property (nonatomic) IUController *controller;

@end
