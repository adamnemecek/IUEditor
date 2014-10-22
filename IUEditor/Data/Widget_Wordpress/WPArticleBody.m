//
//  WPArticleBody.m
//  IUEditor
//
//  Created by jd on 2014. 8. 7..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "WPArticleBody.h"

@implementation WPArticleBody

- (id)initWithProject:(IUProject *)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    [self.undoManager disableUndoRegistration];
    
    //css
    self.positionType = IUPositionTypeRelative;
    
    [self.css setValue:@(0) forTag:IUCSSTagPixelX forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(40) forTag:IUCSSTagPixelY forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(YES) forTag:IUCSSTagWidthUnitIsPercent forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(100) forTag:IUCSSTagPercentWidth forViewport:IUCSSDefaultViewPort];
    [self.css eradicateTag:IUCSSTagPixelHeight];
    [self.css eradicateTag:IUCSSTagBGColor];


    //font
    [self.css setValue:@(14) forTag:IUCSSTagFontSize forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(2.0) forTag:IUCSSTagLineHeight forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(IUAlignLeft) forTag:IUCSSTagTextAlign forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@"HelveticaNeue-Light" forTag:IUCSSTagFontName forViewport:IUCSSDefaultViewPort];
    [self.css setValue:[NSColor rgbColorRed:51 green:51 blue:51 alpha:1] forTag:IUCSSTagFontColor forViewport:IUCSSDefaultViewPort];

    
    //sample text
    NSString *res = [[NSBundle mainBundle] pathForResource:@"loremipsum" ofType:@"txt"];
    self.sampleText = [[NSString stringWithContentsOfFile:res encoding:NSUTF8StringEncoding error:nil] stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
    
    
    [self.undoManager enableUndoRegistration];
    return self;
}

- (void)setSampleText:(NSString *)sampleText{
    if ([sampleText length] == 0) {
        NSString *res = [[NSBundle mainBundle] pathForResource:@"loremipsum" ofType:@"txt"];
        _sampleText = [[NSString stringWithContentsOfFile:res encoding:NSUTF8StringEncoding error:nil] stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
    }
    else {
        _sampleText = sampleText;
    }
    [self updateHTML];
}

- (NSString*)sampleInnerHTML{
    return [NSString stringWithFormat:@"<p>%@</p>", _sampleText];
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[WPArticleBody properties]];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    [self.undoManager disableUndoRegistration];
        [aDecoder decodeToObject:self withProperties:[WPArticleBody properties]];
    
    [self.undoManager enableUndoRegistration];
    return self;
}

- (NSString*)code{
    return @"<?php the_content(); ?>";
}

- (BOOL)shouldCompileFontInfo{
    return YES;
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
