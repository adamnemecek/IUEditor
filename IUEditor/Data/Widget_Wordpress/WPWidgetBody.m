//
//  WPWidgetBody.m
//  IUEditor
//
//  Created by jd on 8/18/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "WPWidgetBody.h"

@implementation WPWidgetBody

#pragma mark - class attributes

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"stack_wpsitedesc"];
}

#pragma mark - initialize

- (id)initWithPreset{
    self = [super initWithPreset];
    if(self){
        [self.undoManager disableUndoRegistration];
        
        //setting for css
        self.defaultPositionStorage.position = @(IUPositionTypeRelative);
        self.defaultPositionStorage.x = nil;
        self.defaultPositionStorage.y = @(40);
        
        [self.defaultStyleStorage setWidth:@(100) unit:@(IUFrameUnitPercent)];
        self.defaultStyleStorage.height = nil;
        self.defaultStyleStorage.bgColor = nil;
        
        //font css
        self.defaultStyleStorage.fontSize = @(14);
        self.defaultStyleStorage.fontLineHeight = @(2.0);
        self.defaultStyleStorage.fontAlign = @(IUAlignLeft);
        self.defaultStyleStorage.fontName = @"Roboto";
        self.defaultStyleStorage.fontColor = [NSColor rgbColorRed:51 green:51 blue:51 alpha:1];
        
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

- (NSString*)cssIdentifier{
    return [NSString stringWithFormat:@".%@ > .WPWidget > ul", self.parent.parent.htmlID];
}

- (NSString *)sampleHTML{
    return [NSString stringWithFormat:@"<ul id='%@' class='%@'><li class='cat-item cat-item-1'>First Line</li><li class='cat-item cat-item-2'>Second Line</li></ul>", self.htmlID, self.cssClassStringForHTML];
}

- (BOOL)canMoveToOtherParent{
    return NO;
}

- (BOOL)canRemoveIUByUserInput{
    return NO;
}

@end
