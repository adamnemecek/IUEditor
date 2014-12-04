//
//  PGPageLinkSet.m
//  IUEditor
//
//  Created by jd on 5/8/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "PGPageLinkSet.h"

@implementation PGPageLinkSet

#pragma mark - class attributes

+ (NSImage *)classImage{
    return [NSImage imageNamed:@"tool_page_nav"];
}

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"stack_page_nav"];
}

+ (NSString *)widgetType{
    return kIUWidgetTypeProgramming;
}


#pragma mark - initialize

- (id)initWithPreset{
    self = [super initWithPreset];
    [[self undoManager] disableUndoRegistration];

    if(self){
        _pageLinkAlign = IUAlignCenter;
        _selectedButtonBGColor = [NSColor rgbColorRed:50 green:50 blue:50 alpha:0.5];
        _defaultButtonBGColor = [NSColor rgbColorRed:50 green:50 blue:50 alpha:0.5];
        _buttonMargin = 5.0f;
    }
    
    [[self undoManager] enableUndoRegistration];

    return self;
}


- (id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [super initWithJDCoder:aDecoder];
    if (self) {
        [self.undoManager disableUndoRegistration];
        [aDecoder decodeToObject:self withProperties:[PGPageLinkSet properties]];
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [super encodeWithJDCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[PGPageLinkSet properties]];
}



- (id)copyWithZone:(NSZone *)zone{
    PGPageLinkSet *iu = [super copyWithZone:zone];
    [[self undoManager] disableUndoRegistration];


    iu.pageCountVariable = [_pageCountVariable copy];
    iu.pageLinkAlign = _pageLinkAlign;
    iu.selectedButtonBGColor = [_selectedButtonBGColor copy];
    iu.defaultButtonBGColor = [_defaultButtonBGColor copy];
    iu.buttonMargin = _buttonMargin;
    
    [[self undoManager] enableUndoRegistration];

    return iu;
}


- (void)setPageLinkAlign:(IUAlign)pageLinkAlign{
    if (_pageLinkAlign == pageLinkAlign) {
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setPageLinkAlign:_pageLinkAlign];
    
    _pageLinkAlign = pageLinkAlign;
    [self updateCSSWithIdentifiers:@[self.clipIdentifier]];

}

- (void)setSelectedButtonBGColor:(NSColor *)selectedButtonBGColor{
    
    if([_selectedButtonBGColor isEqualTo:selectedButtonBGColor]){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setSelectedButtonBGColor:_selectedButtonBGColor];
    
    _selectedButtonBGColor = selectedButtonBGColor;
    [self updateCSSWithIdentifiers:@[self.activeIdentifier, self.hoverIdentifier]];
}

- (void)setDefaultButtonBGColor:(NSColor *)defaultButtonBGColor{
    
    if([_defaultButtonBGColor isEqualTo:defaultButtonBGColor]){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setDefaultButtonBGColor:_defaultButtonBGColor];
    
    _defaultButtonBGColor = defaultButtonBGColor;
    [self updateCSSWithIdentifiers:@[self.itemIdentifier]];
}

- (void)setButtonMargin:(float)buttonMargin{
    
    if(_buttonMargin != buttonMargin){
    
        [[self.undoManager prepareWithInvocationTarget:self] setButtonMargin:_buttonMargin];
        
        _buttonMargin = buttonMargin;
        [self updateCSSWithIdentifiers:@[self.itemIdentifier]];
    }
}
#pragma mark - shouldXXX

- (BOOL)canAddIUByUserInput{
    return NO;
}

#pragma mark - css

- (void)updateCSS{
    [super updateCSS];
    if(self.sourceManager){
        [self.sourceManager callWebScriptMethod:@"resizePageLinkSet" withArguments:nil];
    }
}
- (void)updateCSSWithIdentifiers:(NSArray *)identifiers{
    [super updateCSSWithIdentifiers:identifiers];
    if(self.sourceManager){
        [self.sourceManager callWebScriptMethod:@"resizePageLinkSet" withArguments:nil];
    }
}
- (NSArray *)cssIdentifierArray{
    return [[super cssIdentifierArray] arrayByAddingObjectsFromArray:@[self.clipIdentifier, self.activeIdentifier, self.hoverIdentifier, self.hoverIdentifier, self.itemIdentifier]];
}

- (NSString *)clipIdentifier{
    return [self.cssIdentifier stringByAppendingString:@" > div"];
}
- (NSString *)activeIdentifier{
    return [self.cssIdentifier stringByAppendingString:@" selected > div > ul > a > li"];
}
- (NSString *)hoverIdentifier{
    return [self.cssIdentifier stringByAppendingString:@" > div > ul > a > li:hover"];
}
- (NSString *)itemIdentifier{
    return [self.cssIdentifier stringByAppendingString:@" > div > ul > a > li"];
}

@end