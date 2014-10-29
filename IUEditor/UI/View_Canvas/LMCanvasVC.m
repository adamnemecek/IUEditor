//
//  LMCanvasViewController.m
//  IUEditor
//
//  Created by ChoiSeungmi on 2014. 4. 2..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMCanvasVC.h"

#import "LMWC.h"
#import "LMWindow.h"
#import "JDLogUtil.h"
#import "IUFrameDictionary.h"
#import "IUBox.h"
#import "IUCarousel.h"
#import "IUCarouselItem.h"
#import "InnerSizeBox.h"
#import "IUSection.h"
#import "IUImport.h"
#import "IUMenuItem.h"

#import "LMHelpWC.h"

#pragma mark - debug
#if DEBUG
#import "LMDebugSourceWC.h"

#endif

#import "IUPage.h"
#import "IUBackground.h"

@interface LMCanvasVC ()

#pragma mark - debug window
@property (weak) IBOutlet NSButton *debugBtn;
#if DEBUG
@property LMDebugSourceWC *debugWC;

#endif

@end

@implementation LMCanvasVC{
    IUFrameDictionary *frameDict;
    LMHelpWC *helpWC;
    int levelForUpdateCSS;
    int levelForUpdateJS;
    int levelForUpdateHTML;
    BOOL isEnableText;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        frameDict = [[IUFrameDictionary alloc] init];;
        _maxFrameWidth = 0;
        levelForUpdateCSS = 0;
        levelForUpdateJS =0;
        levelForUpdateHTML= 0;
        isEnableText = NO;
    }
    return self;
}

-(void)awakeFromNib{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMQSelect:) name:IUNotificationMQSelectedWithInfo object:[[self.view window] windowController]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMQMaxSize:) name:IUNotificationMQMaxChanged object:[[self.view window] windowController]];
    
    
    
    [self addObserver:self forKeyPaths:@[@"sheet.ghostImageName",
                                         @"sheet.ghostX",
                                         @"sheet.ghostY",
                                         @"sheet.ghostOpacity"]
              options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:@"ghostImage"];
    
    
#if DEBUG
    
    _debugWC = [[LMDebugSourceWC alloc] initWithWindowNibName:@"LMDebugSourceWC"];
    _debugWC.canvasVC = self;
    [_debugBtn setHidden:NO];
#else
    [_debugBtn setHidden:YES];
#endif
    

    
}

- (void)prepareDealloc{
#if DEBUG
    _debugWC.canvasVC = nil;
#endif

}

-(void) dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IUNotificationMQSelected object:[[self.view window] windowController]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IUNotificationMQMaxChanged object:[[self.view window] windowController]];
    
    [self removeObserver:self forKeyPaths:@[@"sheet.ghostImageName",
                                            @"sheet.ghostX",
                                            @"sheet.ghostY",
                                            @"sheet.ghostOpacity"] context:@"ghostImage"];
    [JDLogUtil log:IULogDealloc string:@"CanvasVC"];
}


-(void)setController:(IUController *)controller{
    _controller = controller;
    [_controller addObserver:self forKeyPath:@"selectedObjects" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld|NSKeyValueObservingOptionPrior context:nil];
}

- (void)setSheet:(IUSheet *)sheet{
    NSAssert(self.documentBasePath != nil, @"resourcePath is nil");
    if (self.documentBasePath == nil) {
        return;
    }
    JDSectionInfoLog( IULogSource, @"resourcePath  : %@", self.documentBasePath);
    [[self gridView] clearAllLayer];
    [_sheet setDelegate:nil];
    _sheet = sheet;
    [_sheet setDelegate:self];
    
    NSString *editorSrc = [sheet.editorSource copy];
    [[[self webView] mainFrame] loadHTMLString:editorSrc baseURL:[NSURL fileURLWithPath:self.documentBasePath]];
    
    [self updateClassHeight];
}


- (void)reloadSheet{
    if(_sheet){
        [self setSheet:_sheet];
    }
}


#pragma mark - views

- (LMCanvasView *)canvasView{
    return (LMCanvasView *)[self view];
}
- (GridView *)gridView{
    return [[self canvasView] gridView];
}
- (WebCanvasView *)webView{
    return [[self canvasView] webView];
}
- (DOMDocument *)webDocument{
    return [[[self webView] mainFrame] DOMDocument];
}


#pragma mark - canvas frame
/** change webview width by media query size
 */
