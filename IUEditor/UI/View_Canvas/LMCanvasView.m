//
//  LMCanvasView.m
//  IUEditor
//
//  Created by ChoiSeungmi on 2014. 4. 2..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMCanvasView.h"
#import "LMCanvasVC.h"

@implementation LMCanvasView{
    /* current state of mouse + current state of iu (extend or move)*/
    BOOL isMouseDragForIU, isDragForMultipleSelection, isMouseDownForMoveIU;
    NSPoint startDragPoint, middleDragPoint, endDragPoint;
    NSUInteger keyModifierFlags;
    CGFloat zoomFactor;
}

+ (void)initialize{

    NSArray  *upArray = [NSArray arrayWithObjects:[NSNumber numberWithDouble:10.0], nil];
    NSArray *downArray = [NSArray arrayWithObjects:[NSNumber numberWithDouble:0.5],
                 [NSNumber numberWithDouble:0.5], nil];
    [NSRulerView registerUnitWithName:@"Pixel"
                         abbreviation:@"px"
         unitToPointsConversionFactor:1
                          stepUpCycle:upArray stepDownCycle:downArray];

}


- (void)awakeFromNib{
    
    //setting for inner views
    self.mainView = [[NSFlippedView alloc] init];
    self.webView = [[WebCanvasView alloc] init];
    self.gridView = [[GridView alloc] init];
    
    self.webView.controller = self.controller;
    self.gridView.controller = self.controller;
    
    [self.mainScrollView setDocumentView:self.mainView];
    
    [self.mainView addSubviewFullFrame:self.webView withIdentifier:@"webview"];
    [self.mainView addSubviewFullFrame:self.gridView];
    
    [self.mainView setFrameOrigin:NSZeroPoint];
    [self.mainView setFrameSize:NSMakeSize(defaultFrameWidth, self.mainScrollView.frame.size.height)];
    
    [self.mainView addObserver:self forKeyPath:@"frame" options:0 context:nil];
    
    [[self.mainScrollView contentView] setPostsBoundsChangedNotifications:YES];
    
    
    //setting for ruler
    [self.mainScrollView setHasHorizontalRuler:YES];
    [self.mainScrollView setHasVerticalRuler:YES];
    
    [self initailizeRulers];
    [self setRulerOffsets];
    [self.mainScrollView setRulersVisible:YES];
    
    //setting for zoom
    zoomFactor = 1.0;
    [self setZoom:1.0];
    //zoom observer
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"zoom" options:NSKeyValueObservingOptionInitial context:nil];
    



}

-(void) dealloc{
    [self.mainView removeObserver:self forKeyPath:@"frame"];
    
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"zoom"];
}
- (BOOL)isFlipped{
    return YES;
}

- (void)updateMediaQuerySize{
    [self setRulerOffsets];
    
    //adjsut to constraint of webview,gridview;
    NSLayoutConstraint *webviewConstraint = [self.mainView constraintForIdentifier:@"leading_webview"];
    //NSLayoutConstraint *gridviewConstraint = [self.mainView constraintForIdentifier:@"leading_gridview"];
    [self.mainView removeConstraints:@[webviewConstraint]];
    
    NSInteger left = (self.controller.maxFrameWidth - self.controller.selectedFrameWidth)/2;
    NSLayoutConstraint *adjustWebViewConstraint = [self.mainView viewConstraint:self.webView toSuperview:self.mainView leading:left];
    adjustWebViewConstraint.identifier = @"leading_webview";
    [self.mainView addConstraints:@[adjustWebViewConstraint]];    
}
#pragma mark - ruler

- (void)setRulerOffsets
{
    NSRulerView *horizRuler = [self.mainScrollView horizontalRulerView];
    NSRulerView *vertRuler = [self.mainScrollView verticalRulerView];
    
    horizRuler.reservedThicknessForMarkers = 4;
    [horizRuler setMeasurementUnits:@"Pixel"];
    [vertRuler setMeasurementUnits:@"Pixel"];
    
    CGFloat left = (self.mainView.frame.size.width - self.controller.selectedFrameWidth)/2;
    if(left > 0){
        [horizRuler setOriginOffset:left];
    }
    else{
        [horizRuler setOriginOffset:0];
    }
    [vertRuler setOriginOffset:0];
    
    return;
}
- (void)initailizeRulers{
    NSRulerView *horizRuler = [self.mainScrollView horizontalRulerView];
    [horizRuler setClientView:self.gridView];
    NSRulerView *vertRuler = [self.mainScrollView verticalRulerView];
    [vertRuler setClientView:self.gridView];


}


