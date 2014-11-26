//
//  WPWidgetTitle.m
//  IUEditor
//
//  Created by jd on 8/18/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "WPWidgetTitle.h"

@implementation WPWidgetTitle

#pragma mark - class attributes

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"stack_wpsitetitle"];
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
        self.defaultStyleStorage.fontSize = @(18);
        self.defaultStyleStorage.fontLineHeight = @(1.5);
        self.defaultStyleStorage.fontAlign = @(IUAlignLeft);
        self.defaultStyleStorage.fontName = @"Roboto";
        self.defaultStyleStorage.fontColor = [NSColor rgbColorRed:0 green:120 blue:220 alpha:1];
        
        
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

- (BOOL)canChangeHCenter{
    return NO;
}

- (NSString*)cssIdentifier{
    return [NSString stringWithFormat:@".%@ > .WPWidget > .WPWidgetTitle", self.parent.parent.htmlID];
}

-(NSString*)sampleHTML{
    return [NSString stringWithFormat:@"<h2 id='%@' class='%@'>This is Title</h2>", self.htmlID, self.cssClassStringForHTML];
}

@end
