//
//  GridView.m
//  IUCanvas
//
//  Created by ChoiSeungmi on 2014. 3. 21..
//  Copyright (c) 2014년 ChoiSeungmi. All rights reserved.
//

#import "GridView.h"
#import "PointLayer.h"
#import "BorderLayer.h"
#import "JDLogUtil.h"
#import "CursorRect.h"
#import "JDUIUtil.h"
#import "PointTextLayer.h"
#import "LMCanvasVC.h"
#import "SelectionBorderLayer.h"
#import "RulerLineLayer.h"

@interface GridView(){
    CALayer *selectionLayer, *ghostLayer;
    CALayer *borderManagerLayer;
    CALayer *textManageLayer, *pointManagerLayer;
    CALayer *selectLineManagerLayer;
    CALayer *rulerLineManagerLayer;
    MQShadowLayer *shadowLayer;
    GuideLineLayer *guideLayer;
    
    
    //for dragging - change width, height ofIU
    BOOL isClicked, isDragged;
    NSPoint startPoint, middlePoint;
    IUPointLayerPosition selectedPointType;
    
    //for managing cursor
    NSMutableDictionary *cursorDict;
    
    //for ruler
    NSMutableArray *markerIdentifiers;
}

@end


@implementation GridView

- (id)init
{
    self = [super init];
    if (self) {
        [self setLayer:[[CALayer alloc] init]];
        [self setWantsLayer:YES];
        [self.layer setBackgroundColor:[[NSColor clearColor] CGColor]];
        
        [self.layer disableAction];

        
        //iniialize point Manager
        pointManagerLayer = [CALayer layer];
        [pointManagerLayer disableAction];
        [self.layer addSubLayerFullFrame:pointManagerLayer];

        selectLineManagerLayer = [CALayer layer];
        [selectLineManagerLayer disableAction];
        [self.layer insertSubLayerFullFrame:selectLineManagerLayer below:pointManagerLayer];
        
        //initialize textPoint Manager
        textManageLayer = [CALayer layer];
        [textManageLayer disableAction];
        [self.layer insertSubLayerFullFrame:textManageLayer below:pointManagerLayer];
        
        //initialize border manager
        borderManagerLayer = [CALayer layer];
        [borderManagerLayer disableAction];
        [borderManagerLayer setHidden:YES];
        [self.layer insertSubLayerFullFrame:borderManagerLayer below:textManageLayer];
        
        [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"showBorder" options:NSKeyValueObservingOptionInitial context:nil];
        
        
        //initialize ghost Layer
        ghostLayer = [CALayer layer];
        [ghostLayer setBackgroundColor:[[NSColor clearColor] CGColor]];
        [ghostLayer setOpacity:0.3];
        [ghostLayer disableAction];
        [self.layer insertSubLayerFullFrame:ghostLayer below:borderManagerLayer];
        
        [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"showGhost" options:NSKeyValueObservingOptionInitial context:nil];
        
        /*
         delete : 2014.11.30 initialize, zoom에서 mqselect 할때 사이즈가 맞지않음.
        //initialize mqshadow layer
        //shadowLayer = [MQShadowLayer layer];
        //[self.layer insertSubLayerFullFrame:shadowLayer below:borderManagerLayer];
        */
        
        
        //initialize selection Layer
        selectionLayer = [CALayer layer];
        [selectionLayer setBackgroundColor:[[NSColor clearColor] CGColor]];
        [selectionLayer setBorderColor:[[NSColor gridColor] CGColor]];
        [selectionLayer setBorderWidth:1.0];
        [selectionLayer disableAction];
        [self.layer insertSublayer:selectionLayer below:pointManagerLayer];
        
        //initialize guideline layer;
        guideLayer = [[GuideLineLayer alloc] init];
        [self.layer insertSubLayerFullFrame:guideLayer below:pointManagerLayer];
        
        //initialize ruler
        markerIdentifiers = [NSMutableArray array];
        rulerLineManagerLayer = [CALayer layer];
        [rulerLineManagerLayer setBackgroundColor:[[NSColor clearColor] CGColor]];
        [rulerLineManagerLayer disableAction];
        [self.layer insertSubLayerFullFrame:rulerLineManagerLayer below:pointManagerLayer];
        

        
    }
    return self;
}


