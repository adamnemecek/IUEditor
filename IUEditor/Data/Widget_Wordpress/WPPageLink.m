//
//  WPPageLink.m
//  IUEditor
//
//  Created by jd on 8/24/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "WPPageLink.h"

@implementation WPPageLink


#pragma mark - class attributes

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"stack_page_nav"];
}

#pragma mark - initialize

- (id)initWithPreset{
    self = [super initWithPreset];
    if(self){
        [self.undoManager disableUndoRegistration];
        
        self.defaultPositionStorage.position = @(IUPositionTypeRelative);
        self.defaultStyleStorage.width = nil;
        self.defaultStyleStorage.height = nil;
        self.defaultStyleStorage.bgColor = nil;
    
        self.defaultStyleStorage.fontName = @"Roboto";
        self.defaultStyleStorage.fontSize = @(14);
        self.defaultStyleStorage.fontLineHeight = @(1.0);
        self.defaultStyleStorage.fontLetterSpacing = @(1.0);
        self.defaultStyleStorage.fontAlign = @(IUAlignRight);
        self.defaultStyleStorage.fontColor = [NSColor rgbColorRed:0 green:120 blue:220 alpha:1];
        
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

- (void)connectWithEditor{
    [super connectWithEditor];
    [self.parent.cascadingPositionStorage addObserver:self forKeyPath:@"height" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:@"height"];
}

- (void)prepareDealloc{
    if([self isConnectedWithEditor]){
        [self.parent.cascadingPositionStorage removeObserver:self forKeyPath:@"height" context:@"height"];
    }
    
}


- (NSString*)sampleInnerHTML{
    NSString *identifier = self.htmlID;
        return [NSString stringWithFormat:@"\
                <ul id='%@' class='page-numbers IUBox'>\
                <li class='WPPageLink %@'><a class='page-numbers current'>1</a></li>\
                <li class='WPPageLink %@'><a class='page-numbers' href=''>2</a></li>\
                <li class='WPPageLink %@'><a class='page-numbers' href=''>3</a></li>\
                <li class='WPPageLink %@'><a class='next page-numbers' href=''>Next &raquo;</a></li></ul>\
                ",identifier, identifier, identifier, identifier, identifier];

}


- (void)heightDidChange:(NSDictionary *)dictionary{
    [self updateCSS];
}

#pragma mark -

- (BOOL)canRemoveIUByUserInput {
    return NO;
}

- (BOOL)canChangeXByUserInput{
    return NO;
}
- (BOOL)canChangeYByUserInput{
    return NO;
}

- (BOOL)canChangeHeightByUserInput{
    return NO;
}
- (BOOL)canChangePositionType{
    return NO;
}
- (BOOL)canChangeHCenter{
    return NO;
}

@end
