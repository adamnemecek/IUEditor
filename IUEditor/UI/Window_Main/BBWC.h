//
//  BBWC.h
//  IUEditor
//
//  Created by seungmi on 2014. 12. 3..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IUSourceManager.h"
#import "IUSheetController.h"
#import "IUController.h"

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

@interface BBWC : NSWindowController


/**
 @brief sourceManager connects between iubox(iudata) and canvasVC
 @code
 
 */
@property IUSourceManager *sourceManager;
@property IUSheetController *pageController;
@property IUSheetController *classController;
@property IUController *iuController;

@end
