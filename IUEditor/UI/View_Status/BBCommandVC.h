//
//  BBCommandVC.h
//  IUEditor
//
//  Created by seungmi on 2014. 12. 3..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "JDShellUtil.h"

#import "IUSourceManager.h"
#import "IUSheetController.h"


@interface BBCommandVC : NSViewController <JDShellUtilPipeDelegate>

@property (nonatomic, weak) IUSourceManager *sourceManager;
@property (weak, nonatomic) IUSheetController      *docController;


- (IBAction)build:(id)sender;
- (IBAction)stopServer:(id)sender;

@end
