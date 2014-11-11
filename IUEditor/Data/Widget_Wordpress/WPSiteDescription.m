//
//  WPSiteDescription.m
//  IUEditor
//
//  Created by jd on 2014. 7. 14..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "WPSiteDescription.h"

@implementation WPSiteDescription

- (id)initWithProject:(id <IUProjectProtocol>)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    [self.undoManager disableUndoRegistration];
    [self.css setValue:@(450) forTag:IUCSSTagPixelWidth forViewport:IUCSSDefaultViewPort];
    [self.css eradicateTag:IUCSSTagPixelHeight];
    [self.css eradicateTag:IUCSSTagBGColor];
    
    self.enableHCenter = YES;
    
    [self.css setValue:@(12) forTag:IUCSSTagFontSize forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(1.5) forTag:IUCSSTagLineHeight forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(IUAlignCenter) forTag:IUCSSTagTextAlign forViewport:IUCSSDefaultViewPort];
    [self.css setValue:[NSColor rgbColorRed:76 green:76 blue:76 alpha:1] forTag:IUCSSTagFontColor forViewport:IUCSSDefaultViewPort];
    
    [self.undoManager enableUndoRegistration];
    return self;
}

- (NSString*)sampleInnerHTML{
    return @"This is Site Description. Contact j@jdlab.org for more information.";
}

- (NSString*)code{
    return @"<?bloginfo('description')?>";
}

- (BOOL)shouldCompileFontInfo{
    return YES;
}

- (BOOL)shouldCompileChildrenForOutput{
    return NO;
}

@end