- (void)dealloc{
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"showBorder"];
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"showGhost"];
}


#pragma mark - frame

- (BOOL)isFlipped{
    return YES;
}

- (void)windowDidResize:(NSNotification *)notification{
    [shadowLayer updateMQLayer];
    [self updateLayerOrigin];
}

- (void)setSelectedFrameWidth:(NSInteger)width{
    [shadowLayer setSelectedFrameWidth:width];
    [self updateLayerOrigin];
}

- (void)updateLayerOrigin{
    CGFloat zoom = self.layer.affineTransform.a;
    [self setLayerOriginWithZoom:zoom];
}

- (CGFloat)currentLeft{
    CGFloat mainViewFrameWidth =  MAX(self.superview.frame.size.width, self.controller.maxFrameWidth);
    NSInteger left = (mainViewFrameWidth - self.controller.selectedFrameWidth)/2;

    return left;
}

- (void)setLayerOriginWithZoom:(CGFloat)zoom{
    NSInteger left = [self currentLeft];
    self.layer.affineTransform = CGAffineTransformMake(zoom,0,0,zoom, left*zoom, 0);
    
    [self setNeedsDisplay:YES];

}




#pragma mark -
#pragma mark mouse operation

- (NSView *)hitTest:(NSPoint)aPoint{
    NSPoint convertedPoint = [self convertedPoint:aPoint];
    CALayer *hitLayer = [self hitTestInnerPointLayer:convertedPoint];
    if( hitLayer ){
        return self;
    }
    return nil;
}

- (NSPoint)convertedPoint:(NSPoint)aPoint{
    CGFloat zoom = self.layer.affineTransform.a;
    CGFloat tx = self.layer.affineTransform.tx*(1/zoom);
    NSPoint convertedPoint = NSMakePoint((aPoint.x - tx), (aPoint.y));
    return convertedPoint;
}


- (InnerPointLayer *)hitTestInnerPointLayer:(NSPoint)aPoint{
    CALayer *hitLayer = [pointManagerLayer hitTest:aPoint];
    if([hitLayer isKindOfClass:[InnerPointLayer class]]){
        return (InnerPointLayer *)hitLayer;
    }
    return nil;
}

- (void)mouseDown:(NSEvent *)theEvent{
    isClicked = YES;
    NSPoint flipConvertedPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSPoint convertedPoint = [self convertedPoint:flipConvertedPoint];
    InnerPointLayer *hitPointLayer = [self hitTestInnerPointLayer:convertedPoint];
    selectedPointType = [hitPointLayer type];

    startPoint = convertedPoint;
    middlePoint = convertedPoint;
    
    [self.controller startFrameMoveWithUndoManager:self];

}

- (void)mouseDragged:(NSEvent *)theEvent{
    if(isClicked){
        isDragged = YES;
        NSPoint flipConvertedPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        NSPoint convertedPoint = [self convertedPoint:flipConvertedPoint];

        NSPoint diffPoint = NSMakePoint(convertedPoint.x-middlePoint.x, convertedPoint.y-middlePoint.y);
        NSPoint totalPoint = NSMakePoint(convertedPoint.x-startPoint.x, convertedPoint.y-startPoint.y);
        
        middlePoint = convertedPoint;
        
        for(PointLayer *pLayer in pointManagerLayer.sublayers){
            
            NSRect newframe = [pLayer diffPointAndSizeWithType:selectedPointType withDiffPoint:diffPoint];
            NSRect totalFrame = [pLayer diffPointAndSizeWithType:selectedPointType withDiffPoint:totalPoint];
            
            if (selectedPointType == IUPointLayerPositionUp || selectedPointType == IUPointLayerPositionDown) {
                newframe.size.width = CGFLOAT_INVALID;
                totalFrame.size.width = CGFLOAT_INVALID;
            }
            else if (selectedPointType == IUPointLayerPositionLeftMiddle || selectedPointType == IUPointLayerPositionRightMiddle){
                newframe.size.height = CGFLOAT_INVALID;
                totalFrame.size.height = CGFLOAT_INVALID;
            }
            
            [self.controller extendIUToTotalDiffSize:totalFrame.size];
            [self.controller moveIUToTotalDiffPoint:totalFrame.origin];
            
        }
        
        //reset cursor
        [[self window] invalidateCursorRectsForView:self];
    }
}




