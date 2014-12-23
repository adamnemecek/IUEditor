//
//  IUHTML.m
//  IUEditor
//
//  Created by ChoiSeungmi on 2014. 4. 15..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUHTML.h"


NSString * const IUInnerHTMLKey = @"IUInnerHTMLKey";

@implementation IUHTML

#pragma mark - class attributes

+ (NSImage *)classImage{
    return [NSImage imageNamed:@"tool_html"];
}

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"stack_html"];
}



#pragma mark - init

-(id)initWithPreset{
    self = [super initWithPreset];
    [self.undoManager disableUndoRegistration];
    
    if(self){
        NSString *innerHTML = @"<div style=\"text-align:center;\"> Edit HTML Code at property tab. </div>";
        [self.defaultPropertyStorage setValue:innerHTML forKey:IUInnerHTMLKey];
    }
    
    [self.undoManager enableUndoRegistration];
    return self;
}

- (id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [super initWithJDCoder:aDecoder];
    if(self){
        [self.undoManager disableUndoRegistration];
        
        [aDecoder decodeToObject:self withProperties:[[IUHTML class] properties]];
        
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [super encodeWithJDCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[[IUHTML class] properties]];
}


-(BOOL)canAddIUByUserInput{
    return NO;
}

@end
