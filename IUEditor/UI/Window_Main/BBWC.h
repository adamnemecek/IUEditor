//
//  BBWC.h
//  IUEditor
//
//  Created by seungmi on 2014. 12. 3..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

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

@end
