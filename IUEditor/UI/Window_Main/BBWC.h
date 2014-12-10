//
//  BBWC.h
//  IUEditor
//
//  Created by seungmi on 2014. 12. 3..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BBWindowProtocol.h"

typedef enum{
    BBPropertyTabTypeWidget,
    BBPropertyTabTypeProperty,
    BBPropertyTabTypeImage,
    BBPropertyTabTypeStyle,
    BBPropertyTabTypeAction,
    BBPropertyTabTypeEvent,
    BBPropertyTabTypeLibrary,
    BBPropertyTabTypeTracing,
    BBPropertyTabTypeStructure,
    BBPropertyTabTypeBackEnd,
    BBPropertyTabTypeNone,
    
}BBPropertyTabType;

@interface BBWC : NSWindowController <BBWindowProtocol>


/**
 @brief sourceManager connects between iubox(iudata) and canvasVC
 @code
 
 */
@property IUSourceManager *sourceManager;
@property IUSheetController *pageController;
@property IUSheetController *classController;
@property IUController *iuController;


- (void)reloadCurrentSheet:(id)sender;
- (NSString *)projectName;

@end
