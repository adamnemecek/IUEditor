//
//  PGTextView.m
//  IUEditor
//
//  Created by jd on 4/25/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "PGTextView.h"

@implementation PGTextView

#pragma mark - class attributes

+ (NSImage *)classImage{
    return [NSImage imageNamed:@"tool_textview"];
}

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"stack_textview"];
}

+ (IUWidgetType)widgetType{
    return IUWidgetTypePG;
}

#pragma mark - Initialize

- (id)initWithPreset{
    self = [super initWithPreset];

    if(self){
        [[self undoManager] disableUndoRegistration];


        _placeholder = @"placeholder";
        _inputValue = @"Sample Text";
        
        self.defaultStyleStorage.width = @(130);
        self.defaultStyleStorage.height = @(50);
        self.defaultStyleStorage.fontLineHeight = @(1.3);
        self.defaultStyleStorage.fontAlign = @(IUAlignLeft);

        [[self undoManager] enableUndoRegistration];
    }

    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self =  [super initWithCoder:aDecoder];

    if(self){
        
        [aDecoder decodeToObject:self withProperties:[[PGTextView class] properties]];
        
    }

    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[[PGTextView class] properties]];
    
}

-(id)initWithJDCoder:(JDCoder *)aDecoder{
    self =  [super initWithJDCoder:aDecoder];
    if(self){
        [self.undoManager disableUndoRegistration];
        [aDecoder decodeToObject:self withProperties:[[PGTextView class] properties]];
        [self.undoManager enableUndoRegistration];
        
    }
    
    return self;
}
-(void)encodeWithJDCoder:(JDCoder *)aCoder{
    [super encodeWithJDCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[[PGTextView class] properties]];
    
}


- (id)copyWithZone:(NSZone *)zone{
    PGTextView *iu = [super copyWithZone:zone];
    [[self undoManager] disableUndoRegistration];

    iu.placeholder = [_placeholder copy];
    iu.inputValue = [_inputValue copy];
    
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

- (IUTextInputType)textInputType{
    return IUTextInputTypeTextField;
}

@end
