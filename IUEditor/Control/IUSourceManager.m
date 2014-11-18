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

/**
 Basic Compiler rules
 */
static NSString *kIUCompileRuleHTML = @"HTML";
static NSString *kIUCompileRuleDjango = @"Django";
static NSString *kIUCompileRulePresentation = @"Presentation";
static NSString *kIUCompileRuleWordpress = @"wordpress";


@interface IUSourceManager () <NSFileManagerDelegate> // delegate copy item

@end

@implementation IUSourceManager {
    __weak  id <IUSourceManagerDelegate> _canvasVC;
    __weak  IUCompiler *_compiler;
    __weak WebView *_webView;
    __weak IUProject *_project;
    
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

- (id)evaluateWebScript:(NSString *)script{
    return [_canvasVC evaluateWebScript:script];
}

- (void)setDocumentBasePath:(NSString*)documentBasePath {
    _documentBasePath = [documentBasePath copy];
}

- (void)setProject:(IUProject *)project{
    _project = project;
    _documentBasePath = project.path;
}


- (void)loadSheet:(IUSheet*)sheet {
    NSAssert(_compiler, @"compiler is nil");
    NSString *code = [_compiler editorWebSource:sheet];
    NSAssert(code, @"code is nil");
    if (_documentBasePath) {
        [[_webView mainFrame] loadHTMLString:code baseURL:[NSURL fileURLWithPath:_documentBasePath]];
    }
#if DEBUG
    else {
        [[_webView mainFrame] loadHTMLString:code baseURL:nil];
    }
#endif
}

- (DOMDocument *)DOMDocument{
    return [[_webView mainFrame] DOMDocument];
}

- (void)setNeedsUpdateHTML:(IUBox *)box{
    DOMHTMLElement *element = (DOMHTMLElement *)[[self DOMDocument] getElementById:box.htmlID];
    NSAssert(element, @"element should not nil");
    NSString *code = [_compiler editorHTMLString:box viewPort:self.viewPort];
    [element setOuterHTML:code];
}

- (void)setNeedsUpdateCSS:(IUBox*)box{
    [JDLogUtil log:IULogSource key:@"updateCSS" string:box.htmlID];
    
    /* get css code from compiler */
    IUCSSCode *code = [_compiler editorCSSCode:box viewPort:self.viewPort];
    
    /* insert css code to inline */
    NSDictionary *inlineCSSDict = [code inlineTagDictionyForViewport:_viewPort];
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
    NSDictionary *nonInlineCSSDict = [code nonInlineTagDictionaryForViewport:_viewPort];

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


/**** build ***/
/*
 Get code from compiler
 Save it to approprite path.
 */

- (BOOL)build:(NSError **)error {
    /*
     Note :
     Do not delete build path. Instead, overwrite files.
     If needed, remove all files (except hidden file started with '.'), due to issus of git, heroku and editer such as Coda.
     NSFileManager's (BOOL)createFileAtPath:(NSString *)path contents:(NSData *)contents attributes:(NSDictionary *)attributes automatically overwrites file.
     */
    
    /* make directory */
    NSAssert(_project.buildPath != nil, @"");
    NSAssert(_compiler != nil, @"");

    NSString *buildDirectoryPath = [_project absoluteBuildPath];
    NSString *buildResourcePath = [_project absoluteBuildResourcePath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:buildDirectoryPath] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:buildDirectoryPath withIntermediateDirectories:YES attributes:nil error:error];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:buildResourcePath] == YES) {
        [[NSFileManager defaultManager] removeItemAtPath:buildResourcePath error:nil];
    }
    
    
    /* copy resource */
    [[NSFileManager defaultManager] setDelegate:self];
    [[NSFileManager defaultManager] copyItemAtPath:_project.resourceGroup.absolutePath toPath:buildResourcePath error:error];
    [self copyCSSJSResourceToBuildPath:buildResourcePath];
    
    
    /* build clip art */
    /*
     Build Sheet 을 하면서 클립아트어레이를 만들 수도 있지만, 
     코드를 분할하는데는 For-Loop를 두번 도는 것이 보기 좋음.
     */
    NSMutableArray *clipArtArray = [NSMutableArray array];
    for (IUSheet *sheet in _project.allSheets) {
        [clipArtArray addObjectsFromArray:[_compiler outputClipArtArray:sheet]];
    }
    if ([clipArtArray count]) {
        NSString *copyPath = [buildResourcePath stringByAppendingPathComponent:@"clipArt"];
        [[NSFileManager defaultManager] createDirectoryAtPath:copyPath withIntermediateDirectories:YES attributes:nil error:error];
        
        for(NSString *imageName in clipArtArray){
            if ([[NSFileManager defaultManager] fileExistsAtPath:[buildResourcePath stringByAppendingPathComponent:imageName] isDirectory:NO] == NO) {
                [[JDFileUtil util] copyBundleItem:[imageName lastPathComponent] toDirectory:copyPath];
            }
        }
    }
    
    /* build sheet */
    NSString *resourceCSSPath = [buildResourcePath stringByAppendingPathComponent:@"css"];
    NSString *resourceJSPath = [buildResourcePath stringByAppendingPathComponent:@"js"];

    for (IUSheet *sheet in _project.allSheets) {

        //*If page, make js code */
        if ([sheet isKindOfClass:[IUPage class]]) {
            IUPage *page = (IUPage *)sheet;
            /* make JS File */
            NSString *jsInitCode = [_compiler jsInitSource:page];
            if (jsInitCode) {
                NSString *jsFilePath = [resourceJSPath stringByAppendingPathComponent:[_compiler jsInitFileName:page]];
                /* save */
                if ([jsInitCode writeToFile:jsFilePath atomically:YES encoding:NSUTF8StringEncoding error:error] == NO){
                    NSAssert(0, @"write fail");
                    return NO;
                }
            }
            
            NSString *jsEventCode = [_compiler jsEventSource:page];
            if (jsEventCode) {
                NSString *jsFilePath = [resourceJSPath stringByAppendingPathComponent:[_compiler jsEventFileName:page]];
                /* save */
                if ([jsEventCode writeToFile:jsFilePath atomically:YES encoding:NSUTF8StringEncoding error:error] == NO){
                    NSAssert(0, @"write fail");
                    return NO;
                }
            }
        }
        
        /* make html and css */
        
        //if compile mode is Presentation, add button
        if (_compilerRule == kIUCompileRulePresentation) {
            NSAssert(0, @"Not Coded ");
            return NO;
        }
        
        //html
        NSString *htmlSource = [_compiler outputHTMLSource:(IUPage *)sheet];
        NSString *htmlPath = [self absoluteBuildPathForSheet:sheet];
        
        NSAssert(htmlSource, @"html Source is nil");
        NSAssert(htmlPath, @"htmlPath is nil");
        
        //note : writeToFile: automatically overwrite
        NSError *error;
        if ([htmlSource writeToFile:htmlPath atomically:YES encoding:NSUTF8StringEncoding error:&error] == NO){
            NSAssert(0, @"write fail");
            return NO;
        }
        
        //css
        NSString *outputCSS = [_compiler outputCSSSource_storage:(IUPage *)sheet];
        
        NSString *cssPath = [[resourceCSSPath stringByAppendingPathComponent:sheet.name] stringByAppendingPathExtension:@"css"];
        
        //note : writeToFile: automatically overwrite
        if ([outputCSS writeToFile:cssPath atomically:YES encoding:NSUTF8StringEncoding error:&error] == NO){
            NSAssert(0, @"write fail");
            return NO;
        }
        
    }//end of all sheet forloop
    return YES;
}

