//
//  PGForm.m
//  IUEditor
//
//  Created by jd on 5/7/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "PGForm.h"

@implementation PGForm

#pragma mark - class attributes

+ (NSImage *)classImage{
    return [NSImage imageNamed:@"tool_form"];
}

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"stack_form"];
}

+ (IUWidgetType)widgetType{
    return IUWidgetTypePG;
}

#pragma mark - init


-(id)initWithCoder:(NSCoder *)aDecoder{
    self =  [super initWithCoder:aDecoder];
    if(self){
        [self.undoManager disableUndoRegistration];
        [aDecoder decodeToObject:self withProperties:[[PGForm class] properties]];
        [self.undoManager enableUndoRegistration];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[[PGForm class] properties]];
}

- (id)copyWithZone:(NSZone *)zone{
    PGForm *iu = [super copyWithZone:zone];
    [self.undoManager disableUndoRegistration];
    [_canvasVC disableUpdateAll:self];

    
    iu.target = [_target copy];

    [_canvasVC enableUpdateAll:self];
    [self.undoManager enableUndoRegistration];
    return iu;
}

- (void)setTarget:(id)target{
    if([target isEqualTo:_target]){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setTarget:_target];
    
    _target = target;
    
}

@end
    