- (void)updateWebViewWidth{
    NSString *outerCSS = [NSString stringWithFormat:@"width:%ldpx", self.selectedFrameWidth];
    [self IUClassIdentifier:@"#"IUSheetOuterIdentifier CSSUpdated:outerCSS];
    [self updateJS];
}

- (void)windowDidResize:(NSNotification *)notification{
    [[self webView] resizePageContent];
    [[self canvasView] windowDidResize:notification];
    [self updateWebViewWidth];
}

-(void)changeIUPageHeight:(CGFloat)pageHeight{
    [[self canvasView] setHeightOfMainView:pageHeight];
}


- (void)updateClassHeight{
    //not page class
    //page will be set reported values from javscript
    if([_sheet isKindOfClass:[IUClass class]]){
        [(LMCanvasView*)self.view extendMainViewToFullSize];
    }
}

- (CGFloat)heightOfCanvas{
    return [[[self canvasView] mainScrollView] frame].size.height;
}



#pragma mark - MQ
- (void)changeMQSelect:(NSNotification *)notification{
    
    NSInteger selectedSize = [[notification.userInfo valueForKey:IUNotificationMQSize] integerValue];
    NSInteger maxSize = [[notification.userInfo valueForKey:IUNotificationMQMaxSize] integerValue];
    
    NSInteger oldSelectedSize = [[notification.userInfo valueForKey:IUNotificationMQOldSize] integerValue];
    if(oldSelectedSize == maxSize){
        [self saveCurrentTextEditorForWidth:IUCSSDefaultViewPort];
    }
    else{
        [self saveCurrentTextEditorForWidth:oldSelectedSize];
    }
    
    
    [self setSelectedFrameWidth:selectedSize];
    [self setMaxFrameWidth:maxSize];
    [self reloadSheet];
    
    [[self canvasView] setRulerOffsets];
    [[self gridView] setSelectedFrameWidth:_selectedFrameWidth];

    
    [[self webView] updateFrameDict];
}


- (void)changeMQMaxSize:(NSNotification *)notification{
    NSInteger selectedSize = [[notification.userInfo valueForKey:IUNotificationMQSize] integerValue];
    NSInteger maxSize = [[notification.userInfo valueForKey:IUNotificationMQMaxSize] integerValue];
    //extend to scroll size
    [self.canvasView.mainView setWidth:maxSize];
    
    [self setMaxFrameWidth:maxSize];
    [self setSelectedFrameWidth:selectedSize];
    
    
    [[self webView] updateFrameDict];
    
}

#pragma mark - IUCanvasController Protocol

- (void)webViewdidFinishLoadFrame{
    
    [self disableUpdateJS:self];
    
    [_sheet updateCSS];
    for(IUBox *box in _sheet.allChildren){
        [box updateCSS];
    }
    
    [self enableUpdateJS:self];
    
    NSString *htmlSource =  [(DOMHTMLElement *)[[self webDocument] documentElement] outerHTML];
    JDTraceLog(@"%@", htmlSource);

    [self updateWebViewWidth];
    [self updateJS];
}



#pragma mark - notification from other Controllers

- (void)ghostImageContextDidChange:(NSDictionary *)change{
    
    NSString *ghostImageName = _sheet.ghostImageName;
    IUResourceFile *resourceNode = [_resourceManager resourceFileWithName:ghostImageName];
    NSImage *ghostImage = [[NSImage alloc] initWithContentsOfFile:resourceNode.absolutePath];
    [[self gridView] setGhostImage:ghostImage];
    
    NSPoint ghostPosition = NSMakePoint(_sheet.ghostX, _sheet.ghostY);
    [[self gridView] setGhostPosition:ghostPosition];
    [[self gridView] setGhostOpacity:_sheet.ghostOpacity];
}


-(void)selectedObjectsDidChange:(NSDictionary*)change{
    [JDLogUtil log:IULogAction key:@"CanvasVC:observed" string:[self.controller.selectedIdentifiers description]];
    
    [[self gridView] removeAllSelectionLayers];
    [[self gridView] removeAllTextPointLayer];
    
    for(NSString *identifier in self.controller.selectedIdentifiersWithImportIdentifier){
        if([frameDict.dict objectForKey:identifier]){
            NSRect frame = [[frameDict.dict objectForKey:identifier] rectValue];
            [[self gridView] addSelectionLayerWithIdentifier:identifier withFrame:frame];
            [[self gridView] addTextPointLayerWithIdentifier:identifier withFrame:frame];
        }
    }
}

#pragma mark - Manage IUs

