//
//  LMCanvasViewController.m
//  IUEditor
//
//  Created by ChoiSeungmi on 2014. 4. 2..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMCanvasVC.h"

#import "BBWC.h"
#import "LMWindow.h"
#import "LMCanvasView.h"

#import "JDLogUtil.h"
#import "IUFrameDictionary.h"

#import "IUResource.h"

#import "IUBoxes.h"

#import "LMHelpWC.h"
#import "IUFontController.h"
#import "IUDocumentProtocol.h"

@interface LMCanvasVC ()

@end

@implementation LMCanvasVC{
    IUFrameDictionary *frameDict;
    LMHelpWC *helpWC;
    int levelForUpdateJS;
    BOOL isEnableText;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        frameDict = [[IUFrameDictionary alloc] init];;
        _maxFrameWidth = 0;
        levelForUpdateJS =0;
        isEnableText = NO;
    }
    return self;
}

-(void)viewDidLoad{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMQSelect:) name:IUProjectDidChangeSelectedViewPortNotification object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMQMaxSize:) name:IUProjectDidChangeMaxViewPortNotification object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResize:) name:NSWindowDidResizeNotification object:self.view.window];

    
    
    [self addObserver:self forKeyPaths:@[@"sheet.ghostImageName",
                                         @"sheet.ghostX",
                                         @"sheet.ghostY",
                                         @"sheet.ghostOpacity"]
              options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:@"ghostImage"];
    
    
    
    
}


-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    [[self gridView] clearAllLayer];
//    [[self canvasView] loadDefaultZoom];
    [self updateClassHeight];
    
    _sheet = sheet;
}



#pragma mark - views

- (LMCanvasView *)canvasView{
    return (LMCanvasView *)[self view];
}
- (GridView *)gridView{
    return [[self canvasView] gridView];
}
- (WebCanvasView *)webCanvasView{
    return [[self canvasView] webView];
}
- (DOMDocument *)webDocument{
    return [[[self webCanvasView] mainFrame] DOMDocument];
}


#pragma mark - canvas frame
- (void)windowDidResize:(NSNotification *)notification{
    [[self webCanvasView] resizePageContent];
    [[self canvasView] windowDidResize:notification];
}

-(void)changeIUPageHeight:(CGFloat)pageHeight{
    [[self canvasView] setHeightOfMainView:pageHeight];
}


- (void)updateClassHeight{
    //not page class
    //page will be set reported values from javscript
    if([_sheet isKindOfClass:[IUClass class]]){
        NSNumber *classHeight = _sheet.cascadingStyleStorage.height;
        if(classHeight){
            [[self canvasView] setHeightOfMainView:[classHeight floatValue]];
        }
        else{
            [self.canvasView extendMainViewToFullSize];
        }
        
    }
}

- (CGFloat)heightOfCanvas{
    return [[[self canvasView] mainScrollView] frame].size.height;
}

- (void)zoomIn{
    [[self canvasView] zoomIn];
}
- (void)zoomOut{
    [[self canvasView] zoomOut];
}


#pragma mark - MQ
- (void)changeMQSelect:(NSNotification *)notification{
    
    NSInteger selectedSize = [[notification.userInfo valueForKey:IUViewPortKey] integerValue];
    NSInteger maxSize = [[notification.userInfo valueForKey:IUMaxViewPortKey] integerValue];
    
    NSInteger oldSelectedSize = [[notification.userInfo valueForKey:IUOldViewPortKey] integerValue];
    //mq가 바뀌기전에 현재 text를 현재 size에 저장한다.
    [self saveCurrentTextEditorForWidth:oldSelectedSize];
    
    
    [self setSelectedFrameWidth:selectedSize];
    [self setMaxFrameWidth:maxSize];
    
    [(BBWC *)[[NSApp mainWindow] windowController] reloadCurrentSheet:self viewport:selectedSize];
    
    [[self canvasView] updateMainViewOrigin];
    [[self gridView] setSelectedFrameWidth:_selectedFrameWidth];
    
    
    [[self webCanvasView] updateFrameDict];
}


- (void)changeMQMaxSize:(NSNotification *)notification{
    NSInteger selectedSize = [[notification.userInfo valueForKey:IUViewPortKey] integerValue];
    NSInteger maxSize = [[notification.userInfo valueForKey:IUMaxViewPortKey] integerValue];
    //extend to scroll size
    [self.canvasView.mainView setWidth:maxSize];
    
    [self setMaxFrameWidth:maxSize];
    [self setSelectedFrameWidth:selectedSize];
    
    
    [[self webCanvasView] updateFrameDict];
    
}

