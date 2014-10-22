//
//  JDClickBox.m
//  IUEditor
//
//  Created by seungmi on 2014. 8. 29..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "JDResponderBox.h"

@implementation JDResponderBox

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

- (void)mouseDown:(NSEvent *)theEvent{
    [super mouseDown:theEvent];
    
    if(self.delegate){
        if(theEvent.type == NSLeftMouseDown && theEvent.clickCount ==2){
            if([self.delegate respondsToSelector:@selector(doubleClick:)]){
                [self.delegate performSelector:@selector(doubleClick:) withObject:theEvent];
            }
        }
    }
}
- (void)keyDown:(NSEvent *)theEvent{
    [super keyDown:theEvent];
    if(self.delegate){
        if([self.delegate respondsToSelector:@selector(keyDown:)]){
            [self.delegate performSelector:@selector(keyDown:) withObject:theEvent];

        }
    }
}

@end
