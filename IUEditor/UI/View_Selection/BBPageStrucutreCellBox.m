//
//  BBPageStrucutreCellBox.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 18..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBPageStrucutreCellBox.h"

@interface BBPageStrucutreCellBox ()

@property (nonatomic) BOOL mouseInside;

@end

@implementation BBPageStrucutreCellBox{
    NSTrackingArea *_trackingArea;
}


- (void)setMouseInside:(BOOL)value {
    if (_mouseInside != value) {
        _mouseInside = value;

        [self setNeedsDisplay:YES];
    }
}

- (void)ensureTrackingArea{
    if (_trackingArea == nil) {
        _trackingArea = [[NSTrackingArea alloc] initWithRect:NSZeroRect options:NSTrackingInVisibleRect | NSTrackingActiveAlways | NSTrackingMouseEnteredAndExited owner:self userInfo:nil];
    }
}
- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    [self ensureTrackingArea];
    if (![[self trackingAreas] containsObject:_trackingArea]) {
        [self addTrackingArea:_trackingArea];
    }
}

- (void)mouseEntered:(NSEvent *)theEvent{
    self.mouseInside = YES;
}
- (void)mouseExited:(NSEvent *)theEvent{
    self.mouseInside = NO;
}

- (void)drawRect:(NSRect)dirtyRect{
    [super drawRect:dirtyRect];
    [self.hoverView setHidden:!_mouseInside];
}


@end