#pragma mark - IUCanvasController Protocol

- (void)webViewdidFinishLoadFrame{
    [self updateJS];
}



#pragma mark - notification from other Controllers

- (void)ghostImageContextDidChange:(NSDictionary *)change{
    
    NSString *ghostImageName = _sheet.ghostImageName;
    IUResourceFileItem *resourceNode = [self.resourceRootItem resourceFileItemForName:ghostImageName];
    NSImage *ghostImage = [[NSImage alloc] initWithContentsOfFile:resourceNode.absolutePath];
    [[self gridView] setGhostImage:ghostImage];
    
    NSPoint ghostPosition = NSMakePoint(_sheet.ghostX, _sheet.ghostY);
    [[self gridView] setGhostPosition:ghostPosition];
    [[self gridView] setGhostOpacity:_sheet.ghostOpacity];
    
}

- (IUResourceRootItem *)resourceRootItem{
    return [[[[NSApp mainWindow] windowController] document] performSelector:@selector(resourceRootItem)];
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


- (BOOL)makeNewIUWithClassName:(NSString *)className withFrame:(NSRect)frame atParentIU:(IUBox *)parentIU{
    //Distance
    NSString *currentIdentifier;
    if (self.controller.importIUInSelectionChain){
        currentIdentifier =  [self.controller.importIUInSelectionChain modifieldHtmlIDOfChild:parentIU];
    }
    else{
        currentIdentifier = parentIU.htmlID;
    }
    
    //postion을 먼저 정한 후에 add 함
    IUBox *newIU = [[NSClassFromString(className) alloc] initWithPreset];
    
    NSPoint position = [self distanceFromIUIdentifier:currentIdentifier toPointFromWebView:frame.origin];
    
    if ([newIU canChangeXByUserInput]) {
        [newIU.defaultPositionStorage setX:@(position.x) unit:@(IUFrameUnitPixel)];
    }
    if([newIU canChangeYByUserInput]){
        [newIU.defaultPositionStorage setY:@(position.y) unit:@(IUFrameUnitPixel)];
    }
    
    if([newIU canChangeWidthByUserInput]){
        [newIU.defaultStyleStorage setWidth:@(frame.size.width) unit:@(IUFrameUnitPixel)];
    }
    if([newIU canChangeHeightByUserInput]){
        [newIU.defaultStyleStorage setHeight:@(frame.size.height) unit:@(IUFrameUnitPixel)];
    }
    
    BOOL result = [parentIU addIU:newIU error:nil];
    
    [self.controller setSelectedObject:newIU];

    JDTraceLog( @"[IU:%@] : point(%.1f, %.1f) atIU:%@", newIU.htmlID, position.x, position.y, parentIU.htmlID);
    
    return result;
}

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
        [newIU.currentPositionStorage setX:@(position.x) unit:@(IUFrameUnitPixel)];
    }
    if([newIU canChangeYByUserInput]){
        [newIU.currentPositionStorage setY:@(position.y) unit:@(IUFrameUnitPixel)];
    }
    
    [parentIU addIU:newIU error:nil];
    
    [self.controller setSelectedObject:newIU];
    
    JDTraceLog( @"[IU:%@] : point(%.1f, %.1f) atIU:%@", newIU.htmlID, point.x, point.y, parentIU.htmlID);
    return YES;
}

