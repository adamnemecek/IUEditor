//
//  IUHTML.m
//  IUEditor
//
//  Created by ChoiSeungmi on 2014. 4. 15..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUHTML.h"

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
        _innerHTML = @"<div style=\"text-align:center;\"> Edit HTML Code at property tab. </div>";
    }
    
    [self.undoManager enableUndoRegistration];
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self =  [super initWithCoder:aDecoder];
    
    if(self){
        [aDecoder decodeToObject:self withProperties:[[IUHTML class] properties]];
    }
    
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[[IUHTML class] properties]];

}

- (id)copyWithZone:(NSZone *)zone{
    IUHTML *html = [super copyWithZone:zone];
    [self.undoManager disableUndoRegistration];
    [_canvasVC disableUpdateAll:self];

    
    if(html){
        html.innerHTML = [_innerHTML copy];
    }
    
    [_canvasVC enableUpdateAll:self];
    [self.undoManager enableUndoRegistration];
    return html;
}

-(BOOL)canAddIUByUserInput{
    return NO;
}

-(BOOL)hasInnerHTML{
    if(_innerHTML){
        return YES;
    }
    return NO;
}

-(void)setInnerHTML:(NSString *)aInnerHTML{
    _innerHTML = aInnerHTML;
    JDInfoLog(@"%@", aInnerHTML);
    [self updateHTML];
}

@end
