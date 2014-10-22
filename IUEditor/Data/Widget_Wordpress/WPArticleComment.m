//
//  WPArticleComment.m
//  IUEditor
//
//  Created by seungmi on 2014. 8. 27..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "WPArticleComment.h"

@implementation WPArticleComment

- (id)initWithProject:(IUProject *)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    [self.undoManager disableUndoRegistration];
    
    //css
    self.positionType = IUPositionTypeRelative;
    
    [self.css setValue:@(40) forTag:IUCSSTagPixelY];
    [self.css setValue:@(YES) forTag:IUCSSTagWidthUnitIsPercent];
    [self.css setValue:@(90) forTag:IUCSSTagPercentWidth];
    [self.css eradicateTag:IUCSSTagPixelHeight];
    [self.css eradicateTag:IUCSSTagBGColor];
    
    self.enableHCenter = YES;
    
    [self.css setValue:@(24) forTag:IUCSSTagFontSize];
    [self.css setValue:@(1.5) forTag:IUCSSTagLineHeight];
    [self.css setValue:@(IUAlignCenter) forTag:IUCSSTagTextAlign];
    [self.css setValue:@"HelveticaNeue-Light" forTag:IUCSSTagFontName];
    
    [self.undoManager enableUndoRegistration];
    return self;
}

-(NSString*)code{
    return @"<?php comments_template(); ?>";
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

@end