- (BOOL)makeNewIUByDragAndDrop:(IUBox *)newIU atPoint:(NSPoint)point atParentIU:(IUBox *)parentIU{
    
    //Distance
    NSString *currentIdentifier;
    if (self.controller.importIUInSelectionChain){
        currentIdentifier =  [self.controller.importIUInSelectionChain modifieldHtmlIDOfChild:parentIU];
    }
    else{
        currentIdentifier = parentIU.htmlID;
    }
    
    //postion을 먼저 정한 후에 add 함
    NSPoint position = [self distanceFromIUIdentifier:currentIdentifier toPointFromWebView:point];
    
    if ([newIU canChangeXByUserInput]) {
        [newIU setPixelX:position.x percentX:0];
    }
    if([newIU canChangeYByUserInput]){
        [newIU setPixelY:position.y percentY:0];
    }
    
    [parentIU addIU:newIU error:nil];
    [newIU confirmIdentifier];
    
    [self.controller setSelectedObject:newIU];
    
    JDTraceLog( @"[IU:%@] : point(%.1f, %.1f) atIU:%@", newIU.htmlID, point.x, point.y, parentIU.htmlID);
    return YES;
}

- (void)removeSelectedIUs{
    NSMutableArray *alternatedSelection = [NSMutableArray array];
    
    for(IUBox *box in [self.controller selectedObjects]){
        //selected objects can contain removed object
        if([alternatedSelection containsObject:box.htmlID]){
            [alternatedSelection removeObject:box.htmlID];
        }
        
        //add parent or not to be removed objects add to alternated selection
        if([box canRemoveIUByUserInput]){
            [box.parent removeIU:box];
            [alternatedSelection addObject:box.parent.htmlID];
        }
        else{
            [alternatedSelection addObject:box.htmlID];
        }
    }
    
    [self.controller setSelectedObjectsByIdentifiers:alternatedSelection];
    [self.controller rearrangeObjects];
    
}

- (IUBox *)tryIUBoxByIdentifier:(NSString *)identifier{
    return [self.controller tryIUBoxByIdentifier:identifier];
}

-(NSUInteger)countOfSelectedIUs{
    return [self.controller.selectedObjects count];
}

- (BOOL)containsIdentifier:(NSString *)identifier{
    if ([self.controller.selectedIdentifiersWithImportIdentifier containsObject:identifier]){
        return YES;
    }
    else {
        return NO;
    }
}

- (void)deselectedAllIUs{
    [self.controller setSelectionIndexPath:nil];
}

- (void)deselectedIdentifier:(NSString *)identifier{
    if(identifier == nil){
        return;
    }
    NSMutableArray *selectedObject  =  [[self.controller selectedIdentifiersWithImportIdentifier] mutableCopy];
    [selectedObject removeObject:identifier];
    [self.controller trySetSelectedObjectsByIdentifiers:selectedObject];
}

- (void)setSelectedIdentifier:(NSString *)identifier{
    NSString *selectedIdentifier = identifier;
    IUBox *selectIU = [self.controller tryIUBoxByIdentifier:identifier];
    
    if(selectIU){
        if([selectIU isKindOfClass:[IUItem class]]){
            if( [((IUItem *)selectIU) shouldSelectParentFirst]){
                IUBox *parentIU = selectIU.parent;
                if([self.controller.selectedObjects containsObject:parentIU] == NO &&
                   [self.controller.selectedObjects containsObject:selectIU] == NO){
                    selectedIdentifier = parentIU.htmlID;
                }
            }
        }
        /*
         Even it is selected object, still select it again.
         (IUClass is not shown selected until it is selected again)
         */
        [self.controller trySetSelectedObjectsByIdentifiers:@[selectedIdentifier]];
    }
    
}
- (void)addSelectedIdentifier:(NSString *)identifier{
    if(identifier == nil){
        return;
    }
    
    if([self.controller.selectedIdentifiersWithImportIdentifier containsObject:identifier]){
        return;
    }
    NSArray *array = [self.controller.selectedIdentifiersWithImportIdentifier arrayByAddingObject:identifier];
    [self.controller trySetSelectedObjectsByIdentifiers:array];
}

- (void)setSelectIUsInRect:(NSRect)frame{
    NSArray *keys = [frameDict.dict allKeys];
    
    [self deselectedAllIUs];
    
    for(NSString *key in keys){
        NSRect iuframe = [[frameDict.dict objectForKey:key] rectValue];
        if( NSIntersectsRect(iuframe, frame) ){
            [self addSelectedIdentifier:key];
        }
    }
}


