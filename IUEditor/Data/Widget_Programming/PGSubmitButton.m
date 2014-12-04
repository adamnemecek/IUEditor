//
//  IUButton.m
//  IUEditor
//
//  Created by jd on 5/7/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "PGSubmitButton.h"

@implementation PGSubmitButton

#pragma mark - class attributes

+ (NSImage *)classImage{
    return [NSImage imageNamed:@"tool_submit"];
}

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"stack_submit"];
}

+ (NSString *)widgetType{
    return kIUWidgetTypeProgramming;
}

#pragma mark - init

- (id)initWithPreset{
    self = [super initWithPreset];
    if (self) {
        [self.undoManager disableUndoRegistration];
        
        self.label = @"Submit"; //place holder 초기값은 Submit
        
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

-(id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [super initWithJDCoder:aDecoder];
    if(self){
        [self.undoManager disableUndoRegistration];
        [aDecoder decodeToObject:self withProperties:[PGSubmitButton properties]];
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

-(void)encodeWithJDCoder:(JDCoder *)aCoder{
    [super encodeWithJDCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[PGSubmitButton properties]];
}



- (id)copyWithZone:(NSZone *)zone{
    PGSubmitButton *iu = [super copyWithZone:zone];
    [self.undoManager disableUndoRegistration];
    
    iu.label = [_label copy];
    
    [self.undoManager enableUndoRegistration];
    return iu;
}


- (void)setLabel:(NSString *)label{
    
    if([label isEqualToString:_label]){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setLabel:_label];
    
    if (label == nil){
        _label = @"";   //place holder 에 빈칸 입력시 null 로 표시되는 것을 방지
    }
    else{
        _label = label;
    }
    
    [self updateHTML];
}


- (IUTextInputType)textInputType{
    return IUTextInputTypeTextField;
}

@end
