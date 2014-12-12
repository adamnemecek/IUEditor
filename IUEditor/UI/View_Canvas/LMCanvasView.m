//
//  LMCanvasView.m
//  IUEditor
//
//  Created by ChoiSeungmi on 2014. 4. 2..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMCanvasView.h"
#import "LMCanvasVC.h"
#import "NSRulerView+CustomColor.h"

@implementation LMCanvasView{
    /* current state of mouse + current state of iu (extend or move)*/
    BOOL _isMouseDragForIU, _isDragForMultipleSelection, _isMouseDownForMoveIU, _isMouseDownForNewIU;
    NSPoint startDragPoint, middleDragPoint, endDragPoint;
    NSUInteger keyModifierFlags;
    CGFloat zoomFactor, oldLeft;
    NSString *_selectedWidgetClassName;
    
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
    [self.mainView setFrameSize:NSMakeSize(IUDefaultViewPort, self.mainScrollView.frame.size.height)];
    
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeWidgetSelection:) name:IUWidgetLibrarySelectionDidChangeNotification object:self.window];
    

}

-(void) dealloc{
    [self.mainView removeObserver:self forKeyPath:@"frame"];
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"zoom"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (BOOL)isFlipped{
    return YES;
}

- (void)updateMainViewOrigin{
    [self setRulerOffsets];
    
    //adjsut to constraint of webview;
    NSLayoutConstraint *leadingWebviewConstraint = [self.mainView constraintForIdentifier:@"leading_webview"];
    NSLayoutConstraint *trailingWebviewContstraint = [self.mainView constraintForIdentifier:@"trailing_webview"];
    [self.mainView removeConstraints:@[leadingWebviewConstraint, trailingWebviewContstraint]];
    
    
    NSInteger left = (self.maxCurrentFrameWidth - self.controller.selectedFrameWidth)/2;
    NSLayoutConstraint *adjustLeadingWebViewConstraint = [self.mainView viewConstraint:self.webView toSuperview:self.mainView leading:left];
    adjustLeadingWebViewConstraint.identifier = @"leading_webview";
    
    NSLayoutConstraint *adjustTrailingWebViewConstraint = [self.mainView viewConstraint:self.webView toSuperview:self.mainView trailing:left];
    adjustTrailingWebViewConstraint.identifier = @"trailing_webview";

    
    [self.mainView addConstraints:@[adjustLeadingWebViewConstraint, adjustTrailingWebViewConstraint]];
    [self.mainView setNeedsLayout:YES];
    [self.mainView setNeedsUpdateConstraints:YES];
}
#pragma mark - ruler

- (void)initailizeRulers{
    NSRulerView *horizRuler = [self.mainScrollView horizontalRulerView];
    [horizRuler setClientView:self.gridView];
    NSRulerView *vertRuler = [self.mainScrollView verticalRulerView];
    [vertRuler setClientView:self.gridView];
}

- (void)setRulerOffsets
{
    //horizontal Ruler
    NSRulerView *horizRuler = [self.mainScrollView horizontalRulerView];
    
    horizRuler.reservedThicknessForMarkers = 4;
    [horizRuler setMeasurementUnits:@"Pixel"];
    
    CGFloat left = (self.maxCurrentFrameWidth - self.controller.selectedFrameWidth)/2;
    if(left < 0){
        left = 0;
    }
    [horizRuler setOriginOffset:left];
    for(NSRulerMarker *marker in [horizRuler markers]){
        marker.markerLocation = marker.markerLocation - oldLeft + left;
    }
    
    oldLeft = left;
    
    //vertical Ruler
    NSRulerView *vertRuler = [self.mainScrollView verticalRulerView];
    [vertRuler setMeasurementUnits:@"Pixel"];
    [vertRuler setOriginOffset:0];
    
    return;
}

- (CGFloat)maxCurrentFrameWidth{
    return MAX(self.mainView.frame.size.width, self.controller.maxFrameWidth);
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

    CGFloat zoomNumber = zoomFactor * zoom * 100;
    [[NSUserDefaults standardUserDefaults] setFloat:zoomNumber forKey:@"zoom"];
}

/**
 @brief called from toolbar vc
 */

- (void)zoomDidChange:(NSDictionary *)change{
    
    CGFloat percentZoom = [[[NSUserDefaults standardUserDefaults] valueForKey:@"zoom"] floatValue];
    if(percentZoom <= ZOOMOUTMIN*100 || percentZoom > ZOOMINMAX*100){
        return;
    }

    CGFloat zoom = (percentZoom/100.0)*(1/zoomFactor);
    zoomFactor *= zoom;
    
    //webview - scale
    self.webView.layer.affineTransform = CGAffineTransformMake(zoomFactor,0,0,zoomFactor, 0, 0);
    [self.webView.layer setNeedsDisplay];
    [[[[self.webView mainFrame] frameView] documentView] setNeedsDisplay:YES];
    
    //gridview - scale
    [self.gridView setLayerOriginWithZoom:zoomFactor];
    
    //ruler- scale
    [[self.mainScrollView contentView] scaleUnitSquareToSize:NSMakeSize(zoom, zoom)];
    [self.mainScrollView setNeedsDisplay:YES];
    [self.mainScrollView setNeedsLayout:YES];

    
    
}
- (void)loadDefaultZoom{
    [[NSUserDefaults standardUserDefaults] setFloat:100 forKey:@"zoom"];
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
    [self updateMainViewOrigin];
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
    
    [self.controller startFrameMoveWithTransaction:self];
    [self.controller moveIUToTotalDiffPoint:diffPoint];
    [self.controller endFrameMoveWithTransaction:self];
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

- (NSString *)identifierAtPoint:(NSPoint)point{
    NSString *identifier = [self.webView IdentifierAtPoint:point];
    
    //webview에서 발견 못하면 gridView에서 한번더 체크
    //media query 에서 보이지 않는 iu를 위해서 체크함.
    if(identifier == nil){
        identifier = [self.gridView identifierAtPoint:point];
    }
    return identifier;
}




-(void)receiveMouseEvent:(NSEvent *)theEvent{
    //make current position
    NSPoint originalPoint = [theEvent locationInWindow];
    NSPoint filpConvertedPoint = [self.mainView convertPoint:originalPoint fromView:nil];
    CGFloat zoom = self.gridView.layer.affineTransform.a;
    CGFloat left = self.gridView.layer.affineTransform.tx*1/zoom;
    NSPoint centerConvertedPoint = NSMakePoint(filpConvertedPoint.x - left, filpConvertedPoint.y);

    NSPoint convertedScrollPoint = [self.mainScrollView convertPoint:originalPoint fromView:nil];
    NSView *hitView = [self.gridView hitTest:filpConvertedPoint];
    
  
    /*
     if hitView is gridview, resize iu
     else, LMCanvasView manage move, make newIU, select ius, enable/disable text mode
     */
    if([hitView isKindOfClass:[GridView class]] == NO){
        if( [self pointInScrollView:convertedScrollPoint]){
            
            /* mouse down */
            if ( theEvent.type == NSLeftMouseDown && ([self.webView isTextEditorAtPoint:centerConvertedPoint] == NO)){
                JDTraceLog( @"mouse down");
                NSString *clickedIdentifier = [self identifierAtPoint:centerConvertedPoint];
                if(clickedIdentifier == nil){
                    return;
                }
                
                if (theEvent.clickCount == 1){
                    [self mouseDownAtOnce:theEvent withClickedIdentifier:clickedIdentifier];
                    startDragPoint = centerConvertedPoint;
                    middleDragPoint = startDragPoint;
                }
                
                //change editable mode
                if(theEvent.clickCount == 2){
                    [self.controller enableTextEditorForSelectedIU];
                }
            }
        }
        /* mouse dragged */
        if (theEvent.type == NSLeftMouseDragged){
            JDTraceLog( @"mouse dragged");
            endDragPoint = centerConvertedPoint;
            
            //multiple select or draw new IU
            if(([theEvent modifierFlags] & NSCommandKeyMask )|| _isMouseDownForNewIU){
                [self selectWithDrawRect];
                _isMouseDownForMoveIU = NO;
            }
            if(_isMouseDownForMoveIU){
                [self moveIUByDragging:theEvent];
            }
            
            middleDragPoint = endDragPoint;
        }
        /* mouse up */
        else if ( theEvent.type == NSLeftMouseUp ){
            JDTraceLog( @"NSLeftMouseUp");
            [self mouseUp:theEvent withConvertedPoint:centerConvertedPoint];
        }
    }
    
    if(_isDragForMultipleSelection || _isMouseDownForNewIU){
        [[NSCursor crosshairCursor] push];
    }

}


#pragma mark -
#pragma mark handle mouse event

- (void)selectMultipleIUWithClieckedIdentifier:(NSString *)identifier{
    //이미 select되어 있으면 deselect
    if( [self.controller containsIdentifier:identifier] ){
        [self.controller deselectedIdentifier:identifier];
    }
    else{
        [self.controller addSelectedIdentifier:identifier];
    }
}

- (void)mouseDownAtOnce:(NSEvent *)theEvent withClickedIdentifier:(NSString *)clickedIdentifier{
    //multiple selection
    if( [theEvent modifierFlags] & NSShiftKeyMask ){
        [self selectMultipleIUWithClieckedIdentifier:clickedIdentifier];
    }
    else{
        //다른 iu를 선택하는 순간 editing mode out
        if([self isDifferentIdentifier:clickedIdentifier]){
            [self.controller disableTextEditor];
            
        }
        
        //현재 셀렉된 위젯 라이브러리가 있으면, 새로운 iu를 만들어냄
        if(_selectedWidgetClassName){
            _isMouseDownForNewIU = YES;
        }
        //셀력된 위젯 라이브러리가 없으면, iu selection으로 받아들임
        else{
            if([self.controller containsIdentifier:clickedIdentifier] == NO || [self.controller countOfSelectedIUs] == 1){
                [self.controller setSelectedIdentifier:clickedIdentifier];
            }
            _isMouseDownForMoveIU = YES;
        }
    }
    
    //double check : if mouse down on text, it assumes for text selection
    if(clickedIdentifier && [self.controller isEnableTextEditor]){
        _isMouseDownForMoveIU = NO;
    }
}

/* mouse Up */
- (void)mouseUp:(NSEvent *)theEvent withConvertedPoint:(NSPoint)centerConvertedPoint{
    if(_isMouseDownForNewIU){
        NSString *identifier = [self identifierAtPoint:centerConvertedPoint];
        IUBox *parentIU = [self parentIUWithIdentifier:identifier];
        NSSize size = NSMakeSize(centerConvertedPoint.x - startDragPoint.x, centerConvertedPoint.y - startDragPoint.y);
        BOOL result =  [self.controller makeNewIUWithClassName:_selectedWidgetClassName withFrame:NSMakeRect(startDragPoint.x, startDragPoint.y, size.width, size.height) atParentIU:parentIU];
        
        if(result){
            _selectedWidgetClassName = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationNewIUCreatedByCanvas object:self.window];
            
        }
    }
    [self clearMouseMovement];
}

/** 
 dragging start from grid view turn off canvas view dragging.
 prevent racing condition
 */
- (void)startDraggingFromGridView{
    [self clearMouseMovement];
}

- (void)moveIUByDragging:(NSEvent *)theEvent{
    if(_isMouseDragForIU == NO){
        //처음 스타트할때 tansaction 시작
        [self.controller startFrameMoveWithTransaction:self];
    }
    _isMouseDragForIU = YES;
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
    if(_selectedWidgetClassName){
        _isMouseDownForNewIU = YES;
    }
    else{
        _isDragForMultipleSelection = YES;
    }
    
    NSSize size = NSMakeSize(endDragPoint.x-startDragPoint.x, endDragPoint.y-startDragPoint.y);
    NSRect selectFrame = NSMakeRect(startDragPoint.x, startDragPoint.y, size.width, size.height);
    
    [self.gridView drawSelectionLayer:selectFrame];
    
    if(_isDragForMultipleSelection){
        [self.controller setSelectIUsInRect:selectFrame];
    }
}

- (void)clearMouseMovement{
    [self.gridView clearGuideLine];
    
    if(_isMouseDownForMoveIU){
        _isMouseDownForMoveIU = NO;
    }
    if(_isMouseDragForIU){
        _isMouseDragForIU = NO;
        [self.controller endFrameMoveWithTransaction:self];
    }
    if(_isDragForMultipleSelection || _isMouseDownForNewIU){
        _isDragForMultipleSelection = NO;
        _isMouseDownForNewIU = NO;
        
        [NSCursor pop];
        [self.gridView resetSelectionLayer];
    }
}

#pragma mark - make new IU
/**
 receive widget notification
 */
- (void)changeWidgetSelection:(NSNotification *)notification{
    _selectedWidgetClassName = [notification.userInfo objectForKey:IUWidgetLibraryKey];
}

- (IUBox *)parentIUWithIdentifier:(NSString *)identifier{
    IUBox *parentIU = [self.controller tryIUBoxByIdentifier:identifier];
    
    int safeIndex =0;
    if(parentIU){
        while(1){
            //safe code
            if(safeIndex > 10000){
                JDFatalLog(@"can't find parent iu more than 10000 times");
                return nil;
            }
            safeIndex++;
            
            //find iu's parent
            if([parentIU canAddIUByUserInput]){
                return parentIU;
            }
            else{
                parentIU = parentIU.parent;
            }
        }
    }
    return nil;

}



@end
