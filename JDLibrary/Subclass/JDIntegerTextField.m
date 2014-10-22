//
//  JDIntegerTextField.m
//  IUEditor
//
//  Created by jd on 2014. 7. 9..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "JDIntegerTextField.h"
#import "JDFormatter.h"

@implementation JDIntegerTextField

- (id)init{
    self = [super init];
    JDOnlyIntegerValueFormatter *formatter = [[JDOnlyIntegerValueFormatter alloc] init];
    [self setFormatter:formatter];
    return self;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        JDOnlyIntegerValueFormatter *formatter = [[JDOnlyIntegerValueFormatter alloc] init];
        [self setFormatter:formatter];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    JDOnlyIntegerValueFormatter *formatter = [[JDOnlyIntegerValueFormatter alloc] init];
    [self setFormatter:formatter];
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