- (NSString*)absoluteBuildPathForSheet:(IUSheet *)sheet{
    NSString *filePath = [[_project.absoluteBuildPath stringByAppendingPathComponent:sheet.name ] stringByAppendingPathExtension:@"html"];
    return filePath;
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


- (BOOL)copyCSSJSResourceToBuildPath:(NSString *)buildPath{
    NSError *error;
    
    //css
    NSString *resourceCSSPath = [buildPath stringByAppendingPathComponent:@"css"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:resourceCSSPath] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:resourceCSSPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    [[NSFileManager defaultManager] createDirectoryAtPath:resourceCSSPath withIntermediateDirectories:YES attributes:nil error:&error];
    for(NSString *filename in [_project defaultOutputCSSArray]){
        [[JDFileUtil util] overwriteBundleItem:filename toDirectory:resourceCSSPath];
    }
    
    
    //js
    NSString *resourceJSPath = [buildPath stringByAppendingPathComponent:@"js"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:resourceJSPath] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:resourceJSPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    for(NSString *filename in [_project defaultCopyJSArray]){
        [[JDFileUtil util] overwriteBundleItem:filename toDirectory:resourceJSPath];
    }
    
#if DEBUG
    [[JDFileUtil util] overwriteBundleItem:@"stressTest.js" toDirectory:resourceJSPath];
    
#endif
    
    //copy js for IE
    NSString *ieJSPath = [resourceJSPath stringByAppendingPathComponent:@"ie"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:ieJSPath] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:ieJSPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    for(NSString *filename in [_project defaultOutputIEJSArray]){
        [[JDFileUtil util] overwriteBundleItem:filename toDirectory:ieJSPath];
    }
    
    
    if(error){
        return NO;
    }
    return YES;
}

@end
