//
//  WPSiteDescription.m
//  IUEditor
//
//  Created by jd on 2014. 7. 14..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "WPSiteDescription.h"

@implementation WPSiteDescription

#pragma mark - class attributes

+ (NSImage *)classImage{
    return [NSImage imageNamed:@"wp_sitedesc"];
}

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"stack_wpsitedesc"];
}

+ (NSString *)widgetType{
    return kIUWidgetTypeWordpress;
}


#pragma mark - initialize

- (id)initWithPreset{
    self = [super initWithPreset];
    if(self){
        [self.undoManager disableUndoRegistration];
        self.enableHCenter = YES;

        self.defaultStyleStorage.width = @(450);
        self.defaultStyleStorage.height = nil;
        
        self.defaultStyleStorage.fontSize = @(12);
        self.defaultStyleStorage.fontLineHeight = @(1.5);
        self.defaultStyleStorage.fontAlign = @(IUAlignCenter);
        self.defaultStyleStorage.fontColor = [NSColor rgbColorRed:76 green:76 blue:76 alpha:1];
        
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

- (NSString*)sampleInnerHTML{
    return @"This is Site Description. Contact j@jdlab.org for more information.";
}

- (NSString*)code{
    return @"<?bloginfo('description')?>";
}

- (BOOL)shouldCompileChildrenForOutput{
    return NO;
}

@end
