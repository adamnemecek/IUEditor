//
//  IUSourceController.m
//  IUEditor
//
//  Created by Joodong Yang on 2014. 11. 4..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUSourceManager.h"
#import "IUCompiler.h"
#import "IUBox.h"
#import "IUSheet.h"
#import "IUPage.h"
#import "IUEventVariable.h"
#import "IUProject.h"
#import "IUController.h"
#import "IUCSSCode.h"


@interface IUSourceManager () <NSFileManagerDelegate> // delegate copy item

@end

@implementation IUSourceManager {
    __weak id<IUSourceManagerDelegate> _canvasVC;
    __weak WebCanvasView *_webCanvasView;
    __weak IUProject *_project;
    
    IUCompiler *_compiler;
    NSString *_documentBasePath;
 
    NSDictionary *CSSCodeCache; // key = box, value = CSSCode last generated
    NSInteger _viewport; /* managing view port, view port is set at loadSheet */

}

#pragma mark - initialize

- (id)init{
    self = [super init];
    _viewport = IUDefaultViewPort;
    [self setCompiler:[[IUCompiler alloc] init]];
    return self;
}

- (void)dealloc{
    JDSectionInfoLog(IULogDealloc, @"");
}

- (void)setCanvasVC:(id <IUSourceManagerDelegate>)canvasVC{
    _canvasVC = canvasVC;
    _webCanvasView = canvasVC.webCanvasView;
    NSAssert ( _webCanvasView, @"WebView IS NIL");
}

#pragma mark - JS
- (id)callWebScriptMethod:(NSString *)function withArguments:(NSArray *)args{
    return [_canvasVC callWebScriptMethod:function withArguments:args];
}

- (id)evaluateWebScript:(NSString *)script{
    return [_canvasVC evaluateWebScript:script];
}

/**
 @brief get element line count by only selected iu
 */
-(NSInteger)countOfLineWithIdentifier:(NSString *)identifier{
    DOMNodeList *list = [self.DOMDocument getElementsByClassName:identifier];
    if(list.length > 0){
        DOMHTMLElement *element = (DOMHTMLElement *)[list item:0];
        DOMNodeList *pList  = [element getElementsByTagName:@"p"];
        return pList.length;

    }
    return 0;
}
/*FIXME: get pixel frame*/
- (NSRect)absolutePixelFrameWithIdentifier:(NSString *)identifier{
    return NSZeroRect;
}


#pragma mark - default properties

- (void)setDocumentBasePath:(NSString*)documentBasePath {
    _documentBasePath = [documentBasePath copy];
}

- (void)setProject:(IUProject *)project{
    _project = project;
    _documentBasePath = project.path;
    self.compilerRule = [project defaultCompilerRule];
}

- (void)setEditorResourceBasePath:(NSString *)path{
    [_compiler setEditorResourceBasePath:path];
}

- (void)loadSheet:(IUSheet *)sheet{
    [self loadSheet:sheet viewport:_viewport];
}

- (void)loadSheet:(IUSheet *)sheet viewport:(NSInteger)viewport{
    
    _viewport = viewport;
    NSAssert(_compiler, @"compiler is nil");
    
    NSString *code = [_compiler editorSource:sheet viewPort:_viewport];
    NSAssert(code, @"code is nil");
    if (_documentBasePath) {
        [[_webCanvasView mainFrame] loadHTMLString:code baseURL:[NSURL fileURLWithPath:_documentBasePath]];
    }
#if DEBUG
    else {
        [[_webCanvasView mainFrame] loadHTMLString:code baseURL:nil];
    }
#endif
    
    [self postProcessAfterUpdate:sheet];
        
}

- (DOMDocument *)DOMDocument{
    return [[_webCanvasView mainFrame] DOMDocument];
}

- (void)setCompiler:(IUCompiler *)compiler{
    _compiler = compiler;
}

- (NSArray *)availableCompilerRule{
    return [_project compilerRules];
}

#pragma mark - manage obj

- (void)removeIU:(id)obj{
    [_canvasVC IURemoved:obj];
}

