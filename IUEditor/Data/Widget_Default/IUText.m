//
//  IUText.m
//  IUEditor
//
//  Created by seungmi on 2014. 11. 25..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUText.h"

@implementation IUText

+ (IUWidgetType)widgetType{
    return IUWidgetTypePrimary;
}
+ (NSImage *)classImage{
    return [NSImage imageNamed:@"tool_text"];
}

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"stack_text"];
}

/**
 
 Some convenience methods to create iubox
 */
+(IUText *)copyrightBox{
    IUText *copyright = [[IUText alloc] initWithPreset];
    [copyright.undoManager disableUndoRegistration];
    
    copyright.name = @"Copyright";
    copyright.enableHCenter = YES;
    
    copyright.defaultPropertyStorage.innerHTML = @"Copyright (C) IUEditor all rights reserved";
    copyright.defaultPositionStorage.y = @(40);
    
    copyright.defaultStyleStorage.width = nil;
    copyright.defaultStyleStorage.height = nil;
    copyright.defaultStyleStorage.bgColor = nil;
    
    copyright.defaultStyleStorage.fontName = @"Roboto";
    copyright.defaultStyleStorage.fontSize = @(12);
    copyright.defaultStyleStorage.fontLineHeight = @(1.5);
    copyright.defaultStyleStorage.fontAlign = @(IUAlignCenter);
    copyright.defaultStyleStorage.fontColor = [NSColor rgbColorRed:102 green:102 blue:102 alpha:1];
    

    [copyright.undoManager enableUndoRegistration];
    return copyright;
}

#pragma mark -

- (IUTextInputType)textInputType{
    if(self.pgContentVariable && self.pgContentVariable.length > 0){
        return IUTextInputTypeAddible;
    }
    return IUTextInputTypeEditable;
}


@end
