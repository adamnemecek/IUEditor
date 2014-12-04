//
//  PGTextField.m
//  IUEditor
//
//  Created by jd on 4/25/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "PGTextField.h"

@implementation PGTextField

#pragma mark - class attributes

+ (NSImage *)classImage{
    return [NSImage imageNamed:@"tool_textfield"];
}

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"stack_textfield"];
}

+ (NSString *)widgetType{
    return kIUWidgetTypeProgramming;
}


#pragma mark - Initialize


-(id)initWithPreset{
    self = [super initWithPreset];
    if(self){
        [self.undoManager disableUndoRegistration];
        
        _placeholder = @"placeholder";
        _inputValue = @"value example";
        _type = IUTextFieldTypeDefault;
        
        self.defaultStyleStorage.width = @(130);
        self.defaultStyleStorage.height = @(80);
        
        
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

-(id)initWithJDCoder:(JDCoder *)aDecoder{
    self =  [super initWithJDCoder:aDecoder];
    if(self){
        [self.undoManager disableUndoRegistration];
        [aDecoder decodeToObject:self withProperties:[[PGTextField class] properties]];
        [self.undoManager enableUndoRegistration];
    }
    return self;
}
-(void)encodeWithJDCoder:(JDCoder *)aCoder{
    [super encodeWithJDCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[[PGTextField class] properties]];
    
}

- (id)copyWithZone:(NSZone *)zone{
    PGTextField *iu = [super copyWithZone:zone];
    [self.undoManager disableUndoRegistration];
    
    iu.inputName = [_inputName copy];
    iu.placeholder = [_placeholder copy];
    iu.inputValue = [_inputValue copy];
    iu.type = _type;
    
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
