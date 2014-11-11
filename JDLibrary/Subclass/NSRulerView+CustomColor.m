//
//  NSRulerView+CustomColor.m
//  IUEditor
//
//  Created by seungmi on 2014. 11. 11..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "NSRulerView+CustomColor.h"

@implementation NSRulerView_CustomColor

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [[NSColor colorWithDeviceRed:207.0/255.0 green:108.0/255.0 blue:
      130.0/255.0 alpha:0.3] set];
    [NSBezierPath fillRect:dirtyRect];

    [self drawHashMarksAndLabelsInRect:dirtyRect];
    // Drawing code here.
}

- (void)drawHashMarksAndLabelsInRect:(NSRect)rect{
    [super drawHashMarksAndLabelsInRect:rect];
}


@end
