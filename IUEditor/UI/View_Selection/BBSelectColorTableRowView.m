//
//  BBStructureTableRowView.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 18..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBSelectColorTableRowView.h"
@interface BBSelectColorTableRowView()

@end

@implementation BBSelectColorTableRowView{
}

// Only called if the 'selected' property is yes.
- (void)drawSelectionInRect:(NSRect)dirtyRect {
    // Check the selectionHighlightStyle, in case it was set to None
    if (self.selectionHighlightStyle != NSTableViewSelectionHighlightStyleNone) {
//        [[NSColor redColor] set];
        if(self.emphasized){
            [[NSColor rgbColorRed:50 green:100 blue:180 alpha:1] set];
            NSRectFill(self.bounds);
        }
    }
}

// interiorBackgroundStyle is normaly "dark" when the selection is drawn (self.selected == YES) and we are in a key window (self.emphasized == YES). However, we always draw a light selection, so we override this method to always return a light color.
- (NSBackgroundStyle)interiorBackgroundStyle {
    return NSBackgroundStyleLight;
}


@end