#pragma mark - IUFrame

- (void)startFrameMoveWithUndoManager:(id)sender{
    if([sender isKindOfClass:[GridView class]]){
        [((LMCanvasView *)[self view]) startDraggingFromGridView];
    }
    for(IUBox *obj in self.controller.selectedObjects){
        if([self shouldMoveParent:obj] || [self shouldExtendParent:obj]){
            [obj.parent startFrameMoveWithUndoManager];
        }
        [obj startFrameMoveWithUndoManager];
        
    }
}

- (void)endFrameMoveWithUndoManager:(id)sender{
    for(IUBox *obj in self.controller.selectedObjects){
        if([self shouldMoveParent:obj] || [self shouldExtendParent:obj]){
            [obj.parent endFrameMoveWithUndoManager];
        }
        
        [obj endFrameMoveWithUndoManager];
        
    }
}
//check parent IU before move
- (BOOL)shouldMoveParent:(IUBox *)obj{
    if([obj respondsToSelector:@selector(shouldMoveParent)]){
        return [[obj performSelector:@selector(shouldMoveParent)] boolValue];
    }
    
    return  NO;
}
//check parent IU before extend
- (BOOL)shouldExtendParent:(IUBox *)iu{
    if([iu respondsToSelector:@selector(shouldExtendParent)]){
        return [[iu performSelector:@selector(shouldExtendParent)] boolValue];
    }
    return NO;
}

//drag & drop after select IU
- (void)moveIUToTotalDiffPoint:(NSPoint)totalPoint{
    
    for(IUBox *obj in self.controller.selectedObjects){
        
        IUBox *moveObj= obj;
        
        if([self shouldMoveParent:obj]){
            moveObj = obj.parent;
        }
        
        NSString *currentIdentifier;
        if (self.controller.importIUInSelectionChain){
            currentIdentifier =  [self.controller.importIUInSelectionChain modifieldHtmlIDOfChild:moveObj];
        }
        else {
            currentIdentifier = moveObj.htmlID;
        }
        NSString *frameJS = [NSString stringWithFormat:@"$('#%@').iuPercentFrame()", currentIdentifier];
        id currentValue = [self.webView evaluateWebScript:frameJS];

        
        NSPoint origianlLocation = [moveObj originalPoint];
        
        if([moveObj canChangeXByUserInput]){
            CGFloat currentX = origianlLocation.x + totalPoint.x;
            CGFloat currentPercentX = [[currentValue valueForKey:@"left"] floatValue];
            [moveObj setPixelX:currentX percentX:currentPercentX];
        }
        
        if([moveObj canChangeYByUserInput]){
            CGFloat currentY = origianlLocation.y + totalPoint.y;
            CGFloat currentPercentY = [[currentValue valueForKey:@"left"] floatValue];
            [moveObj setPixelY:currentY percentY:currentPercentY];
            
        }

        [moveObj updateCSS];
        
    }
}

- (void)extendIUToTotalDiffSize:(NSSize)totalSize{
    //drag pointlayer
    for(IUBox *obj in self.controller.selectedObjects){
        IUBox *moveObj= obj;
        
        if([self shouldExtendParent:obj]){
            moveObj = obj.parent;
        }
        
        NSString *currentIdentifier;
        if (self.controller.importIUInSelectionChain){
            currentIdentifier =  [self.controller.importIUInSelectionChain modifieldHtmlIDOfChild:moveObj];
        }
        else {
            currentIdentifier = moveObj.htmlID;
        }
        NSString *frameJS = [NSString stringWithFormat:@"$('#%@').iuPercentFrame()", currentIdentifier];
        id currentValue = [self.webView evaluateWebScript:frameJS];
        
        
        NSSize originalSize = [moveObj originalSize];
        
        if([moveObj canChangeWidthByDraggable]){
            CGFloat currentW = originalSize.width + totalSize.width;
            CGFloat currentPercentW = [[currentValue valueForKey:@"width"] floatValue];
            [moveObj setPixelWidth:currentW percentWidth:currentPercentW];
        }
        
        if([moveObj canChangeHeightByDraggable]){
            CGFloat currentH = originalSize.height + totalSize.height;
            CGFloat currentPercentH = [[currentValue valueForKey:@"height"] floatValue];
            [moveObj setPixelHeight:currentH percentHeight:currentPercentH];
            
        }
        
        [moveObj updateCSS];
        
        
    }
    
}