- (void)mouseUp:(NSEvent *)theEvent{
    if(isClicked){
        isClicked = NO;
    }
    if(isDragged){
        isDragged = NO;
        [self.controller endFrameMoveWithUndoManager:self];
    }
}

- (CGRect)convertedRect:(NSRect)aRect{
    CGFloat zoom = self.layer.affineTransform.a;
    CGFloat tx = self.layer.affineTransform.tx *(1/zoom);
    
    CGRect convertedRect = NSMakeRect(aRect.origin.x + tx,
                                      aRect.origin.y,
                                      aRect.size.width,
                                      aRect.size.height);
    return convertedRect;
}


- (void)resetCursorRects{
    [self discardCursorRects];
    NSMutableArray *cursorArray = [NSMutableArray array];
    
    for(PointLayer *pLayer in pointManagerLayer.sublayers){
        [cursorArray addObjectsFromArray:[pLayer cursorArray]];
    }
    
    for(CursorRect *aCursor in cursorArray){
        CGRect convertedFrame = [self convertedRect:aCursor.frame];
        [self addCursorRect:convertedFrame cursor:aCursor.cursor];
    }
    
}

#pragma mark -
#pragma mark selectIU
- (NSString *)identifierAtPoint:(NSPoint)point{
    for(BorderLayer *bLayer in borderManagerLayer.sublayers){
        if(NSPointInRect(point, bLayer.frame)){
            return bLayer.identifier;
        }
    }
    return nil;
}

- (void)updateLayerRect:(NSMutableDictionary *)frameDict{
    //framedict가 update될때마다 호출
    
    //pointLayer
    for(PointLayer *pLayer in pointManagerLayer.sublayers){
        NSValue *value = [frameDict objectForKey:pLayer.identifier];
        if(value){
            NSRect currentRect = [value rectValue];
            [pLayer updateFrame:currentRect];
        }
    }
    
    
    //textLayer update
    for(PointTextLayer *tLayer in textManageLayer.sublayers){
        NSValue *value = [frameDict objectForKey:tLayer.identifier];
        if(value){
            NSRect currentRect = [value rectValue];
            [tLayer updateFrame:currentRect];
        }
    }
    
    //selection border layer
    for(SelectionBorderLayer *sLayer in selectLineManagerLayer.sublayers){
        NSValue *value = [frameDict objectForKey:sLayer.identifier];
        if(value){
            NSRect currentRect =[value rectValue];
            [sLayer setFrame:currentRect];
        }
    }
    
    //-----------------bound layer---------------------------
    //updated bound layer if already have
    NSMutableDictionary *borderDict = [frameDict mutableCopy];
    for(BorderLayer *bLayer in borderManagerLayer.sublayers){
        NSString *identifier = bLayer.identifier;
        NSValue *value = [borderDict objectForKey:identifier];
        if(value){
            NSRect currentRect =[value rectValue];
            [bLayer setFrame:currentRect];
        }
        [borderDict removeObjectForKey:identifier];
    }
    //make new bound layer if doesn't have
    NSArray *remainingBorderKeys = [borderDict allKeys];
    for(NSString *key in remainingBorderKeys){
        NSRect currentRect =[[borderDict objectForKey:key] rectValue];
        IUBox *iu = [self.controller tryIUBoxByIdentifier:key];
        if (iu) {
            BorderLayer *newBLayer = [[BorderLayer alloc] initWithIdentifier:key withFrame:currentRect];
            [borderManagerLayer addSublayer:newBLayer];
        }
    }
    
    //reset cursor
    [[self window] invalidateCursorRectsForView:self];
    
}

