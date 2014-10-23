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
    BOOL isSelected, isDragged, isSelectDragged, isMouseDownForMoveIU;
    NSPoint startDragPoint, middleDragPoint, endDragPoint;
    NSUInteger keyModifierFlags;
}


- (void)awakeFromNib{
    
    self.mainView = [[NSFlippedView alloc] init];
    self.webView = [[WebCanvasView alloc] init];
    self.gridView = [[GridView alloc] init];
    
    self.webView.controller = self.controller;
    self.gridView.controller = self.controller;
    self.sizeView.controller = self.controller;
    
    [self.mainScrollView setDocumentView:self.mainView];
    
    
    [self.mainView addSubviewFullFrame:self.webView];
    [self.mainView addSubviewFullFrame:self.gridView];
    
    [self.mainView setFrameOrigin:NSZeroPoint];
    [self.mainView setFrameSize:NSMakeSize(defaultFrameWidth, self.mainScrollView.frame.size.height)];
    
    [self.mainView addObserver:self forKeyPath:@"frame" options:0 context:nil];
    
    [[self.mainScrollView contentView] setPostsBoundsChangedNotifications:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(boundsDidChange:) name:NSViewBoundsDidChangeNotification object:[self.mainScrollView contentView]];
    

}
-(void) dealloc{
    [self.mainView removeObserver:self forKeyPath:@"frame"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewBoundsDidChangeNotification object:[self.mainScrollView contentView]];
    
}
- (BOOL)isFlipped{
    return YES;
}

#pragma mark - frame
-(void)boundsDidChange:(NSNotification *)notification{
    NSRect contentBounds = [self.mainScrollView contentView].bounds;
    [self.sizeView moveSizeView:contentBounds.origin withWidth:contentBounds.size.width];
    
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
}


- (void)setHeightOfMainView:(CGFloat)height{
    if (abs(height -self.mainView.frame.size.height) < 1) {
        return;
    }
    if(height > 50000){
        height = 50000;
    }
    [self.mainView setHeight:height];
    [self.webView resizePageContent];
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
    [self.controller moveIUToDiffPoint:diffPoint totalDiffPoint:diffPoint];
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



- (BOOL)isDifferentIU:(IUBox *)iu{
    
    if(iu != nil){
        if( [self.controller containsIU:iu] == NO ){
            return YES;
        }
    }
    return NO;
}


-(void)receiveMouseEvent:(NSEvent *)theEvent{
    NSPoint originalPoint = [theEvent locationInWindow];
    NSPoint convertedPoint = [self.mainView convertPoint:originalPoint fromView:nil];
    NSPoint convertedScrollPoint = [self.mainScrollView convertPoint:originalPoint fromView:nil];
    NSView *hitView = [self.gridView hitTest:convertedPoint];
    
    if([hitView isKindOfClass:[GridView class]] == NO){
        if( [self pointInScrollView:convertedScrollPoint]){
            if ( theEvent.type == NSLeftMouseDown
                && ([self.webView isTextEditorAtPoint:convertedPoint] == NO)){
                JDTraceLog( @"mouse down");
                
                isMouseDownForMoveIU = YES;
                IUBox *clickedIU = [self.webView IUAtPoint:convertedPoint];
                
                //webview에서 발견 못하면 gridView에서 한번더 체크
                //media query 에서 보이지 않는 iu를 위해서 체크함.
                if(clickedIU == nil){
                    clickedIU = [self.gridView IUAtPoint:convertedPoint];
                }
                
                if (theEvent.clickCount == 1){
                    if( [theEvent modifierFlags] & NSCommandKeyMask ){
                        //여러개 select 하는 순간 editing mode out
                        //[[self webView] setEditable:NO];
                        
                        //이미 select되어 있으면 deselect
                        if( [self.controller containsIU:clickedIU] ){
                            [self.controller deselectedIU:clickedIU];
                        }
                        else{
                            [self.controller addSelectedIU:clickedIU];
                        }
                    }
                    else{
                        //다른 iu를 선택하는 순간 editing mode out
                        if([self isDifferentIU:clickedIU]){
                            [self.controller disableTextEditor];
                            
                        }
                        
                        if([self.controller containsIU:clickedIU] == NO || [self.controller countOfSelectedIUs] == 1){
                            [self.controller setSelectedIU:clickedIU];
                        }
                    }
                    
                    if(clickedIU){
                        isSelected = YES;
                    }
                    [self.controller startFrameMoveWithUndoManager:self];
                    
                    //if mouse down on text, it assumes for text selection
                    if([self.controller isEnableTextEditor]){
                        isMouseDownForMoveIU = NO;
                    }
                    
                    startDragPoint = convertedPoint;
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
        if (theEvent.type == NSLeftMouseDragged && isMouseDownForMoveIU){
            JDTraceLog( @"mouse dragged");
            endDragPoint = convertedPoint;
            
            if([theEvent modifierFlags] & NSCommandKeyMask ){
                [self selectWithDrawRect];
            }
            if(isSelected){
                [self moveIUByDragging:theEvent];
            }
            
            middleDragPoint = endDragPoint;
        }
        /* mouse up */
        else if ( theEvent.type == NSLeftMouseUp ){
            JDTraceLog( @"NSLeftMouseUp");
            isMouseDownForMoveIU = NO;
            [self clearMouseMovement];
            
        }
    }
    
    if(isSelectDragged){
        [[NSCursor crosshairCursor] push];
    }
}


#pragma mark -
#pragma mark handle mouse event

- (void)startDraggingFromGridView{
    //turn off canvas view dragging.
    isMouseDownForMoveIU = NO;
    isSelected = NO;
}

- (void)moveIUByDragging:(NSEvent *)theEvent{
    isDragged = YES;
    NSPoint totalPoint = NSMakePoint(endDragPoint.x-startDragPoint.x, endDragPoint.y-startDragPoint.y);
    NSPoint diffPoint = NSMakePoint(endDragPoint.x - middleDragPoint.x, endDragPoint.y - middleDragPoint.y);
    
    if([theEvent modifierFlags] & NSShiftKeyMask){
        if(abs(diffPoint.x) > abs(diffPoint.y)){
            [self.controller moveIUToDiffPoint:NSMakePoint(diffPoint.x, 0) totalDiffPoint:NSMakePoint(totalPoint.x, 0)];
        }
        else{
            [self.controller moveIUToDiffPoint:NSMakePoint(0, diffPoint.y) totalDiffPoint:NSMakePoint(0, totalPoint.y)];
        }
    }
    else{
        [self.controller moveIUToDiffPoint:diffPoint totalDiffPoint:totalPoint];
    }
    
}

- (void)selectWithDrawRect{
    isSelectDragged = YES;
    isSelected = NO;
    
    NSSize size = NSMakeSize(endDragPoint.x-startDragPoint.x, endDragPoint.y-startDragPoint.y);
    NSRect selectFrame = NSMakeRect(startDragPoint.x, startDragPoint.y, size.width, size.height);
    
    [self.gridView drawSelectionLayer:selectFrame];
    [self.controller selectIUInRect:selectFrame];
}

- (void)clearMouseMovement{
    [self.gridView clearGuideLine];
    
    if(isSelected){
        isSelected = NO;
    }
    if(isDragged){
        isDragged = NO;
        [self.controller endFrameMoveWithUndoManager:self];
    }
    if(isSelectDragged){
        isSelectDragged = NO;
        [NSCursor pop];
        [self.gridView resetSelectionLayer];
    }

}




@end
