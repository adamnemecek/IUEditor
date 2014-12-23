//
//  BBCommandVC.h
//  IUEditor
//
//  Created by seungmi on 2014. 12. 3..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JDMemoryCheckVC.h"

#import "JDShellUtil.h"

#import "IUSourceManager.h"
#import "IUSheetController.h"



/**
 @brief BBComandVC manages build and open exported file by user interaction.
 Also, if project is Django type, commandVC manages run server and stop server.
 
 */
@interface BBCommandVC : JDMemoryCheckVC <JDShellUtilPipeDelegate>

@property (weak, nonatomic) IUSourceManager *sourceManager;
@property (weak, nonatomic) IUSheetController      *docController;


/**
 @brief
 build, StopServer called by it'w onw Button or WindowController(BBWC) 
 */
- (IBAction)build:(id)sender;
- (IBAction)stopServer:(id)sender;

@end
