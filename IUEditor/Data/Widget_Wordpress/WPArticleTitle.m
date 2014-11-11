//
//  WPArticleTitle.m
//  IUEditor
//
//  Created by jd on 2014. 7. 15..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "WPArticleTitle.h"

@implementation WPArticleTitle

#pragma mark - class attributes

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
    
    //css
    self.positionType = IUPositionTypeRelative;
    
    [self.css setValue:@(80) forTag:IUCSSTagPixelY forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(YES) forTag:IUCSSTagWidthUnitIsPercent forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(90) forTag:IUCSSTagPercentWidth forViewport:IUCSSDefaultViewPort];
    [self.css eradicateTag:IUCSSTagPixelHeight];
    [self.css eradicateTag:IUCSSTagBGColor];
    
    self.enableHCenter = YES;
    
    [self.css setValue:@(21) forTag:IUCSSTagFontSize forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(1.5) forTag:IUCSSTagLineHeight forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(IUAlignCenter) forTag:IUCSSTagTextAlign forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@"HelveticaNeue-Light" forTag:IUCSSTagFontName forViewport:IUCSSDefaultViewPort];
    
    [self.undoManager enableUndoRegistration];
    return self;
}

-(NSString*)code{
    return @"<a href=\"<?php the_permalink(); ?>\"><?php the_title(); ?></a>";
}

- (NSString*)sampleInnerHTML{
    return @"Here comes title of article. Elcitra fo eltit semoc ereh.";
}

- (BOOL)shouldCompileFontInfo{
    return YES;
}

- (BOOL)canMoveToOtherParent{
    return NO;
}

- (BOOL)canCopy{
    return NO;
}

- (BOOL)canRemoveIUByUserInput{
    return NO;
}

- (BOOL)shouldCompileChildrenForOutput{
    return NO;
}

@end
