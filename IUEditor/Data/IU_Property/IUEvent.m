//
//  IUEvent.m
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 4. 25..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUEvent.h"

@interface IUEvent()

- (NSUndoManager *)undoManager;

@end

@implementation IUEvent

-(id)init{
    self = [super init];
    if(self){
        
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone{
    IUEvent *event = [[self class] allocWithZone:zone];
    NSArray *properties = [[self class] properties];
    for (JDProperty *property in properties) {
        id value = [self valueForKey:property.name];
        if (property.isID) {
            [self setValue:[value copy] forKey:property.name];
        }
        else {
            [self setValue:value forKey:property.name];
        }
    }
    return event;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeFromObject:self withProperties:[IUEvent properties]];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if(self) {
        [aDecoder decodeToObject:self withProperties:[IUEvent properties]];
    }
    return self;
}

- (NSString *)findVariable:(NSString *)equation{
    
    NSString *trimmedEquation = [equation stringByTrim];
    NSCharacterSet *parsingSet = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    NSArray *component = [trimmedEquation componentsSeparatedByCharactersInSet:parsingSet];
    
    return component[0];
}

+ (NSArray *)visibleTypeArray{
    NSArray *array = [NSArray arrayWithObjects:
                      @"Blind",
                      @"Slide",
                      @"Fold",
                      @"Bounce",
                      @"Clip",
                      @"Drop",
                      @"Explode",
                      @"Hide",
                      @"Puff",
                      @"Pulsate",
                      @"Shake",
                      @"Size",
                      @"HighLight",
                      nil];
    
    return array;
}
#pragma mark - trigger
- (void)setVariable:(NSString *)variable{
    if([_variable isEqualToString:variable]){
        return;
    }
    [[self.undoManager prepareWithInvocationTarget:self] setVariable:_variable];
    _variable = variable;
}

- (void)setMaxValue:(NSInteger)maxValue{
    if(_maxValue == maxValue){
        return;
    }
    [(IUEvent *)[self.undoManager prepareWithInvocationTarget:self] setMaxValue:_maxValue];
    _maxValue = maxValue;
}
- (void)setInitialValue:(NSInteger)initialValue{
    if(_initialValue == initialValue){
        return;
    }
    [(IUEvent *)[self.undoManager prepareWithInvocationTarget:self] setInitialValue:_initialValue];
    _initialValue = initialValue;
}

-(void)setActionType:(IUEventActionType)actionType{
    if(_actionType == actionType){
        return;
    }
    [[self.undoManager prepareWithInvocationTarget:self] setActionType:_actionType];
    _actionType = actionType;
}


#pragma mark - receiver
#pragma mark - visible

- (void)setEnableVisible:(BOOL)enableVisible{
    if(_enableVisible == enableVisible){
        return;
    }
    [[self.undoManager prepareWithInvocationTarget:self] setEnableVisible:_enableVisible];
    _enableVisible = enableVisible;
}


- (void)setEqVisible:(NSString *)eqVisible{
    if([_eqVisible isEqualToString:eqVisible]){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setEqVisible:_eqVisible];
    
    _eqVisible = eqVisible;
    _eqVisibleVariable = [self findVariable:eqVisible];
}


- (void)setEqVisibleDuration:(NSInteger)eqVisibleDuration{
    if(_eqVisibleDuration == eqVisibleDuration){
        return;
    }
    [[self.undoManager prepareWithInvocationTarget:self] setEqVisibleDuration:_eqVisibleDuration];
    _eqVisibleDuration = eqVisibleDuration;
}

- (void)setDirectionType:(IUEventVisibleType)directionType{
    if(_directionType == directionType){
        return;
    }
    [[self.undoManager prepareWithInvocationTarget:self] setDirectionType:_directionType];
    _directionType = directionType;
}

#pragma mark -frame

- (void)setEnableFrame:(BOOL)enableFrame{
    if(_enableFrame == enableFrame){
        return;
    }
    [[self.undoManager prepareWithInvocationTarget:self] setEnableFrame:_enableFrame];
    _enableFrame = enableFrame;
}

- (void)setEqFrame:(NSString *)eqFrame{
    
    if([_eqFrame isEqualToString:eqFrame]){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setEqFrame:_eqFrame];
    
    _eqFrame = eqFrame;
    _eqFrameVariable = [self findVariable:eqFrame];
}

- (void)setEqFrameDuration:(NSInteger)eqFrameDuration{
    if (_eqFrameDuration == eqFrameDuration) {
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setEqFrameDuration:_eqFrameDuration];
    _eqFrameDuration = eqFrameDuration;
}

- (void)setEqFrameWidth:(CGFloat)eqFrameWidth{
    if(_eqFrameWidth != eqFrameWidth){
        [[self.undoManager prepareWithInvocationTarget:self] setEqFrameWidth:_eqFrameWidth];
        _eqFrameWidth = eqFrameWidth;
    }
}

- (void)setEqFrameHeight:(CGFloat)eqFrameHeight{
    if(_eqFrameHeight != eqFrameHeight){
        [[self.undoManager prepareWithInvocationTarget:self] setEqFrameHeight:_eqFrameHeight];
        _eqFrameHeight = eqFrameHeight;
    }
}
#pragma mark - Undo Manager
- (NSUndoManager *)undoManager{
    return [[[[NSApp mainWindow] windowController] document] undoManager];
}

@end
