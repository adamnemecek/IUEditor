//
//  IUEvent2.h
//  IUEditor
//
//  Created by Joodong Yang on 2014. 11. 24..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum _IUEventType{
    IUEventTypeClick,
    IUEventTypeMouseHover,
    IUEventTypeScroll,
    IUEventTypeVariableChange,
}IUEventType;

typedef enum _IUActionType{
    IUActionTypeVariableIncrease,
    IUActionTypeStyle,
}IUActionType;

@class IUEventStyleAction;

#define kHTMLWindow @"window"

@interface IUEvent2 : NSObject

@property NSInteger minViewPortCondition; //initial value = 0
@property NSInteger maxViewPortCondition; //initial value = IUDefaultViewPort
@property NSString  *customCondition; //string which will be inserted in javascript
@property BOOL restore;

/* trigger */
@property (weak) id trigger; //IUBox or kHTMLWindow
@property IUEventType type;
@property (copy) NSString *variableEventCondition; // eg. x==1. Null when eventType != IUEventVariableChange

/* receiver */
@property (weak) id receiver;
@property IUActionType actionType;
@property IUEventStyleAction *styleAction;

@property NSString *variable; //valid if actionType = IUActionTypeVariableIncrease
@property NSInteger *intialValue; //valid if actionType = IUActionTypeVariableIncrease
@property NSInteger *maximumValue; //valid if actionType = IUActionTypeVariableIncrease

@end

@interface IUEventStyleAction : NSObject
@property NSString *x;
@property NSString *y;
@property NSString *width;
@property NSString *height;
@property NSString *visible;
@end