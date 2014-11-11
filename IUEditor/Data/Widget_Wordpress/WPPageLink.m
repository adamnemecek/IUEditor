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

- (id)initWithProject:(id <IUProjectProtocol>)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    [self.undoManager disableUndoRegistration];
    
    self.positionType = IUPositionTypeRelative;
    
    [self.css eradicateTag:IUCSSTagPixelWidth];
    [self.css eradicateTag:IUCSSTagPixelHeight];
    [self.css eradicateTag:IUCSSTagBGColor];
    
    
    [self.css setValue:@"Roboto" forTag:IUCSSTagFontName forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(14) forTag:IUCSSTagFontSize forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(1.0) forTag:IUCSSTagLineHeight forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(1.0) forTag:IUCSSTagTextLetterSpacing forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(IUAlignRight) forTag:IUCSSTagTextAlign forViewport:IUCSSDefaultViewPort];
    [self.css setValue:[NSColor rgbColorRed:0 green:120 blue:220 alpha:1] forTag:IUCSSTagFontColor forViewport:IUCSSDefaultViewPort];

    
    [self.undoManager enableUndoRegistration];
    return self;
}

- (void)connectWithEditor{
    [super connectWithEditor];
    [self.parent.css.effectiveTagDictionary addObserver:self forKeyPath:@"height" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:@"height"];
}

- (void)prepareDealloc{
    if([self isConnectedWithEditor]){
        [self.parent.css.effectiveTagDictionary removeObserver:self forKeyPath:@"height" context:@"height"];
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

- (BOOL)shouldCompileFontInfo{
    return YES;
}

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
