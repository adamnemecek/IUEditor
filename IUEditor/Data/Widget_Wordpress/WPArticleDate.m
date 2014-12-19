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

#pragma mark - class attributes

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"stack_wparticledate"];
}

#pragma mark - initialize

- (id)initWithPreset{
    self = [super initWithPreset];
    
    if(self){
        [self.undoManager disableUndoRegistration];

        self.enableHCenter = YES;
        
        self.defaultPositionStorage.firstPosition = @(IUFirstPositionTypeRelative);
        self.defaultPositionStorage.y = @(10);
        
        [self.defaultStyleStorage setWidth:@(30) unit:@(IUFrameUnitPercent)];
        
        self.defaultStyleStorage.fontSize = @(14);
        self.defaultStyleStorage.fontLineHeight = @(2.0);
        self.defaultStyleStorage.fontAlign = @(IUAlignCenter);
        self.defaultStyleStorage.fontName = @"HelveticaNeue-Light";
        self.defaultStyleStorage.fontColor = [NSColor rgbColorRed:137 green:137 blue:137 alpha:1];
        
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

-(NSString*)code{
    return @"<?php echo get_the_date(); ?>";
}

- (NSString*)sampleInnerHTML{
    return @"Dec. 24. 2014.";
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
