//
//  PGTextView.m
//  IUEditor
//
//  Created by jd on 4/25/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "PGTextView.h"

@implementation PGTextView

-(id)initWithProject:(IUProject *)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];

    if(self){
        [[self undoManager] disableUndoRegistration];


        _placeholder = @"placeholder";
        _inputValue = @"Sample Text";
        [self.css setValue:@(130) forTag:IUCSSTagPixelWidth forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(50) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@"1.3" forTag:IUCSSTagLineHeight forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(IUAlignLeft) forTag:IUCSSTagTextAlign forViewport:IUCSSDefaultViewPort];
        [[self undoManager] enableUndoRegistration];

        
    }

    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self =  [super initWithCoder:aDecoder];

    if(self){
        [[self undoManager] disableUndoRegistration];
        
        [aDecoder decodeToObject:self withProperties:[[PGTextView class] properties]];
        
        [[self undoManager] enableUndoRegistration];

    }

    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[[PGTextView class] properties]];
    
}

- (id)copyWithZone:(NSZone *)zone{
    PGTextView *iu = [super copyWithZone:zone];
    [[self undoManager] disableUndoRegistration];
    [self.delegate disableUpdateAll:self];

    iu.placeholder = [_placeholder copy];
    iu.inputValue = [_inputValue copy];
    
    [self.delegate enableUpdateAll:self];
    [[self undoManager] enableUndoRegistration];

    return iu;
}

- (BOOL)canAddIUByUserInput{
    return NO;
}

- (void)setPlaceholder:(NSString *)placeholder{
    
    if([placeholder isEqualToString:_placeholder]){
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

- (void)setInputName:(NSString *)inputName{
    if([_inputName isEqualToString:inputName]){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setInputName:_inputName];
    
    _inputName = inputName;
}

- (BOOL)shouldCompileFontInfo{
    return YES;
}
- (IUTextInputType)textInputType{
    return IUTextInputTypeTextField;
}

@end