-(void)IURemoved:(NSString*)identifier{
    
    [self deselectedAllIUs];
    IUBox *iu = [_controller tryIUBoxByIdentifier:identifier];
    
    //remove sheet css
    NSArray *cssIds = [iu cssIdentifierArray];
    for (NSString *identifier in cssIds){
        if([identifier containsString:@"hover"]){
            [self removeCSSTextInDefaultSheetWithIdentifier:identifier];
        }
    }
    
    
    if(iu){
        //remove layer
        if([iu isKindOfClass:[IUImport class]]){
            [[self gridView] removeLayerForIdentifier:identifier];
            [frameDict.dict removeObjectForKey:identifier];
            
            for(IUBox *box in iu.allChildren){
                NSString *currentIdentifier =  [(IUImport *)iu modifieldHtmlIDOfChild:box];
                [[self gridView] removeLayerForIdentifier:currentIdentifier];
                [frameDict.dict removeObjectForKey:currentIdentifier];
            }
        }
        else if([iu.sheet isKindOfClass:[IUClass class]]){
            for (IUBox *import in [(IUClass*)iu.sheet references]) {
                
                NSMutableArray *allIU = [iu.allChildren mutableCopy];
                [allIU addObject:iu];
                
                for(IUBox *box in allIU){
                    NSString *currentIdentifier =  [(IUImport *)import modifieldHtmlIDOfChild:box];
                    [[self gridView] removeLayerForIdentifier:currentIdentifier];
                    [frameDict.dict removeObjectForKey:currentIdentifier];
                }
                
            }
            
        }
        else{
            NSMutableArray *allIU = [iu.allChildren mutableCopy];
            [allIU addObject:iu];
            
            
            for(IUBox *box in allIU){
                
                [[self gridView] removeLayerForIdentifier:box.htmlID];
                [frameDict.dict removeObjectForKey:box.htmlID];
                
                //remove sheet css
                NSArray *childIds= [box cssIdentifierArray];
                for (NSString *childIdentifier in childIds){
                    if([identifier containsString:@"hover"]){
                        [self removeCSSTextInDefaultSheetWithIdentifier:childIdentifier];
                    }
                }
            }
        }
    }
}



#pragma mark - Text Editor

- (void)saveCurrentTextEditorForWidth:(NSInteger)width{
    DOMNodeList *list = [self.webDocument.documentElement getElementsByClassName:IUTextAddibleClass];
    for (int i=0; i<list.length; i++) {
        //find editor
        DOMHTMLElement *node = (DOMHTMLElement*)[list item:i];
        
        //save current text
        IUBox *iu = [self.controller tryIUBoxByIdentifier:node.idName];
        if(iu){
            iu.text = node.innerText;
        }
        
        
    }
    
    list = [self.webDocument.documentElement getElementsByClassName:IUTextEditableClass];
    for (int i=0; i<list.length; i++) {
        //find editor
        DOMHTMLElement *node = (DOMHTMLElement*)[list item:i];
        //save current text
        IUBox *iu = [self.controller tryIUBoxByIdentifier:node.idName];
        if(iu){
            [iu.mqData setValue:node.innerHTML forTag:IUMQDataTagInnerHTML forViewport:width];
        }
        [iu updateCSS];
        
    }
}

- (void)disableTextEditor{
    
    if(self.selectedFrameWidth == self.maxFrameWidth){
        [self saveCurrentTextEditorForWidth:IUCSSDefaultViewPort];
    }
    else{
        [self saveCurrentTextEditorForWidth:self.selectedFrameWidth];
    }
    
    //remove current editor
    DOMNodeList *list = [self.webDocument.documentElement getElementsByClassName:IUTextAddibleClass];
    for (int i=0; i<list.length; i++) {
        //find editor
        DOMHTMLElement *node = (DOMHTMLElement*)[list item:i];
        NSString *currentClass = [node getAttribute:@"class"];
        [node setAttribute:@"class" value:[currentClass stringByReplacingOccurrencesOfString:IUTextAddibleClass withString:@""]];
        NSString *identifier = node.idName;
        
        //remove current editor
        NSString *removeMCE = [NSString stringWithFormat:@"tinyMCE.execCommand('mceRemoveEditor', true, '%@');", identifier];
        [self evaluateWebScript:removeMCE];

    }
    
    list = [self.webDocument.documentElement getElementsByClassName:IUTextEditableClass];
    for (int i=0; i<list.length; i++) {
        //find editor
        DOMHTMLElement *node = (DOMHTMLElement*)[list item:i];
        NSString *currentClass = [node getAttribute:@"class"];
        [node setAttribute:@"class" value:[currentClass stringByReplacingOccurrencesOfString:IUTextEditableClass withString:@""]];
        NSString *identifier = node.idName;
        
        //remove editor
        NSString *removeMCE = [NSString stringWithFormat:@"tinyMCE.execCommand('mceRemoveEditor', true, '%@');", identifier];
        [self evaluateWebScript:removeMCE];
        
    }
    
    isEnableText = NO;

}
- (BOOL)isEnableTextEditor{
    return isEnableText;
}