- (void)setNeedsUpdateHTML:(IUBox *)box{
    /*
     현재까지 transaction을 지원하지 않는다.
     */
    /* update IUBox 가 불리면, IUController에서 동일한 Path들을 모두 가져온다. 이 Path들 정보로 html ID를 가져온다 */
    if (_iuController) {
        NSArray *htmlIDs = [_iuController allHTMLIDsWithIU:box];
        for (NSString *htmlID in htmlIDs) {
            DOMHTMLElement *element = (DOMHTMLElement *)[[self DOMDocument] getElementById:htmlID];
            NSAssert(element, @"element should not nil");
            NSString *htmlCode;
            [_compiler editorIUSource:box htmlIDPrefix:htmlID viewPort:_viewport htmlSource:&htmlCode nonInlineCSSSource:nil];
            [element setOuterHTML:htmlCode];
        }
    }
    else {
        DOMHTMLElement *element = (DOMHTMLElement *)[[self DOMDocument] getElementById:box.htmlID];
        NSAssert(element, @"element should not nil");
        NSString *htmlCode;
        [_compiler editorIUSource:box htmlIDPrefix:nil viewPort:_viewport htmlSource:&htmlCode nonInlineCSSSource:nil];
        [element setOuterHTML:htmlCode];
    }
    
    [self postProcessAfterUpdate:box];
}



- (void)setNeedsUpdateCSS:(IUBox *)box{
    /* get css code from compiler */
    /*
     현재까지 transaction을 지원하지 않는다.
     */
    IUCSSCode *code = [_compiler editorIUCSSSource:box viewPort:_viewport];
    NSDictionary *inlineCSSDict = [code inlineTagDictionyForViewport:_viewport];
    /* insert css code to inline */
    [inlineCSSDict enumerateKeysAndObjectsUsingBlock:^(NSString* selector, NSString *cssString, BOOL *stop) {
        DOMNodeList *list = [[self DOMDocument]  querySelectorAll:selector];
        int length= list.length;
        for(int i=0; i<length; i++){
            DOMHTMLElement *element = (DOMHTMLElement *)[list item:i];
            DOMCSSStyleDeclaration *style = element.style;
            style.cssText = cssString;
        }
    }];
    

    NSDictionary *nonInlineCSSDict = [code nonInlineTagDictionaryForViewport:_viewport];

    [nonInlineCSSDict enumerateKeysAndObjectsUsingBlock:^(NSString* selector, NSString *cssString, BOOL *stop) {
        [self updateNonInlineCSSText:cssString withSelector:selector];
    }];
    
    [self postProcessAfterUpdate:box];
}

- (void)postProcessAfterUpdate:(IUBox *)box{
    
    //run js if box has center attribute
    if(box.enableHCenter || box.enableVCenter){
        [_webCanvasView reframeCenter];
    }
    
    //resize sidebar, page content
    if([box.parent isKindOfClass:[IUPageContent class]]){
        [_webCanvasView resizePageContent];
        [_webCanvasView resizeSidebar];
    }
    
    //update grid frame dictionary
    NSMutableArray *updatedIUs = [NSMutableArray array];
    
    if([box.currentPositionStorage.firstPosition isEqualToNumber:@(IUFirstPositionTypeRelative)]){
        //update siblings
        [updatedIUs addObject:box.parent.htmlID];
        [updatedIUs addObjectsFromArray:[box.parent.allChildren valueForKey:@"htmlID"]];
    }
    else{
        [updatedIUs addObject:box.htmlID];
        [updatedIUs addObjectsFromArray:[box.allChildren valueForKey:@"htmlID"]];
    }
    
    [_webCanvasView updateFrameDictionaryWithIdentifiers:updatedIUs];
}



- (void)setNeedsUpdateCSS:(IUBox *)box withIdentifiers:(NSArray *)identifiers{
    //TODO: 겸치는 set만 동작하게
}



-(void)updateNonInlineCSSText:(NSString *)css withSelector:(NSString *)selector{
    [JDLogUtil log:IULogSource key:@"css source" string:css];
    
    if(css.length == 0){
        //nothing to do
        [self removeCSSTextInDefaultSheetWithIdentifier:selector];
    }else{
        NSString *cssText = [NSString stringWithFormat:@"%@{%@}", selector, css];
        //default setting
        [self addCSSText:cssText withSelector:selector];
    }
}

