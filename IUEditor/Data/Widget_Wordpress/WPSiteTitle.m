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

- (id)initWithProject:(id <IUProjectProtocol>)project options:(NSDictionary *)options{
    
    self = [super initWithProject:project options:options];
    [self.undoManager disableUndoRegistration];
    
    [self.css setValue:@(300) forTag:IUCSSTagPixelWidth forViewport:IUCSSDefaultViewPort];
    [self.css eradicateTag:IUCSSTagPixelHeight];
    [self.css eradicateTag:IUCSSTagBGColor];
    
    [self.css setValue:@"Helvetica" forTag:IUCSSTagFontName forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(30) forTag:IUCSSTagFontSize forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(1.5) forTag:IUCSSTagLineHeight forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(IUAlignCenter) forTag:IUCSSTagTextAlign forViewport:IUCSSDefaultViewPort];
    [self.css setValue:[NSColor rgbColorRed:51 green:51 blue:51 alpha:1] forTag:IUCSSTagFontColor];    
    
    [self.undoManager enableUndoRegistration];
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

- (BOOL)shouldCompileFontInfo{
    return YES;
}

- (BOOL)shouldCompileChildrenForOutput{
    return NO;
}

@end
