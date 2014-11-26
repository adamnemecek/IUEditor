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
- (id)initWithPreset{
    self = [super initWithPreset];
    if(self){
        [self.undoManager disableUndoRegistration];
        
        //css
        self.defaultPositionStorage.position = @(IUPositionTypeRelative);
        self.defaultPositionStorage.y = @(80);
        
        [self.defaultStyleStorage setWidth:@(90) unit:@(IUFrameUnitPercent)];
        self.defaultStyleStorage.height = nil;
        self.defaultStyleStorage.bgColor = nil;
        
        self.enableHCenter = YES;
        
        self.defaultStyleStorage.fontSize = @(21);
        self.defaultStyleStorage.fontLineHeight = @(1.5);
        self.defaultStyleStorage.fontAlign = @(IUAlignCenter);
        self.defaultStyleStorage.fontName = @"HelveticaNeue-Light";
                
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

-(NSString*)code{
    return @"<a href=\"<?php the_permalink(); ?>\"><?php the_title(); ?></a>";
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

- (BOOL)shouldCompileChildrenForOutput{
    return NO;
}

@end