- (void)addCSSText:(NSString *)cssText withSelector:(NSString *)selector{
    
    DOMHTMLStyleElement *sheetElement = (DOMHTMLStyleElement *)[[self DOMDocument] getElementById:@"default"];
    NSString *newCSSText = [self innerCSSText:sheetElement.innerHTML byAddingCSSText:cssText withSelector:selector];
    [sheetElement setInnerHTML:newCSSText];
    
}

- (NSString *)innerCSSText:(NSString *)innerCSSText byAddingCSSText:(NSString *)cssText withSelector:(NSString *)selector
{
    NSMutableString *innerCSSHTML = [NSMutableString stringWithString:@"\n"];
    NSString *trimmedInnerCSSHTML = [innerCSSText  stringByTrim];
    NSArray *cssRuleList = [trimmedInnerCSSHTML componentsSeparatedByString:@"\n"];
    
    for(NSString *rule in cssRuleList){
        if(rule.length == 0){
            continue;
        }
        NSString *ruleID = [self cssIDInCSSRule:rule];
        NSString *modifyidentifier = [selector stringByTrim];
        if([ruleID isEqualToString:modifyidentifier] == NO){
            [innerCSSHTML appendString:[NSString stringWithFormat:@"\t%@\n", [rule stringByTrim]]];
        }
    }
    
    [innerCSSHTML appendString:cssText];
    [innerCSSHTML appendString:@"\n"];
    
    return innerCSSHTML;
}

- (NSString *)removeCSSText:(NSString *)innerCSSText withSelector:(NSString *)selector
{
    NSMutableString *innerCSSHTML = [NSMutableString stringWithString:@"\n"];
    NSString *trimmedInnerCSSHTML = [innerCSSText  stringByTrim];
    NSArray *cssRuleList = [trimmedInnerCSSHTML componentsSeparatedByString:@"\n"];
    
    for(NSString *rule in cssRuleList){
        if(rule.length == 0){
            continue;
        }
        NSString *ruleID = [self cssIDInCSSRule:rule];
        NSString *modifiedIdentifier = [selector stringByTrim];
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


- (void)removeCSSTextInDefaultSheetWithIdentifier:(NSString *)identifier{

    DOMHTMLStyleElement *sheetElement = (DOMHTMLStyleElement *)[[self DOMDocument] getElementById:@"default"];
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

- (void)beginTransaction:(id)sender{
    
}

- (void)commitTransaction:(id)sender{
    
}



- (NSString *)source{
    DOMHTMLElement *element = (DOMHTMLElement*)[[self DOMDocument] documentElement];
    NSString *htmlSource = [element outerHTML];
    return htmlSource;
}



- (BOOL)build:(NSError **)error rule:(NSString *)rule{
    return [_compiler build:_project rule:rule error:nil];
}


#if 0
            if ([sheet isKindOfClass:[IUPage class]]) {
                NSInteger indexOfSheet = [self.pageSheets indexOfObject:sheet];
                NSString *prevSheetName = [sheet.name stringByAppendingString:@".html"];
                NSString *nextSheetName = [sheet.name stringByAppendingString:@".html"];
                if (indexOfSheet > 0) {
                    prevSheetName = [[[self.pageSheets objectAtIndex:indexOfSheet-1] name] stringByAppendingString:@".html"];
                }
                if (indexOfSheet < [self.pageSheets count] -1 ) {
                    nextSheetName = [[[self.pageSheets objectAtIndex:indexOfSheet+1] name] stringByAppendingString:@".html"];
                }
                
                NSString *scriptPath = [[NSBundle mainBundle] pathForResource:@"iupresentationScript" ofType:@"txt"];
                NSString *presentStr = [[[NSString stringWithContentsOfFile:scriptPath encoding:NSUTF8StringEncoding error:nil]  stringByReplacingOccurrencesOfString:@"IUPRESENTATION_NEXT_PAGE" withString:nextSheetName] stringByReplacingOccurrencesOfString:@"IUPRESENTATION_PREV_PAGE" withString:prevSheetName];
                outputHTML = [outputHTML stringByAppendingString:presentStr];
            }
#endif




@end