- (void)clearAllLayer{
    //pointLayer
    NSMutableArray *layers = [pointManagerLayer.sublayers mutableCopy];
    for(PointLayer *pLayer in layers){
        [pLayer removeFromSuperlayer];
    }
    
    //selectionborderLayer
    layers = [selectLineManagerLayer.sublayers mutableCopy];
    for(SelectionBorderLayer *sLayer in layers){
        [sLayer removeFromSuperlayer];
    }
    
    //textLayer
    layers = [textManageLayer.sublayers mutableCopy];
    for(PointTextLayer *tLayer in layers){
        [tLayer removeFromSuperlayer];
    }
    
    //-----------------bound layer---------------------------
    layers = [borderManagerLayer.sublayers mutableCopy];
    for(BorderLayer *bLayer in layers){
        [bLayer removeFromSuperlayer];
    }
}

- (void)removeLayerForIdentifier:(NSString *)identifier{
    
    CALayer *removeLayer;
    BOOL found = false;;
    //pointLayer
    for(PointLayer *pLayer in pointManagerLayer.sublayers){
        if([pLayer.identifier isEqualToString:identifier]){
            removeLayer = pLayer;
            found = true;
            break;
        }
    }
    if(found){
        [removeLayer removeFromSuperlayer];
        found = false;
    }
    
    //selectionBorerLayer
    for(SelectionBorderLayer *sLayer in selectLineManagerLayer.sublayers){
        if([sLayer.identifier isEqualToString:identifier]){
            removeLayer = sLayer;
            found = true;
            break;
        }
    }
    if(found){
        [removeLayer removeFromSuperlayer];
        found = false;
    }
    
    //textLayer
    for(PointTextLayer *tLayer in textManageLayer.sublayers){
        if([tLayer.identifier isEqualToString:identifier]){
            removeLayer = tLayer;
            found = true;
            break;
        }
    }
    if(found){
        [removeLayer removeFromSuperlayer];
        found = false;
    }

    
    //-----------------bound layer---------------------------
    for(BorderLayer *bLayer in borderManagerLayer.sublayers){
        if([bLayer.identifier isEqualToString:identifier]){
            removeLayer = bLayer;
            found = true;
            break;
        }
    }
    if(found){
        [removeLayer removeFromSuperlayer];
    }
    
}

#pragma mark red Point layer

- (void)addSelectionLayerWithIdentifier:(NSString *)identifier withFrame:(NSRect)frame{
    PointLayer *pointLayer = [[PointLayer alloc] initWithIdentifier:identifier withFrame:frame];
    [pointManagerLayer addSubLayerFullFrame:pointLayer];
    
    SelectionBorderLayer *sLayer = [[SelectionBorderLayer alloc] initWithIdentifier:identifier withFrame:frame];
    [selectLineManagerLayer addSublayer:sLayer];
    
    //reset cursor
    [[self window] invalidateCursorRectsForView:self];
    
}

- (void)removeAllSelectionLayers{
    //delete current layer
    NSArray *pointLayers = [NSArray arrayWithArray:pointManagerLayer.sublayers];

    for(CALayer *layer in pointLayers){
        [layer removeFromSuperlayer];
    }
    
    
    NSArray *lineLayers = [NSArray arrayWithArray:selectLineManagerLayer.sublayers];
    for(CALayer *layer in lineLayers){
        [layer removeFromSuperlayer];
    }
    
    //reset cursor
    [[self window] invalidateCursorRectsForView:self];
    
}

