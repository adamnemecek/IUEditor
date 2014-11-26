//
//  WPArticleComment.m
//  IUEditor
//
//  Created by seungmi on 2014. 8. 27..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "WPArticleComment.h"

@implementation WPArticleComment


#pragma mark - class attributes

+ (NSImage *)classImage{
    return [NSImage imageNamed:@"tool_page_nav"];
}

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"stack_wparticle"];
}

#pragma mark - initialize

- (id)initWithPreset{
    self = [super initWithPreset];
    if(self){
        [self.undoManager disableUndoRegistration];
        
        self.enableHCenter = YES;

        //css
        self.defaultPositionStorage.position = @(IUPositionTypeRelative);
        self.defaultPositionStorage.y = @(40);

        [self.defaultStyleStorage setWidth:@(90) unit:@(IUFrameUnitPercent)];
        self.defaultStyleStorage.height = nil;
        self.defaultStyleStorage.bgColor = nil;
        
        self.defaultStyleStorage.fontSize = @(24);
        self.defaultStyleStorage.fontLineHeight = @(1.5);
        self.defaultStyleStorage.fontAlign = @(IUAlignCenter);
        self.defaultStyleStorage.fontName = @"HelveticaNeue-Light";
        
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

-(NSString*)code{
    return @"<?php comments_template(); ?>";
}

- (NSString*)sampleInnerHTML{
    return @"Here comes title of article. Elcitra fo eltit semoc ereh.";
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
