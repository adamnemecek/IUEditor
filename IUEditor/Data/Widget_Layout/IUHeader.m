//
//  IUHeader.m
//  IUEditor
//
//  Created by JD on 3/31/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUHeader.h"
#import "IUProject.h"

@implementation IUHeader

#pragma mark - class attributes

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"stack_header"];
}

#pragma mark - Initialize

- (id)initWithPreset{
    self = [super initWithPreset];
    if(self){
        [self.undoManager disableUndoRegistration];
        [self setDefaultPropertiesHeader];
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

- (id)initWithPreset:(IUClass *)aClass{
    self = [super initWithPreset:aClass];
    if(self){
        [self.undoManager disableUndoRegistration];
        [self setDefaultPropertiesHeader];
        [self.undoManager enableUndoRegistration];
    }
    return self;
}
- (void)setDefaultPropertiesHeader{
    self.defaultStyleStorage.bgColor = nil;
    
    [self.defaultStyleStorage setWidth:@(100) unit:@(IUFrameUnitPercent)];
    self.defaultStyleStorage.height = @(120);
    self.defaultStyleStorage.overflowType = @(IUOverflowTypeVisible);
    
    self.defaultPositionStorage.position = @(IUPositionTypeRelative);
    
}

#pragma mark - property

- (void)setPrototypeClass:(IUClass *)prototypeClass{
    [super setPrototypeClass:prototypeClass];
    
    //for version converting for document befor IU_VERSION_LAYOUT
    if(self.isConnectedWithEditor && prototypeClass == nil){
        [_m_children removeAllObjects];
    }
}

- (NSArray*)children{
    if (self.prototypeClass == nil) {
        //for version converting for document befor IU_VERSION_LAYOUT
        if(_m_children.count > 0){
            return _m_children;
        }
        
        return [NSArray array];
    }
    return @[self.prototypeClass];
}

#pragma mark - should

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
