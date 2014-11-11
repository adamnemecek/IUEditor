//
//  WPWidgetTitle.m
//  IUEditor
//
//  Created by jd on 8/18/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "WPWidgetTitle.h"

@implementation WPWidgetTitle

#pragma mark - class attributes

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"stack_wpsitetitle"];
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
        [self.css setValue:@(18) forTag:IUCSSTagFontSize forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(1.5) forTag:IUCSSTagLineHeight forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(IUAlignLeft) forTag:IUCSSTagTextAlign forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@"Roboto" forTag:IUCSSTagFontName forViewport:IUCSSDefaultViewPort];
        [self.css setValue:[NSColor rgbColorRed:0 green:120 blue:220 alpha:1] forTag:IUCSSTagFontColor forViewport:IUCSSDefaultViewPort];
        
        
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

- (BOOL)canChangeHCenter{
    return NO;
}

- (NSString*)cssIdentifier{
    return [NSString stringWithFormat:@".%@ > .WPWidget > .WPWidgetTitle", self.parent.parent.htmlID];
}

-(NSString*)sampleHTML{
    return [NSString stringWithFormat:@"<h2 id='%@' class='%@'>This is Title</h2>", self.htmlID, self.cssClassStringForHTML];
}

- (BOOL)shouldCompileFontInfo{
    return YES;
}
@end
