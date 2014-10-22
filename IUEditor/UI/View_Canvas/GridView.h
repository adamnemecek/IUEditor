//
//  GridView.h
//  IUCanvas
//
//  Created by ChoiSeungmi on 2014. 3. 21..
//  Copyright (c) 2014년 ChoiSeungmi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PointLayer.h"
#import "GuideLineLayer.h"

@interface GridView : NSView{
    CALayer *selectionLayer, *ghostLayer;
    CALayer *borderManagerLayer;
    CALayer *textManageLayer, *pointManagerLayer;
    CALayer *selectLineManagerLayer;
    GuideLineLayer *guideLayer;
    
    //for dragging - change width, height ofIU
    BOOL isClicked, isDragged;
    NSPoint startPoint, middlePoint;
    IUPointLayerPosition selectedPointType;
    
    //for managing cursor
    NSMutableDictionary *cursorDict;
}

@property (weak) id  delegate;

- (void)addSelectionLayerWithIdentifier:(NSString *)iuID withFrame:(NSRect)frame;
- (void)removeAllSelectionLayers;

- (void)addTextPointLayer:(NSString *)iuID withFrame:(NSRect)frame;
- (void)removeAllTextPointLayer;

- (void)drawSelectionLayer:(NSRect)frame;
- (void)resetSelectionLayer;

- (void)updateLayerRect:(NSMutableDictionary *)frameDict;
- (void)removeLayerWithIUIdentifier:(NSString *)identifier;
- (void)clearAllLayer;

- (void)setBorder:(BOOL)border;
- (void)setGhost:(BOOL)ghost;
- (void)setGhostImage:(NSImage *)image;
- (void)setGhostPosition:(NSPoint)position;
- (void)setGhostOpacity:(CGFloat)opacity;

- (void)drawGuideLine:(NSArray *)array;
- (void)clearGuideLine;


- (NSString *)IUAtPoint:(NSPoint)point;
@end
