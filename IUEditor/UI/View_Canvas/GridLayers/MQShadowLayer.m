//
//  MQShadowLayer.m
//  IUEditor
//
//  Created by seungmi on 2014. 10. 27..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "MQShadowLayer.h"

@implementation MQShadowLayer

- (id)init{
    self = [super init];
    if(self){
        self.selectedFrameWidth = defaultFrameWidth;
        
        self.fillRule = kCAFillRuleEvenOdd;
        self.fillColor = [[NSColor controlShadowColor] CGColor];
        self.opacity = 0.3;
        self.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
        self.needsDisplayOnBoundsChange = YES;
        
        [self disableAction];
        [self updateMQLayer];
 
    }
    return self;
}

- (void)updateMQLayer{
    NSBezierPath *totalPath = [NSBezierPath bezierPathWithRect:self.frame];
    CGFloat left =(self.frame.size.width - _selectedFrameWidth)/2;
    NSRect mqFrame = NSMakeRect(left, 0, _selectedFrameWidth, self.frame.size.height);
    [totalPath appendBezierPathWithRect:mqFrame];
    
    self.path = [totalPath quartzPath];
}

- (void)setSelectedFrameWidth:(NSInteger)selectedFrameWidth{
    _selectedFrameWidth = selectedFrameWidth;
    [self updateMQLayer];
}

- (void)drawInContext:(CGContextRef)ctx{
    [self updateMQLayer];
    [super drawInContext:ctx];
}

@end
