//
//  WPWidgetBody.m
//  IUEditor
//
//  Created by jd on 8/18/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "WPWidgetBody.h"

@implementation WPWidgetBody

#pragma mark - class attributes

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"stack_wpsitedesc"];
}

#pragma mark - initialize

- (id)initWithProject:(id <IUProjectProtocol>)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    if(self){
        [self.undoManager disableUndoRegistration];
        
        //setting for css
        [self setPositionType:IUPositionTypeRelative];
        
        [self.css setValue:@(0) forTag:IUCSSTagPixelX forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(40) forTag:IUCSSTagPixelY forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(YES) forTag:IUCSSTagWidthUnitIsPercent forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(100) forTag:IUCSSTagPercentWidth forViewport:IUCSSDefaultViewPort];
        [self.css eradicateTag:IUCSSTagPixelHeight];
        [self.css eradicateTag:IUCSSTagBGColor];
        
        //font css
        [self.css setValue:@(14) forTag:IUCSSTagFontSize forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(2.0) forTag:IUCSSTagLineHeight forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(IUAlignLeft) forTag:IUCSSTagTextAlign forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@"Roboto" forTag:IUCSSTagFontName forViewport:IUCSSDefaultViewPort];
        [self.css setValue:[NSColor rgbColorRed:51 green:51 blue:51 alpha:1] forTag:IUCSSTagFontColor forViewport:IUCSSDefaultViewPort];
        
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

- (NSString*)cssIdentifier{
    return [NSString stringWithFormat:@".%@ > .WPWidget > ul", self.parent.parent.htmlID];
}

- (NSString *)sampleHTML{
    return [NSString stringWithFormat:@"<ul id='%@' class='%@'><li class='cat-item cat-item-1'>First Line</li><li class='cat-item cat-item-2'>Second Line</li></ul>", self.htmlID, self.cssClassStringForHTML];
}

- (BOOL)canMoveToOtherParent{
    return NO;
}

- (BOOL)canRemoveIUByUserInput{
    return NO;
}
- (BOOL)shouldCompileFontInfo{
    return YES;
}

@end
