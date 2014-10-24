//
//  borderLayer.m
//  IUCanvas
//
//  Created by ChoiSeungmi on 2014. 3. 26..
//  Copyright (c) 2014년 ChoiSeungmi. All rights reserved.
//

#import "BorderLayer.h"
#import "JDUIUtil.h"
@implementation BorderLayer

- (id)initWithIdentifier:(NSString *)anIdentifier withFrame:(NSRect)frame{
    self = [super init];
    if(self){
        identifier = anIdentifier;

        [self setFrame:frame];
        
        [self setBorderColor:[[NSColor gridColor] CGColor]];
        [self setBorderWidth:1.0f];
        [self disableAction];
        
    }
    return self;
}

- (NSString *)identifier{
    return identifier;
}

@end