- (void)enableTextEditorForSelectedIU{
    if(self.controller.selectedObjects.count != 1 || isEnableText){
        return;
    }
    
    IUBox *iu = [self.controller.selectedObjects firstObject];
 
    
    IUTextInputType inputType = [iu textInputType];
    NSString *className, *fnName;
    if (inputType == IUTextInputTypeNone || inputType == IUTextInputTypeTextField) {
        return;
    }
    else if(inputType == IUTextInputTypeAddible){
        className = IUTextAddibleClass;
        fnName = @"iuAddEditorAddible";
        NSString *alertString = [NSString stringWithFormat:@"Text Typing Mode : %@", iu.name];
        [JDUIUtil hudAlert:alertString second:2];
    }
    else if(inputType == IUTextInputTypeEditable){
        className = IUTextEditableClass;
        fnName = @"iuAddEditorEditable";
        NSString *alertString = [NSString stringWithFormat:@"Text Editor Mode : %@", iu.name];
        [JDUIUtil hudAlert:alertString second:2];
    }
    NSString *classidentifer = [self.controller.selectedIdentifiers firstObject];
    [self IUClassIdentifier:classidentifer addClass:className];
    
    NSString *identifer = [self.controller.selectedIdentifiersWithImportIdentifier firstObject];
    NSString *reloadMCE =[NSString stringWithFormat:@"tinyMCE.execCommand('%@', true, '%@');",fnName, identifer];
    [self evaluateWebScript:reloadMCE];
    isEnableText = YES;

    
}

/**
 현재 text 수정중인 IU에만 class를 추가할수있도록 사용할예정.
 */
-(void)IUClassIdentifier:(NSString *)classIdentifier addClass:(NSString *)className{
    DOMNodeList *list = [self.webDocument.documentElement getElementsByClassName:classIdentifier];
    for (int i=0; i<list.length; i++) {
        DOMHTMLElement *node = (DOMHTMLElement*)[list item:i];
        NSString *currentClass = [node getAttribute:@"class"];
        if([currentClass containsString:className] == NO){
            [node setAttribute:@"class" value:[currentClass stringByAppendingFormat:@" %@", className]];
        }
    }
}


#pragma mark - JS

- (id)callWebScriptMethod:(NSString *)function withArguments:(NSArray *)args{
    return [[self webView] callWebScriptMethod:function withArguments:args];
}
- (id)evaluateWebScript:(NSString *)script{
    return [[self webView] evaluateWebScript:script];
}
- (void)updateJS{
    if( [self isUpdateJSEnabled]==YES){
        [[self webView] runJSAfterRefreshCSS];
    }
}

#pragma mark - frame

- (void)updateGridFrameDictionary:(NSMutableDictionary *)gridFrameDict{
    
    [[self gridView] updateLayerRect:gridFrameDict];
    
    NSArray *keys = [gridFrameDict allKeys];
    for(NSString *key in keys){
        if([frameDict.dict objectForKey:key]){
            [frameDict.dict removeObjectForKey:key];
        }
        [frameDict.dict setObject:[gridFrameDict objectForKey:key] forKey:key];
    }
    //draw guide line
    for (IUBox *iu in self.controller.selectedObjects){
        if (self.controller.importIUInSelectionChain){
            NSString *currentID =  [self.controller.importIUInSelectionChain modifieldHtmlIDOfChild:iu];
            [[self gridView] drawGuideLine:[frameDict lineToDrawSamePositionWithIU:currentID]];
            
        }
        else{
            [[self gridView] drawGuideLine:[frameDict lineToDrawSamePositionWithIU:iu.htmlID]];
        }
    }
    
}

- (NSRect)absoluteIUFrame:(NSString *)identifier{
    NSRect iuframe = [[frameDict.dict objectForKey:identifier] rectValue];
    return iuframe;
}

