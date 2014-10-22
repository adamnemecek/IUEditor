//
//  WPArticleDate.m
//  IUEditor
//
//  Created by jd on 2014. 7. 16..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "WPArticleDate.h"
#import "WPArticle.h"

@implementation WPArticleDate

- (id)initWithProject:(IUProject *)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    [self.undoManager disableUndoRegistration];
    
    //css
    self.positionType = IUPositionTypeRelative;
    
    [self.css setValue:@(10) forTag:IUCSSTagPixelY forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(YES) forTag:IUCSSTagWidthUnitIsPercent forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(30) forTag:IUCSSTagPercentWidth forViewport:IUCSSDefaultViewPort];
    [self.css eradicateTag:IUCSSTagPixelHeight];
    [self.css eradicateTag:IUCSSTagBGColor];

    
    self.enableHCenter = YES;
    
    [self.css setValue:@(14) forTag:IUCSSTagFontSize forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(2.0) forTag:IUCSSTagLineHeight forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(IUAlignCenter) forTag:IUCSSTagTextAlign forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@"HelveticaNeue-Light" forTag:IUCSSTagFontName forViewport:IUCSSDefaultViewPort];
    [self.css setValue:[NSColor rgbColorRed:137 green:137 blue:137 alpha:1] forTag:IUCSSTagFontColor forViewport:IUCSSDefaultViewPort];


    [self.undoManager enableUndoRegistration];
    return self;
}

-(NSString*)code{
    return @"<?php echo get_the_date(); ?>";
}

- (NSString*)sampleInnerHTML{
    return @"Dec. 24. 2014.";
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