- (void)removeSelectedIUs{
    [self.controller removeSelectedObjects];
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

- (void)startFrameMoveWithTransaction:(id)sender{
    if([sender isKindOfClass:[GridView class]]){
        [[self canvasView] startDraggingFromGridView];
    }
    for(IUBox *obj in self.controller.selectedObjects){
        if([self shouldMoveParent:obj] || [self shouldExtendParent:obj]){
            [obj.parent startFrameMoveWithTransactionForStartFrame:[self absoluteIUFrame:obj.htmlID]];
        }
        [obj startFrameMoveWithTransactionForStartFrame:[self absoluteIUFrame:obj.htmlID]];
        
    }
}

- (void)endFrameMoveWithTransaction:(id)sender{
    for(IUBox *obj in self.controller.selectedObjects){
        if([self shouldMoveParent:obj] || [self shouldExtendParent:obj]){
            [obj.parent endFrameMoveWithTransaction];
        }
        
        [obj endFrameMoveWithTransaction];
        
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
    
    [JDLogUtil timeLogStart:@"moveIU"];
    
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
        [JDLogUtil timeLogStart:@"getpercent"];
        
        
        NSString *frameJS = [NSString stringWithFormat:@"$('#%@').iuPercentFrame()", currentIdentifier];
        id currentValue = [self.webCanvasView evaluateWebScript:frameJS];
        
        [JDLogUtil timeLogEnd:@"getpercent"];
        
        
        NSPoint origianlLocation = [moveObj originalFrame].origin;
        
        if([moveObj canChangeXByUserInput]){
            CGFloat currentX = origianlLocation.x + totalPoint.x;
            CGFloat currentPercentX = [[currentValue valueForKey:@"left"] floatValue];
            if(moveObj.currentPositionStorage.xUnit == nil || [moveObj.currentPositionStorage.xUnit isEqualToNumber:@(IUFrameUnitPixel)]){
                [moveObj.currentPositionStorage setX:@(currentX) unit:@(IUFrameUnitPixel)];
            }
            else{
                [moveObj.currentPositionStorage setX:@(currentPercentX) unit:@(IUFrameUnitPercent)];
            }
        }
        
        if([moveObj canChangeYByUserInput]){
            CGFloat currentY = origianlLocation.y + totalPoint.y;
            CGFloat currentPercentY = [[currentValue valueForKey:@"top"] floatValue];
            if(moveObj.currentPositionStorage.yUnit == nil ||  [moveObj.currentPositionStorage.yUnit isEqualToNumber:@(IUFrameUnitPixel)]){
                [moveObj.currentPositionStorage setY:@(currentY) unit:@(IUFrameUnitPixel)];
            }
            else{
                [moveObj.currentPositionStorage setY:@(currentPercentY) unit:@(IUFrameUnitPercent)];
            }
            
        }
        
        [moveObj updateCSS];
        
    }
    [JDLogUtil timeLogEnd:@"moveIU"];
}

- (void)extendIUToTotalDiffSize:(NSSize)totalSize{
    
    [JDLogUtil timeLogStart:@"extendIU"];
    
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
        
        id currentValue;
        if([moveObj.currentStyleStorage.widthUnit isEqualToNumber:@(IUFrameUnitPercent)]
           || [moveObj.currentStyleStorage.heightUnit isEqualToNumber:@(IUFrameUnitPercent)]){
            NSString *frameJS = [NSString stringWithFormat:@"$('#%@').iuPercentFrame()", currentIdentifier];
            currentValue = [self.webCanvasView evaluateWebScript:frameJS];
        }
        
        NSSize originalSize = [moveObj originalFrame].size;
        
        if([moveObj canChangeWidthByDraggable]){
            CGFloat currentW = originalSize.width + totalSize.width;
            if([moveObj.currentStyleStorage.widthUnit isEqualToNumber:@(IUFrameUnitPixel)]){
                [moveObj.currentStyleStorage setWidth:@(currentW) unit:@(IUFrameUnitPixel)];
            }
            else{
                CGFloat currentPercentW = [[currentValue valueForKey:@"width"] floatValue];
                [moveObj.currentStyleStorage setWidth:@(currentPercentW) unit:@(IUFrameUnitPercent)];
            }
        }
        
        if([moveObj canChangeHeightByDraggable]){
            if([moveObj.currentStyleStorage.heightUnit isEqualToNumber:@(IUFrameUnitPixel)]){
                CGFloat currentH = originalSize.height + totalSize.height;
                [moveObj.currentStyleStorage setHeight:@(currentH) unit:@(IUFrameUnitPixel)];
            }
            else{
                CGFloat currentPercentH = [[currentValue valueForKey:@"height"] floatValue];
                [moveObj.currentStyleStorage setHeight:@(currentPercentH) unit:@(IUFrameUnitPercent)];
            }
            
        }
        
        [moveObj updateCSS];
        
        
    }
    
    [JDLogUtil timeLogEnd:@"extendIU"];
    
}


-(void)IURemoved:(IUBox *)iu{
    
    [self deselectedAllIUs];
    
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
            [[self gridView] removeLayerForIdentifier:iu.htmlID];
            [frameDict.dict removeObjectForKey:iu.htmlID];
            
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
                    if([childIdentifier containsString:@"hover"]){
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
        [self saveElementText:node forIdnetifier:node.idName];
        
    }
    
    list = [self.webDocument.documentElement getElementsByClassName:IUTextEditableClass];
    for (int i=0; i<list.length; i++) {
        //find editor
        DOMHTMLElement *node = (DOMHTMLElement*)[list item:i];
        //save current text
        [self saveElementText:node forIdnetifier:node.idName];
    }
}
- (void)saveElementText:(DOMHTMLElement *)element forIdnetifier:(NSString *)identifier{
    IUBox *iu = [self.controller tryIUBoxByIdentifier:identifier];
    if(iu){
        [iu.cascadingPropertyStorage disableUpdate:self];

        if(element.innerText && [element.innerText stringByTrim].length > 0){
            [[IUFontController sharedFontController] setLastUsedFontToIUBox:iu];
            [iu.cascadingPropertyStorage setObject:element.innerHTML forKey:IUInnerHTMLKey];
        }
        else{
            [iu.cascadingPropertyStorage setObject:element.innerHTML forKey:IUInnerHTMLKey];
        }
        
        [iu.cascadingPropertyStorage enableUpdate:self];
        
    }
    [iu updateCSS];
}