#pragma mark - zoom

#define ZOOMINFACTOR   (1.2)
#define ZOOMOUTFACTOR  (1.0 / ZOOMINFACTOR)
#define ZOOMINMAX   (2.0)
#define ZOOMOUTMIN  (0.2)
/**
 @brief called from key equivalent
 command + (+/-)
 */
- (void)zoomIn
{
    if(zoomFactor >= ZOOMINMAX){
        return;
    }
    [self setZoom:ZOOMINFACTOR];
    return;
}


- (void)zoomOut
{
    if(zoomFactor <= ZOOMOUTMIN){
        return;
    }
    [self setZoom:ZOOMOUTFACTOR];
    return;
}

- (void)setZoom:(CGFloat)zoom{

    NSInteger zoomNumber = zoomFactor * zoom * 100;
    [[NSUserDefaults standardUserDefaults] setInteger:zoomNumber forKey:@"zoom"];
}

/**
 @brief called from toolbar vc
 */

- (void)zoomDidChange:(NSDictionary *)change{
    
    CGFloat percentZoom = [[[NSUserDefaults standardUserDefaults] valueForKey:@"zoom"] floatValue];
    if(percentZoom <= ZOOMOUTMIN*100 || percentZoom >= ZOOMINMAX*100){
        return;
    }

    CGFloat zoom = (percentZoom/100.0)*(1/zoomFactor);
    zoomFactor *= zoom;
    

    [[[[self.webView mainFrame] frameView] documentView] scaleUnitSquareToSize:NSMakeSize(zoom, zoom)];
    [[[[self.webView mainFrame] frameView] documentView] setNeedsDisplay:YES];
    
    
    [self.gridView setLayerZoom:zoomFactor];
    
    [[self.mainScrollView contentView] scaleUnitSquareToSize:NSMakeSize(zoom, zoom)];
    [self.mainScrollView setNeedsDisplay:YES];
    
}
- (void)loadDefaultZoom{
    [[NSUserDefaults standardUserDefaults] setInteger:100 forKey:@"zoom"];
}

#pragma mark - frame


- (void)windowDidResize:(NSNotification *)notification{
    //윈도우 사이즈가 늘어났을 때
    if(self.mainScrollView.frame.size.width > self.mainView.frame.size.width){
        [self.mainView setWidth:self.mainScrollView.frame.size.width];
    }
    else{
        //윈도우 사이즈가 줄어들었으나, 아직도 맥스 사이즈보다는 클때.
        if(self.mainScrollView.frame.size.width >= [self.controller maxFrameWidth]){
            [self.mainView setWidth:self.mainScrollView.frame.size.width];
        }
        //윈도우 사이즈가 줄어들고, 맥스사이즈보다도 작을때
        else{
            [self.mainView setWidth:[self.controller maxFrameWidth]];
            
        }
    }
    [self setRulerOffsets];
    [self.gridView windowDidResize:notification];
    
}


- (void)setHeightOfMainView:(CGFloat)height{
    if (abs(height -self.mainView.frame.size.height) < 1) {
        return;
    }
    if(height > 50000){
        height = 50000;
    }
    [self.mainView setHeight:height];
}

/**
 IUClass 일 경우 scroll 없이 전체 화면을 사용함.
 */
- (void)extendMainViewToFullSize{
    [self setHeightOfMainView:[[self mainScrollView] frame].size.height];
}

#pragma mark -
#pragma mark mouseEvent

//exclude top-botoom view
-  (BOOL)pointInScrollView:(NSPoint)point{
    NSRect frame = NSMakeRect(0, 0, self.bounds.size.width, self.mainScrollView.bounds.size.height);
    if (NSPointInRect(point, frame)){
        return YES;
    }
    return NO;
}

//include bottom view(including scroll heihgt)
-  (BOOL)pointInMainView:(NSPoint)point{
    NSRect frame = NSMakeRect(0, 0, self.bounds.size.width, self.mainView.bounds.size.height);
    if (NSPointInRect(point, frame)){
        return YES;
    }
    return NO;
}

#pragma mark event

#pragma mark -
#pragma mark Event

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent{
    BOOL result = [self canvasPerformKeyEquivalent:theEvent];
    if (result == NO) {
        result = [super performKeyEquivalent:theEvent];
    }
    return result;
}
/*
 * NOTE :
 * deletekey는 performKeyequvalent로 들어오지않음
 * window sendevent를 받아서 lmcanvasview에서 처리
 */
