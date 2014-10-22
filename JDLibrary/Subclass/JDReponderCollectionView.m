//
//  JDReponderCollectionView.m
//  IUEditor
//
//  Created by seungmi on 2014. 9. 15..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "JDReponderCollectionView.h"

@implementation JDReponderCollectionView

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)keyDown:(NSEvent *)theEvent{
    [super keyDown:theEvent];
    [viewController keyDown:theEvent];
}
@end
