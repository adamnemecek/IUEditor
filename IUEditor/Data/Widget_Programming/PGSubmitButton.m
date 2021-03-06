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

+ (IUWidgetType)widgetType{
    return IUWidgetTypePG;
}

#pragma mark - init

- (id)initWithProject:(id <IUProjectProtocol>)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    if (self) {
        [self.undoManager disableUndoRegistration];
        
        self.label = @"Submit"; //place holder 초기값은 Submit
        
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    
    [aDecoder decodeToObject:self withProperties:[PGSubmitButton properties]];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[PGSubmitButton properties]];
}

- (id)copyWithZone:(NSZone *)zone{
    PGSubmitButton *iu = [super copyWithZone:zone];
    [self.undoManager disableUndoRegistration];
    [_canvasVC disableUpdateAll:self];
    
    iu.label = [_label copy];
    
    [_canvasVC enableUpdateAll:self];
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

- (BOOL)shouldCompileFontInfo{
    return YES;
}

- (IUTextInputType)textInputType{
    return IUTextInputTypeTextField;
}

@end
