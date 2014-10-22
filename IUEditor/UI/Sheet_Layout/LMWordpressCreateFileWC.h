//
//  LMWordpressCreateFileWC.h
//  IUEditor
//
//  Created by jd on 2014. 8. 7..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IUWordpressProject.h"
#import "IUSheetController.h"

@interface LMWordpressCreateFileWC : NSWindowController

@property (weak) IUWordpressProject *project;
@property (weak) IUSheetController *sheetController;

@end
