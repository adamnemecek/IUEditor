//
//  CanvasWebView.m
//  IUCanvas
//
//  Created by ChoiSeungmi on 2014. 3. 21..
//  Copyright (c) 2014년 ChoiSeungmi. All rights reserved.
//

#import "WebCanvasView.h"
#import "LMCanvasVC.h"
#import "JDLogUtil.h"
#import "LMCanvasView.h"
#import "IUBox.h"
#import "LMWC.h"
#import "LMCanvasVC.h"
#import "JDLogUtil.h"

@implementation WebCanvasView{
    
    //load web source indicator
    NSTimer *progressTimer;
    BOOL isStartVC;
    int startVCIndicator;
    
    //tracking resource
    int resourceCount;
    int resourceFailedCount;
    int resourceCompletedCount;
}

- (id)init{
    
    self = [super init];
    if(self){
        
        /**
         http://stackoverflow.com/questions/8511147/drawing-a-subview-on-top-of-a-google-map-displayed-in-a-webview-on-osx
         
         For performance reasons, Cocoa does not enforce clipping among sibling views or guarantee correct invalidation and drawing behavior when sibling views overlap. If you want a view to be drawn in front of another view, you should make the front view a subview (or descendant) of the rear view.
         */
        [self setWantsLayer:YES];
        
        //connect delegate
        [self setUIDelegate:self];
        [self setResourceLoadDelegate:self];
        [self setFrameLoadDelegate:self];
        [self setPolicyDelegate:self];
        [self setEditingDelegate:self];

        
        [[[self mainFrame] frameView] setAllowsScrolling:NO];
        
        [self registerForDraggedTypes:@[(id)kUTTypeIUImageResource]];
        
        isStartVC = NO;
        startVCIndicator = 0;
        
    }
    
    return self;
    
}

- (BOOL)isFlipped{
    return YES;
}

#pragma mark - status
#if DEBUG
- (void)updateResourceStatus{
    
    JDTraceLog(@"=========web resource status=============================");
    if(resourceFailedCount > 0){
        JDFatalLog(@"resourceFailedCount : %d", resourceFailedCount);
    }
    else{
        JDTraceLog(@"resourceFailedCount : %d", resourceFailedCount);
    }
    JDTraceLog(@"resourceCompletedCount : %d", resourceCompletedCount);
    JDTraceLog(@"resourceCount : %d", resourceCount );
    JDTraceLog(@"=========================================================");
}

- (id)webView:(WebView *)sender identifierForInitialRequest:(NSURLRequest *)request fromDataSource:(WebDataSource *)dataSource{
    
    resourceCount++;
    //Update the status message
    [self updateResourceStatus];

    return dataSource;
}


- (void)webView:(WebView *)sender resource:(id)identifier didFailLoadingWithError:(NSError *)error fromDataSource:(WebDataSource *)dataSource
{
    resourceFailedCount++;
    //Update the status message
    [self updateResourceStatus];
    
    JDErrorLog(@"failed load resource : %@", identifier);
}

-(void)webView:(WebView *)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource *)dataSource
{
    resourceCompletedCount++;
    //Update the status message
    [self updateResourceStatus];

}
#endif

#pragma mark - load

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame{
    
    //status
    resourceFailedCount=0;
    resourceCompletedCount=0;
    resourceCount =0;
    
    //indicator
    isStartVC = NO;
    startVCIndicator = 0;
    progressTimer = [NSTimer timerWithTimeInterval:0.01667 target:self selector:@selector(setProgressIndicator) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:progressTimer forMode:NSDefaultRunLoopMode];
    
}

