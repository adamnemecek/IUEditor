//
//  PGForm.m
//  IUEditor
//
//  Created by jd on 5/7/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "PGForm.h"

@implementation PGForm


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
    [self.delegate disableUpdateAll:self];

    
    iu.target = [_target copy];

    [self.delegate enableUpdateAll:self];
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
    