//dict[IUID] = frame
- (void)makeSelectionLayersWithDictionary:(NSDictionary *)selectedIUDict{
    
    [self removeAllSelectionLayers];
    
    NSArray *keys = [selectedIUDict allKeys];
    //add new selected layer
    for(NSString *identifier in keys){
        NSRect frame = [[selectedIUDict objectForKey:identifier] rectValue];
        [self addSelectionLayerWithIdentifier:identifier withFrame:frame];
    }
    
}

#pragma mark text layer

- (void)addTextPointLayerWithIdentifier:(NSString *)identifier withFrame:(NSRect)frame{
    PointTextLayer *textOriginLayer = [[PointTextLayer alloc] initWithIdentifier:identifier withFrame:frame type:PointTextTypeOrigin];
    textOriginLayer.contentsScale = [[NSScreen mainScreen] backingScaleFactor];
    PointTextLayer *textSizeLayer = [[PointTextLayer alloc] initWithIdentifier:identifier withFrame:frame type:PointTextTypeSize];
    textSizeLayer.contentsScale = [[NSScreen mainScreen] backingScaleFactor];
    
    [textManageLayer addSublayer:textOriginLayer];
    [textManageLayer addSublayer:textSizeLayer];

}

- (void)removeAllTextPointLayer{
    //delete current layer
    NSArray *textLayers = [NSArray arrayWithArray:textManageLayer.sublayers];
    for(CALayer *layer in textLayers){
        [layer removeFromSuperlayer];
    }
    
}

#pragma mark selection layer
-(void)drawSelectionLayer:(NSRect)frame{
    [selectionLayer setHidden:NO];
    [selectionLayer setFrame:frame];
}

- (void)resetSelectionLayer{
    [selectionLayer setHidden:YES];
    [selectionLayer setFrame:NSZeroRect];
}


#pragma mark - border

- (void)showBorderDidChange:(NSDictionary *)change{
    BOOL border = [[NSUserDefaults  standardUserDefaults] boolForKey:@"showBorder"];
    [self setBorder:border];
}

- (void)setBorder:(BOOL)border{
    [borderManagerLayer setHidden:!border];
}

#pragma mark - ghost

- (void)showGhostDidChange:(NSDictionary *)change{
    BOOL ghost = [[NSUserDefaults  standardUserDefaults] boolForKey:@"showGhost"];
    [self setGhost:ghost];
}
- (void)setGhost:(BOOL)ghost{
    
    [ghostLayer setHidden:!ghost];
}
- (void)setGhostImage:(NSImage *)image{
    NSMutableArray *imageLayers = [ghostLayer.sublayers mutableCopy];
    for(CALayer *layer in imageLayers){
        [layer removeFromSuperlayer];
    }
    if(image){
        CALayer *imageLayer = [CALayer layer];
        [imageLayer setContents:image];
        [imageLayer setFrame:NSMakeRect(0, 0, image.size.width, image.size.height)];
        [ghostLayer addSublayer:imageLayer];
    }
}
- (void)setGhostPosition:(NSPoint)position{
    CALayer *imageLayer = [[ghostLayer sublayers] firstObject];
    NSImage *ghostImage = [imageLayer contents];

    if(ghostImage && imageLayer){
        [imageLayer setFrame:NSMakeRect(position.x, position.y, ghostImage.size.width, ghostImage.size.height)];
    }
}

- (void)setGhostOpacity:(CGFloat)opacity{
    [ghostLayer setOpacity:opacity];
}

#pragma mark -
#pragma mark guideLine layer

- (void)drawGuideLine:(NSArray *)array{
    [guideLayer drawLine:array];
}

- (void)clearGuideLine{
    [guideLayer clearPath];
}



#pragma mark - rulerview client methods

