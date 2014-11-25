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

- (id)initWithProject:(id <IUProjectProtocol>)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    if(self){
        
        [self.undoManager disableUndoRegistration];
        
        [self.css setValue:@(0) forTag:IUCSSTagXUnitIsPercent forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(0) forTag:IUCSSTagYUnitIsPercent forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(1) forTag:IUCSSTagWidthUnitIsPercent forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(0) forTag:IUCSSTagHeightUnitIsPercent forViewport:IUCSSDefaultViewPort];
        
        [self.css setValue:@(100) forTag:IUCSSTagPercentWidth forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(500) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(0) forTag:IUCSSTagPixelX forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(0) forTag:IUCSSTagPixelY forViewport:IUCSSDefaultViewPort];
        
        self.positionType = IUPositionTypeRelative;
        
        [self.undoManager enableUndoRegistration];
     }
    return self;
}

- (id)initWithPreset{
    self = [super initWithPreset];
    if(self){
        [self.undoManager disableUndoRegistration];
        self.liveStyleStorage.height = @(500);
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self =  [super initWithCoder:aDecoder];
    if(self){
        [aDecoder decodeToObject:self withProperties:[[IUSection class] properties]];        
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
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
    if(_enableFullSize){
        return NO;
    }
    return [super canChangeHeightByUserInput];
}

- (void)setEnableFullSize:(BOOL)enableFullSize{
    [self willChangeValueForKey:@"canChangeHeightByUserInput"];
    
    [[self.undoManager prepareWithInvocationTarget:self] setEnableFullSize:_enableFullSize];
    _enableFullSize = enableFullSize;
    
    if(_enableFullSize){
        [self.css eradicateTag:IUCSSTagPixelHeight];
        [self.css eradicateTag:IUCSSTagPercentHeight];
    }
    
    [self didChangeValueForKey:@"canChangeHeightByUserInput"];
}

@end
