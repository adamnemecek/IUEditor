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

+ (IUWidgetType)widgetType{
    return IUWidgetTypePG;
}


#pragma mark - initialize

- (id)initWithProject:(id <IUProjectProtocol>)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
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

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[[self class] properties]];
}


- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];

    [aDecoder decodeToObject:self withProperties:[[self class] properties]];
    _buttonMargin = 2;
    
    return self;
}


- (id)copyWithZone:(NSZone *)zone{
    PGPageLinkSet *iu = [super copyWithZone:zone];
    [[self undoManager] disableUndoRegistration];
    [_canvasVC disableUpdateAll:self];


    iu.pageCountVariable = [_pageCountVariable copy];
    iu.pageLinkAlign = _pageLinkAlign;
    iu.selectedButtonBGColor = [_selectedButtonBGColor copy];
    iu.defaultButtonBGColor = [_defaultButtonBGColor copy];
    iu.buttonMargin = _buttonMargin;
    
    [_canvasVC enableUpdateAll:self];
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

- (BOOL)shouldCompileFontInfo{
    return YES;
}

#pragma mark - css

- (void)updateCSS{
    [super updateCSS];
    if(_canvasVC){
        [_canvasVC callWebScriptMethod:@"resizePageLinkSet" withArguments:nil];
    }
}
- (void)updateCSSWithIdentifiers:(NSArray *)identifiers{
    [super updateCSSWithIdentifiers:identifiers];
    if(_canvasVC){
        [_canvasVC callWebScriptMethod:@"resizePageLinkSet" withArguments:nil];
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