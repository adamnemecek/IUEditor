//
//  WPArticleBody.m
//  IUEditor
//
//  Created by jd on 2014. 8. 7..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "WPArticleBody.h"

@implementation WPArticleBody

#pragma mark - class attributes

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"stack_wpsitedesc"];
}

#pragma mark - initialize

- (id)initWithPreset{
    self = [super initWithPreset];
    if(self){
        [self.undoManager disableUndoRegistration];
        
        //css
        self.defaultPositionStorage.position = @(IUPositionTypeRelative);
        self.defaultPositionStorage.x = nil;
        self.defaultPositionStorage.y = @(40);
        
        [self.defaultStyleStorage setWidth:@(100) unit:@(IUFrameUnitPercent)];
        self.defaultStyleStorage.height = nil;
        self.defaultStyleStorage.bgColor = nil;
        
        //font
        self.defaultStyleStorage.fontSize = @(14);
        self.defaultStyleStorage.fontLineHeight = @(2.0);
        self.defaultStyleStorage.fontAlign = @(IUAlignLeft);
        self.defaultStyleStorage.fontName = @"HelveticaNeue-Light";
        self.defaultStyleStorage.fontColor = [NSColor rgbColorRed:51 green:51 blue:51 alpha:1];
        
        //sample text
        NSString *res = [[NSBundle mainBundle] pathForResource:@"loremipsum" ofType:@"txt"];
        self.sampleText = [[NSString stringWithContentsOfFile:res encoding:NSUTF8StringEncoding error:nil] stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
        
        
        [self.undoManager enableUndoRegistration];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    [aDecoder decodeToObject:self withProperties:[WPArticleBody properties]];
    
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[WPArticleBody properties]];
}


- (id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [super initWithJDCoder:aDecoder];
    if(self){
        [self.undoManager disableUndoRegistration];
        [aDecoder decodeToObject:self withProperties:[WPArticleBody properties]];
        [self.undoManager enableUndoRegistration];
    }
    return self;
}
- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [super encodeWithJDCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[WPArticleBody properties]];
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


- (NSString*)code{
    return @"<?php the_content(); ?>";
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
