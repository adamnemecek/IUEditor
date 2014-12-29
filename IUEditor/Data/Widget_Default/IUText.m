//
//  IUText.m
//  IUEditor
//
//  Created by seungmi on 2014. 11. 25..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUText.h"

NSString * const IUTextContentKey = @"TextContentKey";

@implementation IUText

+ (NSString *)widgetType{
    return kIUWidgetTypePrimary;
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
    
    copyright.defaultStyleStorage.width = nil;
    copyright.defaultStyleStorage.height = nil;
    
    copyright.defaultStyleStorage.fontName = @"Roboto";
    copyright.defaultStyleStorage.fontSize = @(12);
    copyright.defaultStyleStorage.fontLineHeight = @(1.5);
    copyright.defaultStyleStorage.fontAlign = @(IUAlignCenter);
    copyright.defaultStyleStorage.fontColor = [NSColor rgbColorRed:102 green:102 blue:102 alpha:1];
    

    [copyright.undoManager enableUndoRegistration];
    return copyright;
}


#pragma mark - initialize

- (id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [super initWithJDCoder:aDecoder];
    if(self){
        [self.undoManager disableUndoRegistration];
        [aDecoder decodeToObject:self withProperties:[[IUText class] properties]];
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [super encodeWithJDCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[[IUText class] properties]];
}

- (id)copyWithZone:(NSZone *)zone{
    [self.undoManager disableUndoRegistration];
    
    IUText *copy =  [super copyWithZone:zone];
    copy.textType = _textType;
    
    [self.undoManager enableUndoRegistration];
    return copy;
}

#pragma mark - properties

- (BOOL)canAddIUByUserInput{
    return NO;
}

- (void)setTextType:(IUTextType)textType{
    if(_textType != textType){
        [[self.undoManager prepareWithInvocationTarget:self] setTextType:_textType];
        _textType = textType;
        [self updateHTML];
    }
}

- (IUTextInputType)textInputType{
     if(self.pgContentVariable && self.pgContentVariable.length > 0){
        return IUTextInputTypeAddible;
    }
    return IUTextInputTypeEditable;
}



@end
