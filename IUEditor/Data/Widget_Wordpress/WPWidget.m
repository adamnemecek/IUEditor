//
//  WPWidget.m
//  IUEditor
//
//  Created by jd on 8/16/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "WPWidget.h"

@implementation WPWidget

#pragma mark - class attributes

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"stack_wparticle"];
}

#pragma mark - initialize

- (id)initWithProject:(id <IUProjectProtocol>)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    if (self) {
        [self.undoManager disableUndoRegistration];

        //setting for css
        [self.css eradicateTag:IUCSSTagPixelHeight];
        [self.css eradicateTag:IUCSSTagBGColor];

        //setting children
        self.titleWidget = [[WPWidgetTitle alloc] initWithProject:project options:options];
        [self addIU:self.titleWidget error:nil];
        
        self.bodyWidget = [[WPWidgetBody alloc] initWithProject:project options:options];
        [self addIU:self.bodyWidget error:nil];
        
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone{
    WPWidget *widget = [super copyWithZone:zone];
    widget.titleWidget = widget.children[0];
    widget.bodyWidget = widget.children[1];
    return widget;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    [self.undoManager disableUndoRegistration];
    [aDecoder decodeToObject:self withProperties:[WPWidget properties]];
    [self.undoManager enableUndoRegistration];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[WPWidget properties]];
}


- (BOOL)shouldCompileX{
    return NO;
}

- (BOOL)shouldCompileY{
    return NO;
}

- (BOOL)shouldCompileWidth{
    return NO;
}

- (BOOL)shouldCompileHeight{
    return NO;
}

//자기 자신대신 parent를 옮기는 경우
- (BOOL)shouldMoveParent{
    return YES;
}

- (NSString*)cssIdentifier{
    return [NSString stringWithFormat:@".%@ > .WPWidget", self.parent.htmlID];
}


- (NSString*)sampleHTML{
    NSString *ret =  [NSString stringWithFormat:@"<div id ='%@' class='%@'>%@%@</div>", self.htmlID, self.cssClassStringForHTML, self.titleWidget.sampleHTML, self.bodyWidget.sampleHTML];
    return ret;
}

@end