- (void)saveCurrentTextEditor{
    [self saveCurrentTextEditorForWidth:self.selectedFrameWidth];
}

- (void)disableTextEditor{
    [self saveCurrentTextEditor];
    
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
#pragma mark - call web view

-(void)IUClassIdentifier:(NSString*)identifier CSSUpdated:(NSString*)css{
    
    
    [self updateCSS:css selector:identifier];
    
    if([self isSheetHeightChanged:identifier]){
        //CLASS에서 WEBCANVASVIEW의 높이 변화를 위해서
        [self updateClassHeight];
    }
    
    
}

- (BOOL)isSheetHeightChanged:(NSString *)identifier{
    if([identifier isEqualToString:[_sheet cssIdentifier]]
       && [_sheet isKindOfClass:[IUClass class]]){
        return YES;
    }
    return NO;
}

-(void)updateCSS:(NSString *)css selector:(NSString *)selector{
    DOMNodeList *list = [self.webDocument querySelectorAll:selector];
    int length= list.length;
    for(int i=0; i<length; i++){
        DOMHTMLElement *element = (DOMHTMLElement *)[list item:i];
        DOMCSSStyleDeclaration *style = element.style;
        style.cssText = css;
    }
}



- (void)updateJS{
    [[self webCanvasView] runJSAfterRefreshCSS];
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
-(NSString *)cssIDInCSSRule:(NSString *)cssrule{
    
    NSString *css = [cssrule stringByTrim];
    NSArray *cssItems = [css componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"{}"]];
    
    return [cssItems[0] stringByTrim];
}

#pragma mark - frame

- (void)updateGridFrameDictionary:(NSMutableDictionary *)gridFrameDict{
    
    [JDLogUtil timeLogStart:@"updateGridFrame"];
    
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
    
    [JDLogUtil timeLogEnd:@"updateGridFrame"];
    
    
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

#pragma mark - javascript
- (id)callWebScriptMethod:(NSString *)function withArguments:(NSArray *)args{
    return [[self webCanvasView] callWebScriptMethod:function withArguments:args];
}

- (id)evaluateWebScript:(NSString *)script{
    return [[self webCanvasView] evaluateWebScript:script];
}

- (NSRect)pixelFrameForIdentifier:(NSString *)identifier{
    NSString *frameJS = [NSString stringWithFormat:@"$('#%@').iuPosition()", identifier];
    id currentValue = [self evaluateWebScript:frameJS];
    NSRect percentFrame = NSMakeRect([[currentValue valueForKey:@"left"] floatValue],
                                     [[currentValue valueForKey:@"top"] floatValue],
                                     [[currentValue valueForKey:@"width"] floatValue],
                                     [[currentValue valueForKey:@"height"] floatValue]
                                     );
    
    
    return percentFrame;
}
- (NSRect)percentFrameForIdentifier:(NSString *)identifier{
    NSString *frameJS = [NSString stringWithFormat:@"$('#%@').iuPercentFrame()", identifier];
    id currentValue = [self evaluateWebScript:frameJS];
    NSRect pixelFrame = NSMakeRect([[currentValue valueForKey:@"left"] floatValue],
                                   [[currentValue valueForKey:@"top"] floatValue],
                                   [[currentValue valueForKey:@"width"] floatValue],
                                   [[currentValue valueForKey:@"height"] floatValue]
                                   );
    
    
    return pixelFrame;
}
- (NSSize)imageSizeAtPath:(NSString *)path{
    NSString *frameJS = [NSString stringWithFormat:@"getImageSize('%@')", path];
    id currentValue = [self evaluateWebScript:frameJS];
    NSSize imageSize = NSMakeSize([[currentValue valueForKey:@"width"] floatValue],
                                  [[currentValue valueForKey:@"height"] floatValue]
                                  );
    
    
    return imageSize;
}


#pragma mark - copy&paste

- (void)copy:(id)sender{
    [self.controller copySelectedIUToPasteboard:self];
}

- (void)paste:(id)sender{
    [self.controller pasteToSelectedIU:self];
}

@end
