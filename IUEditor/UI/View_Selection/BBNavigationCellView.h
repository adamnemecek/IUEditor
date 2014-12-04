//
//  BBNavigationCellView.h
//  IUEditor
//
//  Created by seungmi on 2014. 12. 4..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BBNavigationCellView : NSTableRowView{
@private
    BOOL mouseInside;
    NSTrackingArea *trackingArea;
}


@property id objectValue;

void DrawSeparatorInRect(NSRect rect);

@end
