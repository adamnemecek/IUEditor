//
//  IUFooter.m
//  IUEditor
//
//  Created by seungmi on 2014. 9. 17..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUFooter.h"

@implementation IUFooter

#pragma mark - class attributes

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"stack_footer"];
}

#pragma mark - Initialize

- (id)initWithPreset{
    self = [super initWithPreset];
    if(self){
        [self.undoManager disableUndoRegistration];
        [self setDefaultProperties];
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

- (id)initWithPreset:(IUClass *)aClass{
    self = [super initWithPreset:aClass];
    if(self){
        [self.undoManager disableUndoRegistration];
        [self setDefaultProperties];
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

- (void)setDefaultProperties{
    self.defaultStyleStorage.width = nil;
    self.defaultStyleStorage.bgColor = nil;
    [self.defaultStyleStorage setWidth:@(100) unit:@(IUFrameUnitPercent)];
    self.defaultStyleStorage.height = @(120);
    
    self.defaultPositionStorage.position = @(IUPositionTypeRelative);
    self.defaultStyleStorage.overflowType = @(IUOverflowTypeHidden);
}

-(BOOL)canRemoveIUByUserInput{
    return NO;
}

- (BOOL)canChangeOverflow{
    return NO;
}
- (BOOL)canChangePositionType{
    return NO;
}

- (BOOL)shouldCompileX{
    return NO;
}

- (BOOL)shouldCompileY{
    return NO;
}

- (BOOL)shouldCompileWidth{
    return YES;
}

- (BOOL)canChangeXByUserInput{
    return NO;
}

- (BOOL)canChangeYByUserInput{
    return NO;
}

- (BOOL)canChangeWidthByUserInput{
    return NO;
}

- (BOOL)canChangeHeightByUserInput{
    return NO;
}
- (BOOL)canCopy{
    return NO;
}

@end
