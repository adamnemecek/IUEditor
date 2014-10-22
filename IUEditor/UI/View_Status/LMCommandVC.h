//
//  LMCommandVC.h
//  IUEditor
//
//  Created by jd on 5/20/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IUCompiler.h"
#import "IUSheetController.h"
#import "JDShellUtil.h"

@interface LMCommandVC : NSViewController <JDShellUtilPipeDelegate>

@property (weak, nonatomic) IUSheetController      *docController;

- (void)prepareDealloc;


// Remove Recording feature at v0.3
//- (IBAction)toggleRecording:(id)sender;

- (IBAction)build:(id)sender;
- (IBAction)stopServer:(id)sender;


@end