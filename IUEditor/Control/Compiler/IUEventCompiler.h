//
//  IUEventCompiler.h
//  IUEditor
//
//  Created by Joodong Yang on 2014. 11. 23..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JDCode.h"
#import "IUBoxes.h"

@interface IUEventCompiler : NSObject

/**
 @return Javascript Code to insert page HTML header
 */
- (JDCode *)fullEventRuleCode:(IUPage *)page;

/**
 @return NSDictionary which has key:condition value:action
 */
#define IUEventTriggerKey @"event"
#define IUEventActionKey @"action"
#define IUEventConditionKey @"condition"
- (NSDictionary *)unitEventRuleCode:(IUBox *)box;

@end
