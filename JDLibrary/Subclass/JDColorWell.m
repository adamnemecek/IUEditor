//
//  JDColorWell.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 23..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "JDColorWell.h"

@implementation JDColorWell

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)activate:(BOOL)exclusive{
    [super activate:exclusive];
    [self changeBorderColor];
}

- (void)deactivate{
    [super deactivate];
    [self changeBorderColor];

}

- (void)changeBorderColor{
    if([self isActive]){
        [self.borderBox setFillColor:[NSColor rgbColorRed:70 green:140 blue:200 alpha:1]];
    }
    else{
        [self.borderBox setFillColor:[NSColor rgbColorRed:204 green:204 blue:204 alpha:1]];
    }
}

@end
