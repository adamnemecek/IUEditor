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

@implementation IUSourceManager {
    __weak  id <IUSourceManagerDelegate> _canvasVC;
    __weak  IUCompiler *_compiler;
    __weak WebView *_webView;
    NSString *_documentBasePath;

    NSDictionary *CSSCodeCache; // key = box, value = CSSCode last generated
}

- (id)init{
    self = [super init];
    _viewPort = IUDefaultViewPort;
    return self;
}

- (void)setCanvasVC:(id <IUSourceManagerDelegate>)canvasVC{
    _canvasVC = canvasVC;
    _webView = canvasVC.webView;
    NSAssert ( _webView, @"WebView IS NIL");
}

- (id)callWebScriptMethod:(NSString *)function withArguments:(NSArray *)args{
    return [_canvasVC callWebScriptMethod:function withArguments:args];
}

- (void)setDocumentBasePath:(NSString*)documentBasePath {
    _documentBasePath = [documentBasePath copy];
}


- (void)loadSheet:(IUSheet*)sheet {
    NSAssert(_compiler, @"compiler is nil");
    NSString *code = [_compiler webSource:sheet target:IUTargetEditor];
    NSAssert(code, @"code is nil");
    if (_documentBasePath) {
        [[_webView mainFrame] loadHTMLString:code baseURL:[NSURL fileURLWithPath:_documentBasePath]];
    }
    else {
        [[_webView mainFrame] loadHTMLString:code baseURL:[NSURL fileURLWithPath:NSHomeDirectory()]];
    }
}

- (DOMDocument *)DOMDocument{
    return [[_webView mainFrame] DOMDocument];
}

- (void)setNeedsUpdateHTML:(IUBox *)box{
    DOMHTMLElement *element = (DOMHTMLElement *)[[self DOMDocument] getElementById:box.htmlID];
    NSAssert(element, @"element should not nil");
    NSString *code = [_compiler htmlSource:box target:IUTargetEditor viewPort:_viewPort];
    [element setOuterHTML:code];
}

- (void)setNeedsUpdateCSS:(IUBox*)box{
    [JDLogUtil log:IULogSource key:@"updateCSS" string:box.htmlID];
    
    /* get css code from compiler */
    IUCSSCode *code = [_compiler cssSource:box target:IUTargetEditor viewPort:_viewPort];
    
    /* insert css code to inline */
    NSDictionary *inlineCSSDict = [code inlineTagDictiony];
    [inlineCSSDict enumerateKeysAndObjectsUsingBlock:^(NSString* selector, NSString *cssString, BOOL *stop) {
        DOMNodeList *list = [[self DOMDocument]  querySelectorAll:selector];
        int length= list.length;
        for(int i=0; i<length; i++){
            DOMHTMLElement *element = (DOMHTMLElement *)[list item:i];
            DOMCSSStyleDeclaration *style = element.style;
            style.cssText = cssString;
        }
    }];

    /* insert non-inline css : hover or css */
    NSDictionary *nonInlineCSSDict = [code nonInlineTagDictionary];

    [nonInlineCSSDict enumerateKeysAndObjectsUsingBlock:^(NSString* selector, NSString *cssString, BOOL *stop) {
        DOMHTMLStyleElement *sheetElement = (DOMHTMLStyleElement *)[[self DOMDocument]  getElementById:@"default"];
        NSString *newCSSText = [self removeCSSText:sheetElement.innerHTML withSelector:selector];
        [sheetElement setInnerHTML:newCSSText];
    }];
    
    /* remove unnecessary IUCSSCode */
    
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
    /*
    DOMHTMLStyleElement *sheetElement = (DOMHTMLStyleElement *)[[self webDocument] getElementById:@"default"];
    NSString *newCSSText = [self removeCSSText:sheetElement.innerHTML withID:identifier];
    [sheetElement setInnerHTML:newCSSText];
     */
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

- (void)setCompiler:(IUCompiler *)compiler{
    _compiler = compiler;
}

- (NSString *)source{
    DOMHTMLElement *element = (DOMHTMLElement*)[[self DOMDocument] documentElement];
    NSString *htmlSource = [element outerHTML];
    return htmlSource;
}

@end
