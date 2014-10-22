//
//  IUResourceUtil.h
//  IUEditor
//
//  Created by seungmi on 2014. 8. 26..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IUProject.h"


@interface IUResourceUtil : NSObject

+ (NSImage *)classNavImage:(NSString *)className;
+ (NSImage *)classNavImage:(NSString *)className forProjectType:(IUProjectType)type;
+ (NSArray *)widgetListForProjectType:(IUProjectType)type;

@end
