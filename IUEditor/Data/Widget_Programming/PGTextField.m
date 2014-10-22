//
//  PGTextField.m
//  IUEditor
//
//  Created by jd on 4/25/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "PGTextField.h"

@implementation PGTextField


-(id)initWithProject:(IUProject *)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    if(self){
        [self.undoManager disableUndoRegistration];
        
        _placeholder = @"placeholder";
        _inputValue = @"value example";
        _type = IUTextFieldTypeDefault;
        
        [self.css setValue:@(130) forTag:IUCSSTagPixelWidth forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(30) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];
        
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self =  [super initWithCoder:aDecoder];
    if(self){
        [self.undoManager disableUndoRegistration];
        [aDecoder decodeToObject:self withProperties:[[PGTextField class] properties]];
        [self.undoManager enableUndoRegistration];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[[PGTextField class] properties]];
    
}

- (id)copyWithZone:(NSZone *)zone{
    PGTextField *iu = [super copyWithZone:zone];
    [self.undoManager disableUndoRegistration];
    [self.delegate disableUpdateAll:self];
    
    iu.inputName = [_inputName copy];
    iu.placeholder = [_placeholder copy];
    iu.inputValue = [_inputValue copy];
    iu.type = _type;
    
    [self.delegate enableUpdateAll:self];
    [self.undoManager enableUndoRegistration];
    return iu;
}


#pragma mark -
#pragma mark should

- (BOOL)canAddIUByUserInput{
    return NO;
}

#pragma mark -
#pragma mark setting

- (IUTextInputType)textInputType{
    return IUTextInputTypeTextField;
}
- (BOOL)shouldCompileFontInfo{
    return YES;
}

- (void)setInputName:(NSString *)inputName{
    
    if ([_inputName isEqualToString:inputName]) {
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setInputName:_inputName];
    
    _inputName = inputName;
    [self updateHTML];
}

- (void)setPlaceholder:(NSString *)placeholder{
    
    if([_placeholder isEqualToString:placeholder]){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setPlaceholder:_placeholder];
    
    _placeholder = placeholder;
    [self updateHTML];
}

- (void)setInputValue:(NSString *)inputValue{
    
    if([_inputValue isEqualToString:inputValue]){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setInputValue:_inputValue];
    
    _inputValue = inputValue;
    [self updateHTML];
}
- (void)setType:(IUTextFieldType)type{
    
    if(type == _type){
        return;
    }
    
    [(PGTextField *)[self.undoManager prepareWithInvocationTarget:self] setType:_type];
    
    _type = type;
    [self updateHTML];
}

@end
