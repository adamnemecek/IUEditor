//
//  RulerLineLayer.m
//  IUEditor
//
//  Created by seungmi on 2014. 10. 28..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "RulerLineLayer.h"
@interface RulerLineLayer(){
    NSBezierPath *path;
    NSRulerOrientation orientation;
}
@end

@implementation RulerLineLayer

-(id)initWithOrientation:(NSRulerOrientation)anOrientation{
    self = [super init];
    if(self){
        
        orientation = anOrientation;
        path = [NSBezierPath bezierPath];
        
        self.backgroundColor = [[NSColor clearColor] CGColor];
        [self setStrokeColor:[[NSColor redColor] CGColor]];
        [self setLineWidth:1.0];
        [self setLineJoin:kCALineJoinMiter];
        [self setFillColor:[[NSColor clearColor] CGColor]];
        [self setLineDashPhase:3.0f];
        [self setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithFloat:5], nil]];

        [self disableAction];
        
    }
    return self;
}

- (void)clearPath{
    [path removeAllPoints];
    self.path = [path quartzPath];
}

- (void)setLocation:(CGFloat)location{
    _location = location;
    [self updateRulerLine];
}

- (void)updateRulerLine{
    [self clearPath];
    
    NSPoint start, end;
    if(orientation == NSHorizontalRuler){
        start = NSMakePoint(_location, 0);
        end = NSMakePoint(_location, self.frame.size.height);
    }
    else{//NSVerticalRuler
        start = NSMakePoint(0, _location);
        end = NSMakePoint(self.frame.size.width, _location);
    }
    
    [path drawline:start end:end];
    self.path = [path quartzPath];
    CGPathRelease(self.path);
}


- (void)drawInContext:(CGContextRef)ctx{
    [super drawInContext:ctx];
    [self updateRulerLine];
}

@end