- (BOOL)canvasPerformKeyEquivalent:(NSEvent *)theEvent{
    NSResponder *currentResponder = [[self window] firstResponder];
    
    if([currentResponder isKindOfClass:[NSView class]]
       && [self.mainView hasSubview:(NSView *)currentResponder]){
        
        if(theEvent.type == NSKeyDown){
            unsigned short keyCode = theEvent.keyCode;//keyCode is hardware-independent
            
            if([theEvent modifierFlags] & NSCommandKeyMask){
                if([self.controller isEnableTextEditor] == NO){
                    // 'C'
                    if (keyCode == IUKeyCodeC) {
                        [self.controller copy:self];
                        return YES;
                    }
                    // 'V'
                    if (keyCode == IUKeyCodeV) {
                        [self.controller paste:self];
                        return YES;
                    }
                }
            }
            else{
                
                if([self.controller isEnableTextEditor]){
                    //ESC key
                    if(keyCode == IUKeyCodeESC){
                        [self.webView setEditable:NO];
                        return YES;
                    }
                }
                else{
                    //arrow key
                    if(keyCode <= IUKeyCodeArrowUp && keyCode >= IUKeyCodeArrowLeft){
                        [self moveIUByKeyEvent:keyCode];
                        return YES;
                    }
                }
            }
        }
    }
    return NO;
}

- (void)moveIUByKeyEvent:(unsigned short)keyCode{
    NSPoint diffPoint;
    switch (keyCode) {
        case IUKeyCodeArrowUp: //up
            diffPoint = NSMakePoint(0, -1.0);
            break;
        case IUKeyCodeArrowLeft: // left
            diffPoint = NSMakePoint(-1.0, 0);
            break;
        case IUKeyCodeArrowRight: // right
            diffPoint = NSMakePoint(1.0, 0);
            break;
        case IUKeyCodeArrowDown: // down;
            diffPoint = NSMakePoint(0, 1.0);
            break;
        default:
            diffPoint = NSZeroPoint;
            break;
    }
    
    [self.controller startFrameMoveWithUndoManager:self];
    [self.controller moveIUToTotalDiffPoint:diffPoint];
    [self.controller endFrameMoveWithUndoManager:self];
}

//no를 리턴하면 sendevent 슈퍼를 호출하지 않음.
-(BOOL)receiveKeyEvent:(NSEvent *)theEvent{
    NSResponder *currentResponder = [[self window] firstResponder];
    NSView *mainView = self.mainView;
    
    if([currentResponder isKindOfClass:[NSView class]]
       && [mainView hasSubview:(NSView *)currentResponder]){
        
        if(theEvent.type == NSKeyDown){
            unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
            
            
            if([self.controller isEnableTextEditor]== NO){
                //delete key
                if(key == NSDeleteCharacter){
                    [self.controller removeSelectedIUs];
                    return YES;
                }
            }
        }
    }
    return YES;
}

- (BOOL)isDifferentIdentifier:(NSString *)identifier{
    
    if(identifier != nil){
        if( [self.controller containsIdentifier:identifier] == NO ){
            return YES;
        }
    }
    return NO;
}


