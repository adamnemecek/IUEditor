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

- (void)awakeAfterUsingJDCoder:(JDCoder *)aDecoder{
    [super awakeAfterUsingJDCoder:aDecoder];
    [self.undoManager disableUndoRegistration];
    _target = [aDecoder decodeObjectForKey:@"target"];
    
    [self.undoManager enableUndoRegistration];
}

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [super encodeWithJDCoder:aCoder];
    [aCoder encodeObject:_target forKey:@"target"];
}
- (id)copyWithZone:(NSZone *)zone{
    PGForm *iu = [super copyWithZone:zone];
    [self.undoManager disableUndoRegistration];

    
    if([_target isKindOfClass:[IUBox class]]){
        iu.target = _target;
    }
    else if([_target isKindOfClass:[NSString class]]){
        iu.target = [_target copy];
    }

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
    