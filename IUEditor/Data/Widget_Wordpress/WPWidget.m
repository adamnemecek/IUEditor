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

- (id)initWithPreset{
    self = [super initWithPreset];
    if (self) {
        [self.undoManager disableUndoRegistration];

        //setting for css
        self.defaultStyleStorage.height = nil;
        self.defaultStyleStorage.bgColor = nil;

        //setting children
        self.titleWidget = [[WPWidgetTitle alloc] initWithPreset];
        [self addIU:self.titleWidget error:nil];
        
        self.bodyWidget = [[WPWidgetBody alloc] initWithPreset];
        [self addIU:self.bodyWidget error:nil];
        
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

- (id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [super initWithJDCoder:aDecoder];
    if(self){
        [self.undoManager disableUndoRegistration];
        [aDecoder decodeToObject:self withProperties:[WPWidget properties]];
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [super encodeWithJDCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[WPWidget properties]];
}



- (id)copyWithZone:(NSZone *)zone{
    WPWidget *widget = [super copyWithZone:zone];
    widget.titleWidget = widget.children[0];
    widget.bodyWidget = widget.children[1];
    return widget;
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