- (NSPoint)distanceFromIUIdentifier:(NSString *)identifier toPointFromWebView:(NSPoint)point{

    
    NSRect iuframe = [self absoluteIUFrame:identifier];
    NSPoint distance = NSMakePoint(point.x-iuframe.origin.x,
                                   point.y - iuframe.origin.y);
    return distance;
}



#pragma mark - Manage DOMNode
#pragma mark - HTML

-(void)IUHTMLIdentifier:(NSString*)identifier HTML:(NSString *)html{
    
    //element를 바꾸기 전에 현재 text editor를 disable시켜야지 text editor가 제대로 동작함.
    //editor remove가 제대로 돌아가야 함.
    [self disableTextEditor];
    
    DOMHTMLElement *currentElement = (DOMHTMLElement *)[self.webDocument getElementById:identifier];
    if(currentElement){
        //change html text
        [currentElement setOuterHTML:html];
    }
}


#pragma mark - CSS

/**
 @brief get element line count by only selected iu
 */
-(NSInteger)countOfLineWithIdentifier:(NSString *)identifier{
    DOMNodeList *list = [self.webDocument getElementsByClassName:identifier];
    if(list.length > 0){
        DOMHTMLElement *element = (DOMHTMLElement *)[list item:0];
        DOMNodeList *brList  = [element getElementsByTagName:@"br"];
        int count = brList.length;
        DOMHTMLElement *lastElement = (DOMHTMLElement *)[element.childNodes item:element.childNodes.length-1];
        if([lastElement isKindOfClass:[DOMHTMLBRElement class]]==NO){
            count++;
        }
        return count;
    }
    return 0;
}


-(void)IUClassIdentifier:(NSString*)identifier CSSUpdated:(NSString*)css{
    
    if([self isUpdateCSSEnabled]){
        if([identifier containsString:@":hover"]){
            [self updateHoverCSS:css identifier:identifier];
        }
        else{
            [self updateCSS:css selector:identifier];
        }
        
        if([self isSheetHeightChanged:identifier]){
            //CLASS에서 WEBCANVASVIEW의 높이 변화를 위해서
            [self updateClassHeight];
        }
    }
   
}

- (BOOL)isSheetHeightChanged:(NSString *)identifier{
    if([identifier isEqualToString:[_sheet cssIdentifier]]
       && [_sheet isKindOfClass:[IUClass class]]){
        return YES;
    }
    return NO;
}

/**
 @brief update css - inline attribute : style
 */
-(void)updateCSS:(NSString *)css selector:(NSString *)selector{
    DOMNodeList *list = [self.webDocument querySelectorAll:selector];
    int length= list.length;
    for(int i=0; i<length; i++){
        DOMHTMLElement *element = (DOMHTMLElement *)[list item:i];
        DOMCSSStyleDeclaration *style = element.style;
        style.cssText = css;
    }
}
/**
 @brief update css - style sheet
 */

-(void)updateHoverCSS:(NSString *)css identifier:(NSString *)identifier{
    [JDLogUtil log:IULogSource key:@"css source" string:css];
    
    if(css.length == 0){
        //nothing to do
        [self removeCSSTextInDefaultSheetWithIdentifier:identifier];
    }else{
        NSString *cssText = [NSString stringWithFormat:@"%@{%@}", identifier, css];
        //default setting
        [self setIUStyle:cssText withID:identifier];
    }
}

- (void)setIUStyle:(NSString *)cssText withID:(NSString *)iuID{
    DOMHTMLStyleElement *sheetElement = (DOMHTMLStyleElement *)[[self webDocument] getElementById:@"default"];
    NSString *newCSSText = [self innerCSSText:sheetElement.innerHTML byAddingCSSText:cssText withID:iuID];
    [sheetElement setInnerHTML:newCSSText];
    
}

-(NSString *)cssIDInCSSRule:(NSString *)cssrule{
    
    NSString *css = [cssrule stringByTrim];
    NSArray *cssItems = [css componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"{}"]];
    
    return [cssItems[0] stringByTrim];
}

- (NSString *)innerCSSText:(NSString *)innerCSSText byAddingCSSText:(NSString *)cssText withID:(NSString *)identifier
{
    NSMutableString *innerCSSHTML = [NSMutableString stringWithString:@"\n"];
    NSString *trimmedInnerCSSHTML = [innerCSSText  stringByTrim];
    NSArray *cssRuleList = [trimmedInnerCSSHTML componentsSeparatedByString:@"\n"];
    
    for(NSString *rule in cssRuleList){
        if(rule.length == 0){
            continue;
        }
        NSString *ruleID = [self cssIDInCSSRule:rule];
        NSString *modifyidentifier = [identifier stringByTrim];
        if([ruleID isEqualToString:modifyidentifier] == NO){
            [innerCSSHTML appendString:[NSString stringWithFormat:@"\t%@\n", [rule stringByTrim]]];
        }
    }
    
    [innerCSSHTML appendString:cssText];
    [innerCSSHTML appendString:@"\n"];
    
    return innerCSSHTML;
}


