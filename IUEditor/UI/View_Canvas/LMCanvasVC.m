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
#import "SizeView.h"
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
    
    [self addObserver:self forKeyPath:@"view.sizeView.sizeArray" options:NSKeyValueObservingOptionInitial context:@"mqCount"];
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
    [((LMCanvasView *)self.view) prepareDealloc];

}

-(void) dealloc{
    [self removeObserver:self forKeyPath:@"view.sizeView.sizeArray" context:@"mqCount"];
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


-(LMCanvasView*)view{
    return (LMCanvasView*)[super view];
}

- (void)windowDidResize:(NSNotification *)notification{
    [[self webView] resizePageContent];
}


-(void)changeIUPageHeight:(CGFloat)pageHeight minHeight:(CGFloat)minHeight{
    [(LMCanvasView*)self.view setHeightOfMainView:pageHeight];
    if([self.sheet isKindOfClass:[IUPage class]]){
        IUPage *page = (IUPage *)self.sheet;
        [page.pageContent.css setValueWithoutUpdateCSS:@(minHeight) forTag:IUCSSTagMinHeight];
    }
}

- (void)addFrame:(NSInteger)frameSize{
    [[self sizeView] addFrame:frameSize];
}


#pragma mark -
#pragma mark call by sizeView


- (SizeView *)sizeView{
    return ((LMCanvasView *)(self.view)).sizeView;
    
}

#pragma mark -
#pragma mark call by webView

- (WebCanvasView *)webView{
    return ((LMCanvasView *)self.view).webView;
}

- (DOMDocument *)DOMDoc{
    return [[[self webView] mainFrame] DOMDocument];
}



#pragma mark - Drag & drop

- (BOOL)makeNewIUByDragAndDrop:(IUBox *)newIU atPoint:(NSPoint)point atIU:(NSString *)parentIUID{
    IUBox *parentIU = [self.controller tryIUBoxByIdentifier:parentIUID];
    
    //postion을 먼저 정한 후에 add 함
    
    NSPoint position = [self distanceFromIU:parentIUID toPointFromWebView:point];
    if ([newIU canChangeXByUserInput]) {
        [newIU setX:position.x];
    }
    if([newIU canChangeYByUserInput]){
        [newIU setY:position.y];
    }
    
    [parentIU addIU:newIU error:nil];
    
    if ([parentIUID containsString:kIUImportEditorPrefix]) {
        NSString *parentIdentifier = [[parentIUID componentsSeparatedByString:@"_" ] objectAtIndex:1];
        NSString *finalString = [NSString stringWithFormat:@"%@%@_%@", kIUImportEditorPrefix, parentIdentifier, newIU.htmlID];
        [self.controller trySetSelectedObjectsByIdentifiers:@[finalString]];
    }
    else {
        [self.controller setSelectedObjectsByIdentifiers:@[newIU.htmlID]];
    }
    
    [newIU confirmIdentifier];
    
    JDTraceLog( @"[IU:%@] : point(%.1f, %.1f) atIU:%@", newIU.htmlID, point.x, point.y, parentIUID);
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

-(void)insertImage:(NSString *)name atIU:(NSString *)identifier{
    IUBox *currentIU = [self.controller tryIUBoxByIdentifier:identifier];
    [currentIU setImageName:name];
}

#pragma mark -
#pragma mark call by Document

- (void)didFinishLoadFrame{
    
    [self disableUpdateJS:self];
    
    [_sheet updateCSS];
    for(IUBox *box in _sheet.allChildren){
        [box updateCSS];
    }
    
    [self enableUpdateJS:self];
    [self updateJS];
    
    NSString *htmlSource =  [(DOMHTMLElement *)[[[[self webView] mainFrame] DOMDocument] documentElement] outerHTML];
    JDTraceLog(@"%@", htmlSource);

    
}

- (void)updateSheetHeight{
    //not page class
    //page will be set report from javscript
    if([_sheet isKindOfClass:[IUClass class]]){
        [(LMCanvasView*)self.view extendMainViewToFullSize];
    }
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
        
    [self updateSheetHeight];
}

- (void)reloadSheet{
    if(_sheet){
        [self setSheet:_sheet];
    }
}

- (void)ghostImageContextDidChange:(NSDictionary *)change{
    
    NSString *ghostImageName = _sheet.ghostImageName;
    IUResourceFile *resourceNode = [_resourceManager resourceFileWithName:ghostImageName];
    NSImage *ghostImage = [[NSImage alloc] initWithContentsOfFile:resourceNode.absolutePath];
    [[self gridView] setGhostImage:ghostImage];
    
    NSPoint ghostPosition = NSMakePoint(_sheet.ghostX, _sheet.ghostY);
    [[self gridView] setGhostPosition:ghostPosition];
    
    [[self gridView] setGhostOpacity:_sheet.ghostOpacity];
}


#pragma mark -
#pragma mark manage IUs
-(NSUInteger)countOfSelectedIUs{
    return [self.controller.selectedObjects count];
}

- (BOOL)containsIU:(NSString *)IUID{
    if ([self.controller.selectedIdentifiersWithImportIdentifier containsObject:IUID]){
        return YES;
    }
    else {
        return NO;
    }
}


- (void)saveCurrentTextEditorForWidth:(NSInteger)width{
    DOMNodeList *list = [self.DOMDoc.documentElement getElementsByClassName:@"addible"];
    for (int i=0; i<list.length; i++) {
        //find editor
        DOMHTMLElement *node = (DOMHTMLElement*)[list item:i];
        NSString *currentClass = [node getAttribute:@"class"];
        [node setAttribute:@"class" value:[currentClass stringByReplacingOccurrencesOfString:@"addible" withString:@""]];
        
        //save current text
        IUBox *iu = [self.controller tryIUBoxByIdentifier:node.idName];
        if(iu){
            iu.text = node.innerText;
        }
        
        
    }
    
    list = [self.DOMDoc.documentElement getElementsByClassName:@"editable"];
    for (int i=0; i<list.length; i++) {
        //find editor
        DOMHTMLElement *node = (DOMHTMLElement*)[list item:i];
        NSString *currentClass = [node getAttribute:@"class"];
        [node setAttribute:@"class" value:[currentClass stringByReplacingOccurrencesOfString:@"addible" withString:@""]];
        
        //save current text
        IUBox *iu = [self.controller tryIUBoxByIdentifier:node.idName];
        if(iu){
            [iu.mqData setValue:node.innerHTML forTag:IUMQDataTagInnerHTML forViewport:width];
        }
        [iu updateCSS];
        
    }
}

- (void)disableTextEditor{
    
    if(_selectedFrameWidth == _maxFrameWidth){
        [self saveCurrentTextEditorForWidth:IUCSSDefaultViewPort];
    }
    else{
        [self saveCurrentTextEditorForWidth:_selectedFrameWidth];
    }
    
    //remove current editor
    DOMNodeList *list = [self.DOMDoc.documentElement getElementsByClassName:@"addible"];
    for (int i=0; i<list.length; i++) {
        //find editor
        DOMHTMLElement *node = (DOMHTMLElement*)[list item:i];
        NSString *currentClass = [node getAttribute:@"class"];
        [node setAttribute:@"class" value:[currentClass stringByReplacingOccurrencesOfString:@"addible" withString:@""]];
        NSString *identifier = node.idName;
        
        //remove current editor
        NSString *removeMCE = [NSString stringWithFormat:@"tinyMCE.execCommand('mceRemoveEditor', true, '%@');", identifier];
        [self evaluateWebScript:removeMCE];

    }
    
    list = [self.DOMDoc.documentElement getElementsByClassName:@"editable"];
    for (int i=0; i<list.length; i++) {
        //find editor
        DOMHTMLElement *node = (DOMHTMLElement*)[list item:i];
        NSString *currentClass = [node getAttribute:@"class"];
        [node setAttribute:@"class" value:[currentClass stringByReplacingOccurrencesOfString:@"editable" withString:@""]];
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
        className = @"addible";
        fnName = @"iuAddEditorAddible";
        NSString *alertString = [NSString stringWithFormat:@"Text Typing Mode : %@", iu.name];
        [JDUIUtil hudAlert:alertString second:2];
    }
    else if(inputType == IUTextInputTypeEditable){
        className = @"editable";
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

-(void)selectedObjectsDidChange:(NSDictionary*)change{
    [JDLogUtil log:IULogAction key:@"CanvasVC:observed" string:[self.controller.selectedIdentifiers description]];
    
    [[self gridView] removeAllSelectionLayers];
    [[self gridView] removeAllTextPointLayer];
    
    for(NSString *IUID in self.controller.selectedIdentifiersWithImportIdentifier){
        if([frameDict.dict objectForKey:IUID]){
            NSRect frame = [[frameDict.dict objectForKey:IUID] rectValue];
            [[self gridView] addSelectionLayerWithIdentifier:IUID withFrame:frame];
            [[self gridView] addTextPointLayer:IUID withFrame:frame];
        }
    }
    
}
- (void)deselectedAllIUs{
    [self.controller setSelectionIndexPath:nil];
}
- (void)addSelectedIU:(NSString *)IU{
    if(IU == nil){
        return;
    }
    if([self.controller.selectedIdentifiers containsObject:IU]){
        return;
    }
    NSArray *array = [self.controller.selectedIdentifiersWithImportIdentifier arrayByAddingObject:IU];
    [self.controller trySetSelectedObjectsByIdentifiers:array];
}

- (void)removeSelectedIU:(NSString *)IU{
    if(IU == nil){
        return;
    }
    if([self.controller.selectedIdentifiers containsObject:IU] == NO){
        return;
    }
    
    NSMutableArray *selectArray = [self.controller.selectedIdentifiers mutableCopy];
    [selectArray removeObject:IU];
    [self.controller trySetSelectedObjectsByIdentifiers:selectArray];
}

- (void)setSelectedIU:(NSString *)identifier{
    if(identifier == nil){
        return;
    }
    
    NSString *selectedID = identifier;
    
    IUBox *iu = [self.controller tryIUBoxByIdentifier:identifier];
    if([iu isKindOfClass:[IUItem class]]){
        if( [((IUItem *)iu) shouldSelectParentFirst]){
            IUBox *parentIU = iu.parent;
            if([self.controller.selectedIdentifiers containsString:parentIU.htmlID] == NO &&
               [self.controller.selectedIdentifiers containsString:identifier] == NO){
                selectedID = parentIU.htmlID;
            }
        }
    }
    
    NSArray *addArray = [NSArray arrayWithObject:selectedID];
    
    /*
     Even it is selected object, still select it again.
     (IUClass is not shown selected until it is selected again)
     */
    [self.controller trySetSelectedObjectsByIdentifiers:addArray];

}

- (void)selectIUInRect:(NSRect)frame{
    NSArray *keys = [frameDict.dict allKeys];
    
    [self deselectedAllIUs];
    
    for(NSString *key in keys){
        NSRect iuframe = [[frameDict.dict objectForKey:key] rectValue];
        if( NSIntersectsRect(iuframe, frame) ){
            [self addSelectedIU:key];
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

#pragma mark - frame

- (NSPoint)distanceFromIU:(NSString *)parentName to:(NSString *)iuName{
    NSRect iuFrame = [[frameDict.dict objectForKey:iuName] rectValue];
    NSRect parentFrame = [[frameDict.dict objectForKey:parentName] rectValue];
    
    NSPoint distance = NSMakePoint(iuFrame.origin.x-parentFrame.origin.x,
                                   iuFrame.origin.y - parentFrame.origin.y);
    return distance;
}

- (NSSize)frameSize:(NSString *)identifier{
    NSRect iuFrame = [[frameDict.dict objectForKey:identifier] rectValue];
    return iuFrame.size;
}

- (NSPoint)distanceFromIU:(NSString*)parentName toPointFromWebView:(NSPoint)point{
    
    NSRect parentFrame = [[frameDict.dict objectForKey:parentName] rectValue];
    
    NSPoint distance = NSMakePoint(point.x-parentFrame.origin.x,
                                   point.y - parentFrame.origin.y);
    return distance;
}

#pragma mark - class
/**
 현재 text 수정중인 IU에만 class를 추가할수있도록 사용할예정.
 */
-(void)IUClassIdentifier:(NSString *)classIdentifier addClass:(NSString *)className{
    DOMNodeList *list = [self.DOMDoc.documentElement getElementsByClassName:classIdentifier];
    for (int i=0; i<list.length; i++) {
        DOMHTMLElement *node = (DOMHTMLElement*)[list item:i];
        NSString *currentClass = [node getAttribute:@"class"];
        if([currentClass containsString:className] == NO){
            [node setAttribute:@"class" value:[currentClass stringByAppendingFormat:@" %@", className]];
        }
    }
}

-(void)IUClassIdentifier:(NSString *)classIdentifier removeClass:(NSString *)className{
    DOMNodeList *list = [self.DOMDoc.documentElement getElementsByClassName:classIdentifier];
    for (int i=0; i<list.length; i++) {
        DOMHTMLElement *node = (DOMHTMLElement*)[list item:i];
        NSString *currentClass = [node getAttribute:@"class"];
        [node setAttribute:@"class" value:[currentClass stringByReplacingOccurrencesOfString:className withString:@""]];
    }
}

#pragma mark -
#pragma mark HTML

- (DOMHTMLElement *)getHTMLElementbyID:(NSString *)HTMLID{
    DOMHTMLElement *selectNode = (DOMHTMLElement *)[self.DOMDoc getElementById:HTMLID];
    return selectNode;
    
}
- (NSString *)tagWithHTML:(NSString *)html{
    NSString *subHTML = [html substringFromIndex:[html rangeOfString:@"<"].location];
    NSArray *separatedHTML = [subHTML componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([separatedHTML count]) {
        NSString *incompleteTag = separatedHTML[0];
        NSArray *tags = [incompleteTag componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        if ([tags count] > 1) {
            NSString *tag = tags[1];
            if (tag.length != 0) {
                return tag;
            }
        }
    }
    [JDUIUtil hudAlert:@"You Found error. Please contact to us" second:2];
 //   NSAssert(0, @"Error!!!");
    return nil;
}

-(void)IUHTMLIdentifier:(NSString*)identifier HTML:(NSString *)html withParentID:(NSString *)parentID{
    
    //element를 바꾸기 전에 현재 text editor를 disable시켜야지 text editor가 제대로 동작함.
    //editor remove가 제대로 돌아가야 함.
    [self disableTextEditor];
    
    DOMHTMLElement *currentElement = [self getHTMLElementbyID:identifier];
    if(currentElement){
        //change html text
        [currentElement setOuterHTML:html];
    }
    else{
        //insert html
        DOMHTMLElement *selectHTMLElement = [self getHTMLElementbyID:parentID];
        if (selectHTMLElement == nil) {
            return;
        }
        DOMHTMLElement *newElement = (DOMHTMLElement *)[self.DOMDoc createElement:[self tagWithHTML:html]];
        [selectHTMLElement appendChild:newElement];
        
        [newElement setOuterHTML:html];

    }
    
}


#pragma mark -
#pragma mark CSS

- (BOOL)isSheetHeightChanged:(NSString *)identifier{
    if([identifier isEqualToString:[_sheet cssIdentifier]]
       && [_sheet isKindOfClass:[IUClass class]]){
        return YES;
    }    
    return NO;
}


/**
 @brief get element line count by only selected iu
 */
-(NSInteger)countOfLineWithIdentifier:(NSString *)identifier{
    DOMNodeList *list = [self.DOMDoc getElementsByClassName:identifier];
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

-(void)updateCSS:(NSString *)css selector:(NSString *)selector{
    DOMNodeList *list = [self.DOMDoc querySelectorAll:selector];
    int length= list.length;
    for(int i=0; i<length; i++){
        DOMHTMLElement *element = (DOMHTMLElement *)[list item:i];
        DOMCSSStyleDeclaration *style = element.style;
        style.cssText = css;
    }
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
            [self updateSheetHeight];
        }
    }
   
}

- (void)updateJS{
    if( [self isUpdateJSEnabled]==YES){
        [[self webView] runJSAfterRefreshCSS];
    }
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


#pragma mark - style sheet update
/**
 @brief style sheet에서만 동작하는 것들
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
    DOMHTMLStyleElement *sheetElement = (DOMHTMLStyleElement *)[[self DOMDoc] getElementById:@"default"];
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
    
    //    NSArray *cssRuleList = [trimmedInnerCSSHTML componentsSeparatedByCharactersInSet:
    //                          [NSCharacterSet characterSetWithCharactersInString:@"."]];
    
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
    DOMHTMLStyleElement *sheetElement = (DOMHTMLStyleElement *)[[self DOMDoc] getElementById:@"default"];
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



#pragma mark -
#pragma mark GridView
- (GridView *)gridView{
    return ((LMCanvasView *)self.view).gridView;
}


/*
 ******************************************************************************************
 SET IU : View call IU
 ******************************************************************************************
 */
#pragma mark -
#pragma mark setIU

#pragma mark frameDict


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


#pragma mark moveIU
//drag & drop after select IU
- (void)moveIUToDiffPoint:(NSPoint)point totalDiffPoint:(NSPoint)totalPoint{
    if (point.x == 0 && point.y == 0) {
        return;
    }
    
    
    for(IUBox *obj in self.controller.selectedObjects){
        
        IUBox *moveObj= obj;
        
        if([self isParentMove:obj]){
            moveObj = obj.parent;
        }
        
        NSSize parentSize;
        if (self.controller.importIUInSelectionChain){
            NSString *currentID =  [self.controller.importIUInSelectionChain modifieldHtmlIDOfChild:moveObj];
            parentSize = [[self webView] parentBlockElementSize:currentID];
        }
        else {
            parentSize = [[self webView] parentBlockElementSize:moveObj.htmlID];
        }

        /*
        if([frameDict isGuidePoint:totalPoint]){
            
            NSString *IUID = obj.htmlID;
            NSRect currentFrame = [[frameDict.dict objectForKey:IUID] rectValue];
            NSRect moveFrame = currentFrame;
            
            moveFrame.origin = NSMakePoint(currentFrame.origin.x+point.x, currentFrame.origin.y+point.y);
            NSPoint guidePoint = [frameDict guidePointOfCurrentFrame:moveFrame IU:IUID];
            guidePoint= NSMakePoint(guidePoint.x - currentFrame.origin.x, guidePoint.y - currentFrame.origin.y);
            
            
            [obj movePosition:NSMakePoint(guidePoint.x, guidePoint.y) withParentSize:parentSize];
            JDInfoLog(@"Point:(%.1f %.1f)", moveFrame.origin.x, moveFrame.origin.y);
            [obj updateCSS];
        }
        else{
         */
        [moveObj movePosition:NSMakePoint(totalPoint.x, totalPoint.y) withParentSize:parentSize];
        [moveObj updateCSS];
        
    }
}

- (BOOL)checkExtendSelectedIU:(NSSize)size{
    //drag pointlayer
    for(IUBox *obj in self.controller.selectedObjects){
        
        NSString *IUID = obj.htmlID;
        NSRect currentFrame = [[frameDict.dict objectForKey:IUID] rectValue];
        NSSize expectedSize = NSMakeSize(currentFrame.size.width+size.width, currentFrame.size.height+size.height);
        if(expectedSize.width < 0 || expectedSize.height < 0){
            return NO;
        }
    }
    return YES;
}

- (BOOL)isParentMove:(IUBox *)obj{
    if([obj respondsToSelector:@selector(shouldMoveParent)]){
        return [[obj performSelector:@selector(shouldMoveParent)] boolValue];
    }

    return  NO;
}

- (void)startFrameMoveWithUndoManager:(id)sender{
    if([sender isKindOfClass:[GridView class]]){
        [((LMCanvasView *)[self view]) startDraggingFromGridView];
    }
    for(IUBox *obj in self.controller.selectedObjects){
        if([self isParentMove:obj] || [self isParentExtend:obj]){
            [obj.parent startFrameMoveWithUndoManager];
        }
        [obj startFrameMoveWithUndoManager];
        
    }
}

- (void)endFrameMoveWithUndoManager:(id)sender{
    for(IUBox *obj in self.controller.selectedObjects){
        if([self isParentMove:obj] || [self isParentExtend:obj]){
            [obj.parent endFrameMoveWithUndoManager];
        }
        
        [obj endFrameMoveWithUndoManager];
        
    }
}

- (BOOL)isParentExtend:(IUBox *)iu{
    if([iu respondsToSelector:@selector(shouldExtendParent)]){
        return [[iu performSelector:@selector(shouldExtendParent)] boolValue];
    }
    return NO;
}

- (void)extendIUToTotalDiffSize:(NSSize)totalSize{
    //drag pointlayer
    for(IUBox *obj in self.controller.selectedObjects){
        IUBox *moveObj= obj;
        
        if([self isParentExtend:obj]){
            moveObj = obj.parent;
        }
        
        NSSize parentSize;
        if (self.controller.importIUInSelectionChain){
            NSString *currentID =  [self.controller.importIUInSelectionChain modifieldHtmlIDOfChild:moveObj];
            parentSize = [[self webView] parentBlockElementSize:currentID];
        }
        else {
            parentSize = [[self webView] parentBlockElementSize:moveObj.htmlID];
        }
        
        /*
        if([frameDict isGuideSize:totalSize]){

            NSString *IUID = obj.htmlID;
            NSRect currentFrame = [[frameDict.dict objectForKey:IUID] rectValue];
            //NSSize expectedSize = NSMakeSize(currentFrame.size.width+size.width, currentFrame.size.height+size.height);
            NSRect moveFrame = currentFrame;
            
            moveFrame.size = NSMakeSize(currentFrame.size.width+size.width, currentFrame.size.height+size.height);
            NSSize guideSize = [frameDict guideSizeOfCurrentFrame:moveFrame IU:IUID];
            guideSize = NSMakeSize(guideSize.width- currentFrame.size.width, guideSize.height - currentFrame.size.height);
            
            [obj increaseSize:NSMakeSize(guideSize.width, guideSize.height) withParentSize:parentSize];
            [obj updateCSS];
        }
        else{
         */
        [moveObj increaseSize:NSMakeSize(totalSize.width, totalSize.height) withParentSize:parentSize];
        [moveObj updateCSS];
        
        
        /*
        JDTraceLog( @"[IU:%@]\n origin: (%.1f, %.1f) \n size: (%.1f, %.1f)",
                   IUID, guideFrame.origin.x, guideFrame.origin.y, guideFrame.size.width, guideFrame.size.height);
         */
        
    }
    
}


-(void)IURemoved:(NSString*)identifier withParentID:(NSString *)parentID{
    
    [self deselectedAllIUs];
    IUBox *iu = [_controller IUBoxByIdentifier:identifier];
    
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
            [[self gridView] removeLayerWithIUIdentifier:identifier];
            [frameDict.dict removeObjectForKey:identifier];
            
            for(IUBox *box in iu.allChildren){
                NSString *currentID =  [(IUImport *)iu modifieldHtmlIDOfChild:box];
                [[self gridView] removeLayerWithIUIdentifier:currentID];
                [frameDict.dict removeObjectForKey:currentID];
            }
        }
        else if([iu.sheet isKindOfClass:[IUClass class]]){
            for (IUBox *import in [(IUClass*)iu.sheet references]) {
                
                NSMutableArray *allIU = [iu.allChildren mutableCopy];
                [allIU addObject:iu];
                
                for(IUBox *box in allIU){
                    NSString *currentID =  [(IUImport *)import modifieldHtmlIDOfChild:box];
                    [[self gridView] removeLayerWithIUIdentifier:currentID];
                    [frameDict.dict removeObjectForKey:currentID];
                }
                
            }
            
        }
        else{
            
            NSMutableArray *allIU = [iu.allChildren mutableCopy];
            [allIU addObject:iu];
            
            
            for(IUBox *box in allIU){
                
                [[self gridView] removeLayerWithIUIdentifier:box.htmlID];
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
    else{
        [[self gridView] removeLayerWithIUIdentifier:identifier];
        [frameDict.dict removeObjectForKey:identifier];

    }
    
    
}



#pragma mark HTMLSource

-(NSString *)currentHTML{
    NSString *htmlSource =  [(DOMHTMLElement *)[[[[self webView] mainFrame] DOMDocument] documentElement] outerHTML];
    return htmlSource;
}

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

- (void)copy:(id)sender{
    [self.controller copySelectedIUToPasteboard:self];
}

- (void)paste:(id)sender{
    [self.controller pasteToSelectedIU:self];
}

- (void)performRightClick:(NSString*)IUID withEvent:(NSEvent*)event{
    
    /*
     TO Be removed:20140930
    //make help menu
    NSMenu *menu = [[NSMenu alloc] init];
    NSMenuItem *helpItem = [[NSMenuItem alloc] init];
    helpItem.title = @"Help";
    NSMenu *helpMenu = [[NSMenu alloc] initWithTitle:@"Help"];
    [menu addItem:helpItem];
    [menu setSubmenu:helpMenu forItem:helpItem];
    
    

    //get className
    IUBox *selectedIU = [self.controller IUBoxByIdentifier:IUID];
    NSString *className = [selectedIU className];
    
    //pdf list
    NSString *pdfFilePath = [[NSBundle mainBundle] pathForResource:@"helpPdf" ofType:@"plist"];
    NSDictionary *pdfDict = [NSDictionary dictionaryWithContentsOfFile:pdfFilePath];
    
    //widget manual list
    NSString *widgetFilePath = [[NSBundle mainBundle] pathForResource:@"widgetForDefault" ofType:@"plist"];
    NSArray *availableWidgetProperties = [NSArray arrayWithContentsOfFile:widgetFilePath];
    NSDictionary *widget = [availableWidgetProperties objectWithKey:@"className" value:className];
    NSArray *helpArray = [widget objectForKey:@"manual"];
    for (NSString *pdfKey in helpArray) {
        NSMenuItem *item = [[NSMenuItem alloc] init];
        item.representedObject = pdfKey;
        item.title = [pdfDict objectForKey:pdfKey][@"title"];
        [helpMenu addItem:item];
        item.target = self;
        [item setAction:@selector(performHelp:)];
    }
    
    //get
    [NSMenu popUpContextMenu:menu withEvent:event forView:self.view];
     */
}

@end
