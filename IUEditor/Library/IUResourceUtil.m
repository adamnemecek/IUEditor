//
//  IUResourceUtil.m
//  IUEditor
//
//  Created by seungmi on 2014. 8. 26..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUResourceUtil.h"


@implementation IUResourceUtil


+ (NSImage *)classNavImage:(NSString *)className{
    NSArray *plistArray = @[@"widgetForDefault", @"widgetForDjango", @"widgetForWordpress"];
    
    NSMutableArray *widgetList = [NSMutableArray array];
    for(NSString *fileName in plistArray){
        NSString *widgetFilePath =  [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
        NSArray *availableWidgetProperties = [NSArray arrayWithContentsOfFile:widgetFilePath];
        [widgetList addObjectsFromArray:availableWidgetProperties];
    }
    for (NSDictionary *dict in widgetList) {
        NSString *name = dict[@"className"];
        if([name isEqualToString:className]){
            NSImage *classImage = [NSImage imageNamed:dict[@"navImage"]];
            return classImage;
        }
    }
    return nil;
}

+ (NSImage *)classNavImage:(NSString *)className forProjectType:(IUProjectType)type{
    
    NSArray *widgetList = [IUResourceUtil widgetListForProjectType:type];

    for (NSDictionary *dict in widgetList) {
        NSString *name = dict[@"className"];
        if([name isEqualToString:className]){
            NSImage *classImage = [NSImage imageNamed:dict[@"navImage"]];
            return classImage;
        }
    }
    return nil;
}

+ (NSArray *)widgetListForProjectType:(IUProjectType)type{
    NSMutableArray *widgetList = [NSMutableArray array];
    NSString *widgetFilePath = [[NSBundle mainBundle] pathForResource:@"widgetForDefault" ofType:@"plist"];
    NSArray *availableWidgetProperties = [NSArray arrayWithContentsOfFile:widgetFilePath];
    [widgetList addObjectsFromArray:availableWidgetProperties];
    
    if(type == IUProjectTypeDjango){
        NSString *widgetFilePath = [[NSBundle mainBundle] pathForResource:@"widgetForDjango" ofType:@"plist"];
        NSArray *availableWidgetProperties = [NSArray arrayWithContentsOfFile:widgetFilePath];
        [widgetList addObjectsFromArray:availableWidgetProperties];
    }
    else if(type == IUProjectTypeWordpress){
        NSString *widgetFilePath = [[NSBundle mainBundle] pathForResource:@"widgetForWordpress" ofType:@"plist"];
        NSArray *availableWidgetProperties = [NSArray arrayWithContentsOfFile:widgetFilePath];
        [widgetList addObjectsFromArray:availableWidgetProperties];
    }
    return widgetList;
}

@end
