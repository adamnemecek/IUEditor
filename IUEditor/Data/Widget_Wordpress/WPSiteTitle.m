//
//  WPSiteTitle.m
//  IUEditor
//
//  Created by jd on 2014. 7. 14..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "WPSiteTitle.h"

@implementation WPSiteTitle


#pragma mark - class attributes

+ (NSImage *)classImage{
    return [NSImage imageNamed:@"wp_sitetitle"];
}

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"stack_wpsitetitle"];
}

+ (IUWidgetType)widgetType{
    return IUWidgetTypeWP;
}


#pragma mark - initialize

- (id)initWithPreset{
    
    self = [super initWithPreset];
    if(self){
        [self.undoManager disableUndoRegistration];
        
        self.defaultStyleStorage.width = @(300);
        self.defaultStyleStorage.height = nil;
        self.defaultStyleStorage.bgColor = nil;
        
        self.defaultStyleStorage.fontName = @"Helvetica";
        self.defaultStyleStorage.fontSize = @(30);
        self.defaultStyleStorage.fontLineHeight = @(1.5);
        self.defaultStyleStorage.fontAlign = @(IUAlignCenter);
        self.defaultStyleStorage.fontColor = [NSColor rgbColorRed:51 green:51 blue:51 alpha:1];
        
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

- (NSString*)sampleInnerHTML{
    return @"Site Title";
}

- (NSString*)code{
    return @"<h1><a href=\"<?php echo home_url(); ?>\"><?bloginfo()?></a></h1>";
}

- (BOOL)canAddIUByUserInput{
    return NO;
}


- (BOOL)shouldCompileChildrenForOutput{
    return NO;
}

@end