- (NSString *)newMarkerName{
    for(NSInteger number=0; ;number++){
        NSString *identifier = [NSString stringWithFormat:@"marker_%ld", number];
        if([markerIdentifiers containsString:identifier] == NO){
            [markerIdentifiers addObject:identifier];
            return identifier;
        }
        if(number > 100){
            [JDUIUtil hudAlert:@"There are too many markers." second:2];
            return nil;
        }
    }
    return nil;
}

- (void)rulerView:(NSRulerView *)ruler handleMouseDown:(NSEvent *)event{
    if(event.type == NSLeftMouseDown){
        NSRulerMarker *newMarker;
        
        NSImage *image = [NSImage imageNamed:@"rulermarker"];
        if ([ruler orientation] == NSHorizontalRuler) {
            newMarker = [[NSRulerMarker alloc] initWithRulerView:ruler
                                                  markerLocation:0.0 image:image imageOrigin:NSZeroPoint];
        } else {
            newMarker = [[NSRulerMarker alloc] initWithRulerView:ruler
                                                  markerLocation:0.0 image:image imageOrigin:NSMakePoint(8.0, 8.0)];
        }
        if(newMarker){
            NSString *identifier = [self newMarkerName];
            if(identifier){
                [newMarker setRepresentedObject:identifier];
                [newMarker setRemovable:YES];
                [ruler trackMarker:newMarker withMouseEvent:event];
            }
        }
    }
    return;
}


- (CGFloat)rulerView:(NSRulerView *)aRulerView willMoveMarker:(NSRulerMarker *)aMarker toLocation:(CGFloat)location
{
    return round(location);
}


//gridview-rulerview연결
/*
- (BOOL)rulerView:(NSRulerView *)ruler shouldMoveMarker:(NSRulerMarker *)marker{
    if(marker.markerLocation < [self currentLeft]){
        return NO;
    }
    return YES;
}

- (BOOL)rulerView:(NSRulerView *)ruler shouldAddMarker:(NSRulerMarker *)marker{
    if(marker.markerLocation < [self currentLeft]){
        return NO;
    }
    return YES;
}
 */

- (void)rulerView:(NSRulerView *)ruler didMoveMarker:(NSRulerMarker *)marker{
    RulerLineLayer *movedLayer;
    NSString *movedIdentifier = (NSString *)marker.representedObject;

    for (RulerLineLayer *lineLayer in rulerLineManagerLayer.sublayers) {
        if([lineLayer.markerIdentifer isEqualToString:movedIdentifier]){
            movedLayer = lineLayer;
            break;
        }
    }
    if(movedLayer){
        CGFloat lineLocation = marker.markerLocation - [self currentLeft];
        [movedLayer setLocation:lineLocation];
    }
}


- (void)rulerView:(NSRulerView *)ruler didAddMarker:(NSRulerMarker *)marker{
    //alloc new ruler line layer
    RulerLineLayer *lineLayer = [[RulerLineLayer alloc] initWithOrientation:[ruler orientation]];
    [lineLayer setMarkerIdentifer:(NSString *)marker.representedObject];
    CGFloat lineLocation = marker.markerLocation - [self currentLeft];
    [lineLayer setLocation:lineLocation];
    [rulerLineManagerLayer addSubLayerFullFrame:lineLayer];
    [lineLayer setNeedsDisplay];
}

- (void)rulerView:(NSRulerView *)ruler didRemoveMarker:(NSRulerMarker *)marker{
    NSString *removedIdentifier = (NSString *)marker.representedObject;
    RulerLineLayer *removedLayer;
    
    for (RulerLineLayer *lineLayer in rulerLineManagerLayer.sublayers) {
        if([lineLayer.markerIdentifer isEqualToString:removedIdentifier]){
            removedLayer = lineLayer;
            break;
        }
    }
    if(removedLayer){
        [removedLayer removeFromSuperlayer];
        [markerIdentifiers removeObject:removedLayer.markerIdentifer];
    }
}

@end