- (void)setProgressIndicator{
    CGFloat progress = ([self estimatedProgress]) *100;
    if(isStartVC ==NO && progress > 80){
        progress *= 0.9;
    }
    if(isStartVC){
        startVCIndicator++;
    }
    progress += startVCIndicator;
    if(progress > 98){
        progress = 98;
    }
    
    /**
     FIXME:
    LMWC *wc = (LMWC *)[[self window] windowController];
    [wc setProgressBarValue:progress];
     */
    
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame{
    if (frame != [sender mainFrame]){
        return;
    }
    //FIXME: 동시에 두개 켜지면서 하나가 로딩이 덜된것이 신호가 같이 가는 것 같음. 
    isStartVC = YES;
    [self.controller webViewdidFinishLoadFrame];
    /**
     FIXME:
    LMWC *wc = (LMWC *)[[self window] windowController];
    [wc stopProgressBar:self];
     */
    [progressTimer invalidate];
}


#pragma mark -
#pragma mark mouse operation

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender{
    return NSDragOperationEvery;
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender{
    return NSDragOperationEvery;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender{
    
    NSPasteboard *pBoard = sender.draggingPasteboard;
    NSPoint dragPoint = sender.draggingLocation;
    NSPoint convertedPoint = [self convertPoint:dragPoint fromView:nil];
    
    
    //type2) resourceImage
    NSString *imageName = [pBoard stringForType:(id)kUTTypeIUImageResource];
    if(imageName){
        NSString *identifier = [self IdentifierAtPoint:convertedPoint];
        if(identifier){
            IUBox *iu = [self.controller tryIUBoxByIdentifier:identifier];
            if(iu){
//                [iu setImageName:imageName];
                [self.window makeFirstResponder:self];
                return YES;
            }
        }
    }
    
    return NO;
}

- (NSUInteger)webView:(WebView *)webView dragSourceActionMaskForPoint:(NSPoint)point{
    //prevent drag image (already inserted)
    return WebDragDestinationActionNone;
}

- (void)mouseDown:(NSEvent *)theEvent{
    
}



#pragma mark -
#pragma mark Javascript with WebView
- (void)webView:(WebView *)webView didClearWindowObject:(WebScriptObject *)windowObject forFrame:(WebFrame *)frame{
    [windowObject setValue:self forKey:@"console"];
}


+ (NSString *)webScriptNameForSelector:(SEL)selector{
    if (selector == @selector(doOutputToLog:)){
        return @"log";
    }
    else if(selector == @selector(reportFrameDict:)){
        return @"reportFrameDict";
    }
    else if(selector == @selector(resizePageContentHeightFinished:)){
        return @"resizePageContentHeightFinished";
    }
    else if(selector == @selector(jsTimeStartWithName:)){
        return @"timeStart";
    }
    else if(selector == @selector(jsTimeEndWithName:)){
        return @"timeEnd";
    }
    else if(selector ==@selector(reportTextChangedWithIdentifier:)){
        return @"textChanged";
    }
    else{
        return nil;
    }
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector {
    if (selector == @selector(reportFrameDict:)
        || selector == @selector(doOutputToLog:)
        || selector == @selector(resizePageContentHeightFinished:)
        || selector == @selector(jsTimeStartWithName:)
        || selector == @selector(jsTimeEndWithName:)
        || selector == @selector(reportTextChangedWithIdentifier:)
        ){
        return NO;
    }
    return YES;
}

- (void)resizePageContentHeightFinished:(NSNumber *)scriptObj{
    [JDLogUtil timeLogStart:@"resizePageContent"];
    JDInfoLog(@"document size change to : %f" , [scriptObj floatValue]);
    [self.controller changeIUPageHeight:[scriptObj floatValue]];
    [JDLogUtil timeLogEnd:@"resizePageContent"];

}

/* Here is our Objective-C implementation for the JavaScript console.log() method.
 */
- (void)doOutputToLog:(NSString*)theMessage {
    JDTraceLog(@"LOG: %@", theMessage);
}

- (void)jsTimeStartWithName:(NSString *)name{
    [JDLogUtil timeLogStart:name];
}

- (void)jsTimeEndWithName:(NSString *)name{
    [JDLogUtil timeLogEnd:name];
}


#pragma mark -
#pragma mark scriptObject



- (NSArray*) convertWebScriptObjectToNSArray:(WebScriptObject*)webScriptObject
{
    // Assumption: webScriptObject has already been tested using isArray:
    
    NSUInteger count = [[webScriptObject valueForKey:@"length"] integerValue];
    NSMutableArray *a = [NSMutableArray array];
    for (unsigned i = 0; i < count; i++) {
        id item = [webScriptObject webScriptValueAtIndex:i];
        if ([item isKindOfClass:[WebScriptObject class]]) {
            [a addObject:[self convertWebScriptObjectToNSDictionary:item]];
        } else {
            [a addObject:item];
        }
    }
    
    return a;
}

- (NSMutableDictionary*) convertWebScriptObjectToNSDictionary:(WebScriptObject*)webScriptObject
{
    WebScriptObject* keysObject = [[self windowScriptObject] callWebScriptMethod:@"getDictionaryKeys" withArguments:[NSArray arrayWithObject:webScriptObject]];
    NSArray* keys = [self convertWebScriptObjectToNSArray:keysObject];
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:[keys count]];
    
    NSEnumerator* enumerator = [keys objectEnumerator];
    id key;
    while (key = [enumerator nextObject]) {
        id value = [webScriptObject valueForKey:key];
        
        if([value isKindOfClass:[WebScriptObject class]]){
            [dict setObject:[self convertWebScriptObjectToNSDictionary:value] forKey:key];
        }
        else{
            [dict setObject:value forKey:key];
        }
    }
    
    return dict;
}

- (void)reportTextChangedWithIdentifier:(NSString *)identifier{
    JDTraceLog(@"textChanged : %@", identifier);
    [self.controller saveCurrentTextEditor];
}


#pragma mark -
#pragma mark IUFrame


- (void)reportFrameDict:(WebScriptObject *)scriptObj{
    
    [JDLogUtil timeLogStart:@"reportFrameDict"];
    
    NSMutableDictionary *scriptDict = [self convertWebScriptObjectToNSDictionary:scriptObj];
    NSMutableDictionary *iuFrameDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *gridFrameDict = [NSMutableDictionary dictionary];
    
    NSArray *keys = [scriptDict allKeys];
    for(NSString *key in keys){
        NSDictionary *innerDict = [scriptDict objectForKey:key];
        
        CGFloat left = [[innerDict objectForKey:@"left"] floatValue];
        CGFloat top = [[innerDict objectForKey:@"top"] floatValue];
        CGFloat x = [[innerDict objectForKey:@"x"] floatValue];
        CGFloat y = [[innerDict objectForKey:@"y"] floatValue];
        CGFloat w = [[innerDict objectForKey:@"width"] floatValue];
        CGFloat h = [[innerDict objectForKey:@"height"] floatValue];
        
        NSRect iuFrame = NSMakeRect(left, top, w, h);
        [iuFrameDict setObject:[NSValue valueWithRect:iuFrame] forKey:key];
        NSRect gridFrame = NSMakeRect(x, y, w, h);
        [gridFrameDict setObject:[NSValue valueWithRect:gridFrame] forKey:key];
    }
    
    
    [self.controller updateGridFrameDictionary:gridFrameDict];
    
    [JDLogUtil timeLogEnd:@"reportFrameDict"];
    JDTraceLog( @"reportSharedFrameDict");
}


- (NSRect)gridFrameWithIdentfier:(NSString *)identifier{
    NSString *frameJS = [NSString stringWithFormat:@"$('#%@').iuPosition()", identifier];
    id frameObject = [self evaluateWebScript:frameJS];
    NSRect pixelFrame = NSMakeRect([[frameObject valueForKey:@"left"] floatValue],
                                       [[frameObject valueForKey:@"top"] floatValue],
                                       [[frameObject valueForKey:@"width"] floatValue],
                                       [[frameObject valueForKey:@"height"] floatValue]
                                       );
    return pixelFrame;
    

    //NSRect frame = NSMakeRect(element.offsetLeft, element.offsetTop, element.offsetWidth, element.offsetHeight);
}

- (NSPoint)offsetWithElement:(DOMElement *)element{
    NSPoint offset = NSMakePoint(element.offsetLeft, element.offsetTop);
    if(element.parentElement){
        NSPoint parentOffset  = [self offsetWithElement:element.parentElement];
        offset.x += parentOffset.x;
        offset.y += parentOffset.y;
    }
    return offset;
}

- (NSRect)domGridFrameWithIdentifier:(NSString *)identifier{
    DOMElement *element =  [[[self mainFrame] DOMDocument] getElementById:identifier];
    if(element){
        NSPoint offset = [self offsetWithElement:element];
        return NSMakeRect(offset.x, offset.y, element.offsetWidth, element.offsetHeight);
    }
    return NSZeroRect;
}

- (void)updateFrameDictionaryWithIdentifiers:(NSArray *)identifiers{
    

    /*
    [JDLogUtil timeLogStart:@"jsFrame"];
    NSMutableDictionary *gridFrameDict = [NSMutableDictionary dictionary];
    
    for(NSString *identifier in identifiers){
        NSRect gridFrame = [self gridFrameWithIdentfier:identifier];
        [gridFrameDict setObject:[NSValue valueWithRect:gridFrame] forKey:identifier];
        
    }
    [JDLogUtil timeLogEnd:@"jsFrame"];
     //REVIEW : jsframe is slower than dom frame
     JDLogUtil.m:+[JDLogUtil timeLogEnd:] 250 - Time taken for jsFrame 0.000318364 s[;
     JDLogUtil.m:+[JDLogUtil timeLogEnd:] 250 - Time taken for domFrame 4.8748e-05 s[;
     */
    [JDLogUtil timeLogStart:@"domFrame"];
    
    NSMutableDictionary *gridFrameDict = [NSMutableDictionary dictionary];
    
    for(NSString *identifier in identifiers){
        NSRect gridFrame = [self domGridFrameWithIdentifier:identifier];
        [gridFrameDict setObject:[NSValue valueWithRect:gridFrame] forKey:identifier];
        
    }
    [JDLogUtil timeLogEnd:@"domFrame"];

    
    [self.controller updateGridFrameDictionary:gridFrameDict];
}

- (void)updateFrameDict __deprecated{
    //reportFrameDict(after call setIUCSSStyle)
    [self stringByEvaluatingJavaScriptFromString:@"getIUUpdatedFrameThread()"];
}


- (void)runJSAfterRefreshCSS __deprecated{
    JDTraceLog(@"runJSAfterRefreshCSS");
    [self stringByEvaluatingJavaScriptFromString:@"reframeCenter()"];
    [self evaluateWebScript:@"resizeSideBar()"];

    [self updateFrameDict];
    [self resizePageContent];
}

#pragma mark callJS

- (id)callWebScriptMethod:(NSString *)function withArguments:(NSArray *)args{
    return [[self windowScriptObject] callWebScriptMethod:function withArguments:args];
}

- (id)evaluateWebScript:(NSString *)script{
    return [[self windowScriptObject] evaluateWebScript:script];
}

- (void)reframeCenter{
    [self stringByEvaluatingJavaScriptFromString:@"reframeCenter()"];
}
- (void)resizeSidebar{
    [self evaluateWebScript:@"resizeSideBar()"];
}

- (void)resizePageContent{
    CGFloat height = [self.controller heightOfCanvas];
    NSString *js = [NSString stringWithFormat:@"resizePageContentHeightEditor(%f)", height];
    [self stringByEvaluatingJavaScriptFromString:js];
}


#pragma mark -
#pragma mark manage IU


- (DOMElement *)DOMElementAtPoint:(NSPoint)point{
    NSDictionary *dict  =[self elementAtPoint:point];
    DOMElement *element = [dict objectForKey:WebElementDOMNodeKey];
    return element;
}

- (DOMHTMLElement *)domHTMLElementWithId:(DOMElement *)element{
    if([element isKindOfClass:[DOMHTMLElement class]]
       && ((DOMHTMLElement *)element).idName
       && ((DOMHTMLElement *)element).idName.length > 0){
        return (DOMHTMLElement *)element;
    }
    else if(element == nil){
        return nil;
    }
    else{
        return [self domHTMLElementWithId:element.parentElement];
    }
}

- (BOOL)isTextEditorAtPoint:(NSPoint)point{
    DOMElement *domNode =[self DOMElementAtPoint:point];
    DOMHTMLElement *htmlElement = [self domHTMLElementWithId:domNode];
    if(htmlElement == nil){
        return NO;
    }
    else if([htmlElement.idName rangeOfString:@"mceu"].location == 0){
        return YES;
    }
    else{
        return NO;
    }
    
    return NO;
}

- (NSString *)IdentifierAtPoint:(NSPoint)point{
    
    DOMElement *domNode =[self DOMElementAtPoint:point];
    if(domNode){
        DOMHTMLElement *htmlElement =[self IUNodeAtCurrentNode:domNode];
        if(htmlElement){
            return htmlElement.idName;
        }
        else{
            return nil;
        }
    }
    
    return nil;
}

- (DOMHTMLElement *)IUNodeAtCurrentNode:(DOMNode *)node{
    NSString *iuClass = ((DOMElement *)node).className;
    if([iuClass containsString:@"IUBox"] && [iuClass containsString:@"collectioncopy"]==NO){
        return (DOMHTMLElement *)node;
    }
    else if ([node isKindOfClass:[DOMHTMLIFrameElement class]]){
        JDTraceLog(@"");
        return nil;
    }
    else if (node.parentNode == nil ){
        //can't find div node
        //- it can't be in IU model
        //- IU model : text always have to be in Div class
        //reach to html
        JDTraceLog(@"can't find IU node, reach to HTMLElement");
        return nil;
    }
    else {
        return [self IUNodeAtCurrentNode:node.parentNode];
    }
}

#pragma mark -
#pragma mark web policy


- (BOOL)webView:(WebView *)webView shouldChangeSelectedDOMRange:(DOMRange *)currentRange
     toDOMRange:(DOMRange *)proposedRange
       affinity:(NSSelectionAffinity)selectionAffinity
 stillSelecting:(BOOL)flag
{
    if([self.controller isEnableTextEditor]){
        return YES;
    }
    else{
        // disable text selection
        return NO;
    }
}



- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element
    defaultMenuItems:(NSArray *)defaultMenuItems
{
    // disable right-click context menu
    return nil;
}


/*

- (BOOL)webView:(WebView *)webView shouldPerformAction:(SEL)action fromSender:(id)sender{
    JDWarnLog(@"");

    return [ super webView:webView shouldPerformAction:action fromSender:sender];
}

- (BOOL)webView:(WebView *)webView validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)item defaultValidation:(BOOL)defaultValidation{
    JDWarnLog(@"");

    return [super webView:webView validateUserInterfaceItem:item defaultValidation:defaultValidation];
}
- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request{
    JDWarnLog(@"");
    return [super webView:sender createWebViewWithRequest:request];
}

- (void)webView:(WebView *)webView decidePolicyForMIMEType:(NSString *)type
        request:(NSURLRequest *)request
          frame:(WebFrame *)frame
decisionListener:(id<WebPolicyDecisionListener>)listener{
    
}

*/

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id < WebPolicyDecisionListener >)listener
{
    /*
     web에서 링크를 클릭했을 때 들어오는 actionInformation Dict
     WebActionButtonKey = 0;
     WebActionElementKey =     {
     WebElementDOMNode = "<DOMHTMLParagraphElement [P]: 0x10917c5a0 ''>";
     WebElementFrame = "<WebFrame: 0x60800001b520>";
     WebElementIsContentEditableKey = 0;
     WebElementIsInScrollBar = 0;
     WebElementIsSelected = 0;
     WebElementLinkIsLive = 1;
     WebElementLinkLabel = Recruit;
     WebElementLinkURL = "file:///Users/choiseungmi/IUProjTemp/myApp.iuproject/Index.html";
     WebElementTargetFrame = "<WebFrame: 0x60800001b520>";
     };
     WebActionModifierFlagsKey = 0;
     WebActionNavigationTypeKey = 0;
     WebActionOriginalURLKey = "file:///Users/choiseungmi/IUProjTemp/myApp.iuproject/Index.html"
     ;
     
     */
    NSDictionary *actionDict = [actionInformation objectForKey:WebActionElementKey];
    if(actionDict){
        [listener ignore];
    }
    else{
        [listener use];
    }
}

- (void)webView:(WebView *)webView decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id < WebPolicyDecisionListener >)listener
{
    NSDictionary *actionDict = [actionInformation objectForKey:WebActionElementKey];
    if(actionDict){
        [listener ignore];
    }
    else{
        [listener use];
    }
}



@end
