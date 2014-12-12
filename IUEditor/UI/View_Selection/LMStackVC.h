//
//  LMStackVC.h
//  IUEditor
//
//  Created by JD on 3/17/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IUController.h"

@interface LMStackOutlineView : NSOutlineView

@end

__attribute__((deprecated))
@interface LMStackVC : NSViewController <NSOutlineViewDataSource, NSOutlineViewDelegate, NSControlTextEditingDelegate>
#if 0
@property (weak)  IUSheet    *sheet; //set by lmwc
@property (strong) IBOutlet IUController *IUController;
@property (weak) id notificationSender;

- (IBAction)copy:(id)sender;
- (IBAction)paste:(id)sender;
- (void)connectWithEditor;
#endif
@end