- (void)removeCSSTextInDefaultSheetWithIdentifier:(NSString *)identifier{
    DOMHTMLStyleElement *sheetElement = (DOMHTMLStyleElement *)[[self webDocument] getElementById:@"default"];
    NSString *newCSSText = [self removeCSSText:sheetElement.innerHTML withID:identifier];
    [sheetElement setInnerHTML:newCSSText];
}

- (NSString *)removeCSSText:(NSString *)innerCSSText withID:(NSString *)identifier
{
    NSMutableString *innerCSSHTML = [NSMutableString stringWithString:@"\n"];
    NSString *trimmedInnerCSSHTML = [innerCSSText  stringByTrim];
    NSArray *cssRuleList = [trimmedInnerCSSHTML componentsSeparatedByString:@"\n"];
    
    for(NSString *rule in cssRuleList){
        if(rule.length == 0){
            continue;
        }
        NSString *ruleID = [self cssIDInCSSRule:rule];
        NSString *modifiedIdentifier = [identifier stringByTrim];
        if([ruleID isEqualToString:modifiedIdentifier] == NO){
            [innerCSSHTML appendString:[NSString stringWithFormat:@"\t%@\n", [rule stringByTrim]]];
        }
    }
    
    return innerCSSHTML;
}


#pragma mark - enable, disable

- (void)enableUpdateAll:(id)sender{
    [self enableUpdateHTML:sender];
    [self enableUpdateCSS:sender];
    [self enableUpdateJS:sender];
}
- (void)disableUpdateAll:(id)sender{
    [self disableUpdateHTML:sender];
    [self disableUpdateCSS:sender];
    [self disableUpdateJS:sender];
}

- (void)enableUpdateCSS:(id)sender{
    levelForUpdateCSS++;
}
- (void)disableUpdateCSS:(id)sender{
    levelForUpdateCSS--;
    
    if(levelForUpdateCSS > 0){
        JDFatalLog(@"disableUpdateCSS is not pair, more than enableUpdate");
        assert(0);
    }
}
-(BOOL)isUpdateCSSEnabled{
    if(levelForUpdateCSS==0){
        return YES;
    }
    else{
        return NO;
    }
}

-(void)enableUpdateJS:(id)sender{
    levelForUpdateJS++;
}
-(void)disableUpdateJS:(id)sender{
    levelForUpdateJS--;
    
    if(levelForUpdateJS > 0){
        JDFatalLog(@"levelForUpdateJS is not pair, more than enableUpdate");
        assert(0);
    }
}
-(BOOL)isUpdateJSEnabled{
    if(levelForUpdateJS==0){
        return YES;
    }
    else{
        return NO;
    }
}

- (void)enableUpdateHTML:(id)sender{
    levelForUpdateHTML++;
}

-(void)disableUpdateHTML:(id)sender{
    levelForUpdateHTML--;
    
    if(levelForUpdateHTML > 0){
        JDFatalLog(@"enableUpdateHTML is not pair, more than enableUpdate");
        assert(0);
    }
}

-(BOOL)isUpdateHTMLEnabled{
    if(levelForUpdateHTML==0){
        return YES;
    }
    else{
        return NO;
    }
}

#pragma mark - copy&paste

- (void)copy:(id)sender{
    [self.controller copySelectedIUToPasteboard:self];
}

- (void)paste:(id)sender{
    [self.controller pasteToSelectedIU:self];
}



#pragma mark - debug
#if DEBUG

- (void)applyHtmlString:(NSString *)html{
    [[[self webView] mainFrame] loadHTMLString:html baseURL:[NSURL fileURLWithPath:self.documentBasePath]];
}

- (void)reloadOriginalDocument{
    [self setSheet:_sheet];
}

- (IBAction)showCurrentSource:(id)sender {
    NSString *htmlSource =  [(DOMHTMLElement *)[[[[self webView] mainFrame] DOMDocument] documentElement] outerHTML];
    [_debugWC showWindow:self];
    [_debugWC setCurrentSource:htmlSource];
}

#endif



@end
