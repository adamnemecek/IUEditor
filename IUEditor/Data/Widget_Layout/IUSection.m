//
//  IUResponsiveSection.m
//  IUEditor
//
//  Created by jd on 4/24/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUSection.h"

@implementation IUSection

#pragma mark - class attributes

+ (NSImage *)classImage{
    return [NSImage imageNamed:@"tool_collection"];
}

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"stack_section"];
}

#pragma mark - Initialize

- (id)initWithPreset{
    self = [super initWithPreset];
    if(self){
        
        [self.undoManager disableUndoRegistration];
        
        self.defaultPositionStorage.firstPosition = @(IUFirstPositionTypeRelative);
        self.defaultPositionStorage.x = nil;
        self.defaultPositionStorage.y = nil;
        
        [self.defaultStyleStorage setWidth:@(100) unit:@(IUFrameUnitPercent)];
        self.defaultStyleStorage.height = @(500);

        
        [self.undoManager enableUndoRegistration];
     }
    return self;
}

-(id)initWithJDCoder:(JDCoder *)aDecoder{
    self =  [super initWithJDCoder:aDecoder];
    if(self){
        [self.undoManager disableUndoRegistration];
        [aDecoder decodeToObject:self withProperties:[[IUSection class] properties]];
        [self.undoManager enableUndoRegistration];
    }
    return self;
}
-(void)encodeWithJDCoder:(JDCoder *)aCoder{
    [super encodeWithJDCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[[IUSection class] properties]];
    
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

- (BOOL)canChangePositionType{
    return NO;
}

- (BOOL)canChangeHeightByUserInput{
    if(_heightAsWindowHeight){
        return NO;
    }
    return [super canChangeHeightByUserInput];
}

- (void)setHeightAsWindowHeight:(BOOL)heightAsWindowHeight{
    [self willChangeValueForKey:@"canChangeHeightByUserInput"];
    
    [[self.undoManager prepareWithInvocationTarget:self] setHeightAsWindowHeight:_heightAsWindowHeight];
    _heightAsWindowHeight = heightAsWindowHeight;
    
    if(_heightAsWindowHeight){
        self.defaultStyleStorage.height = nil;
    }
    
    [self didChangeValueForKey:@"canChangeHeightByUserInput"];
}

@end