-(void)receiveMouseEvent:(NSEvent *)theEvent{
    NSPoint originalPoint = [theEvent locationInWindow];
    NSPoint filpConvertedPoint = [self.mainView convertPoint:originalPoint fromView:nil];
    CGFloat zoom = self.gridView.layer.affineTransform.a;
    NSPoint centerConvertedPoint = NSMakePoint((filpConvertedPoint.x - [self.gridView.layer affineTransform].tx)*zoom, (filpConvertedPoint.y)*zoom);

    NSPoint convertedScrollPoint = [self.mainScrollView convertPoint:originalPoint fromView:nil];
    NSView *hitView = [self.gridView hitTest:filpConvertedPoint];
    
    if([hitView isKindOfClass:[GridView class]] == NO){
        if( [self pointInScrollView:convertedScrollPoint]){
            if ( theEvent.type == NSLeftMouseDown
                && ([self.webView isTextEditorAtPoint:centerConvertedPoint] == NO)){
                JDTraceLog( @"mouse down");
                
                isMouseDownForMoveIU = YES;
                NSString *clickedIdentifier = [self.webView IdentifierAtPoint:centerConvertedPoint];
                
                //webview에서 발견 못하면 gridView에서 한번더 체크
                //media query 에서 보이지 않는 iu를 위해서 체크함.
                if(clickedIdentifier == nil){
                    clickedIdentifier = [self.gridView identifierAtPoint:centerConvertedPoint];
                }
                
                if(clickedIdentifier == nil){
                    return;
                }
                
                if (theEvent.clickCount == 1){
                    if( [theEvent modifierFlags] & NSCommandKeyMask ){
                        //여러개 select 하는 순간 editing mode out
                        //[[self webView] setEditable:NO];
                        
                        //이미 select되어 있으면 deselect
                        if( [self.controller containsIdentifier:clickedIdentifier] ){
                            [self.controller deselectedIdentifier:clickedIdentifier];
                        }
                        else{
                            [self.controller addSelectedIdentifier:clickedIdentifier];
                        }
                    }
                    else{
                        //다른 iu를 선택하는 순간 editing mode out
                        if([self isDifferentIdentifier:clickedIdentifier]){
                            [self.controller disableTextEditor];
                            
                        }
                        
                        if([self.controller containsIdentifier:clickedIdentifier] == NO || [self.controller countOfSelectedIUs] == 1){
                            [self.controller setSelectedIdentifier:clickedIdentifier];
                        }
                    }
                    
                    
                    //if mouse down on text, it assumes for text selection
                    if(clickedIdentifier && [self.controller isEnableTextEditor]){
                        isMouseDownForMoveIU = NO;
                    }
                    else{
                        [self.controller startFrameMoveWithUndoManager:self];
                    }
                    
                    startDragPoint = centerConvertedPoint;
                    middleDragPoint = startDragPoint;
                }
                //change editable mode
                if(theEvent.clickCount ==2){
                    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationDoubleClickCanvas object:self.window];
                    [self.controller enableTextEditorForSelectedIU];
                }
            }
        }
        /* mouse dragged */
        if (theEvent.type == NSLeftMouseDragged){
            JDTraceLog( @"mouse dragged");
            endDragPoint = centerConvertedPoint;
            
            if([theEvent modifierFlags] & NSCommandKeyMask ){
                [self selectWithDrawRect];
                isMouseDownForMoveIU = NO;
            }
            if(isMouseDownForMoveIU){
                [self moveIUByDragging:theEvent];
            }
            
            middleDragPoint = endDragPoint;
        }
        /* mouse up */
        else if ( theEvent.type == NSLeftMouseUp ){
            JDTraceLog( @"NSLeftMouseUp");
            [self clearMouseMovement];
            
        }
    }
    
    if(isDragForMultipleSelection){
        [[NSCursor crosshairCursor] push];
    }
}


#pragma mark -
#pragma mark handle mouse event

- (void)startDraggingFromGridView{
    //turn off canvas view dragging.
    isMouseDownForMoveIU = NO;
}

- (void)moveIUByDragging:(NSEvent *)theEvent{
    isMouseDragForIU = YES;
    NSPoint totalPoint = NSMakePoint(endDragPoint.x-startDragPoint.x, endDragPoint.y-startDragPoint.y);
    NSPoint diffPoint = NSMakePoint(endDragPoint.x-middleDragPoint.x, endDragPoint.y-middleDragPoint.y);
    
    if([theEvent modifierFlags] & NSShiftKeyMask){
        if(abs(diffPoint.x) > abs(diffPoint.y)){
            [self.controller moveIUToTotalDiffPoint:NSMakePoint(totalPoint.x, 0)];
        }
        else{
            [self.controller moveIUToTotalDiffPoint:NSMakePoint(0, totalPoint.y)];
        }
    }
    else{
        [self.controller moveIUToTotalDiffPoint:totalPoint];
    }
    
}

- (void)selectWithDrawRect{
    isDragForMultipleSelection = YES;
    
    NSSize size = NSMakeSize(endDragPoint.x-startDragPoint.x, endDragPoint.y-startDragPoint.y);
    NSRect selectFrame = NSMakeRect(startDragPoint.x, startDragPoint.y, size.width, size.height);
    
    [self.gridView drawSelectionLayer:selectFrame];
    [self.controller setSelectIUsInRect:selectFrame];
}

- (void)clearMouseMovement{
    [self.gridView clearGuideLine];
    
    if(isMouseDownForMoveIU){
        isMouseDownForMoveIU = NO;
    }
    if(isMouseDragForIU){
        isMouseDragForIU = NO;
        [self.controller endFrameMoveWithUndoManager:self];
    }
    if(isDragForMultipleSelection){
        isDragForMultipleSelection = NO;
        [NSCursor pop];
        [self.gridView resetSelectionLayer];
    }

}




@end
