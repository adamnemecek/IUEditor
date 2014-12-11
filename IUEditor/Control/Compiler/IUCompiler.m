//
//  IUCompiler.m
//  IUEditor
//
//  Created by JD on 3/17/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUDocumentProtocol.h"
#import "IUProtocols.h"

#import "IUCompiler.h"
#import "IUCSSCompiler.h"
#import "IUCSSCompiler.h"
#import "IUCSSWPCompiler.h"
#import "IUJSCompiler.h"
#import "IUHTMLCompiler.h"

#import "IUResource.h"

#import "NSString+JDExtension.h"
#import "NSDictionary+JDExtension.h"
#import "LMFontController.h"

#import "IUProject.h"
#import "IUWordpressProject.h"

#import "IUBoxes.h"
#import "JDUIUtil.h"


@implementation IUCompiler{
    IUCSSCompiler *cssCompiler;
    IUHTMLCompiler *htmlCompiler;
    IUJSCompiler *jsCompiler;
    NSString *_resourceURLPath;
    NSString *_jsURLPath;
    NSString *_cssURLPath;

}

-(id)init{
    self = [super init];
    if (self) {
        htmlCompiler = [[IUHTMLCompiler alloc] init];
        _rule = @"HTML";
        
        cssCompiler = [[IUCSSCompiler alloc] init];
        
        jsCompiler = [[IUJSCompiler alloc] init];
        
    }
    return self;
}


#pragma mark - Header Part

/**
 
 metadata information
 http://moz.com/blog/meta-data-templates-123
 
 <!-- Update your html tag to include the itemscope and itemtype attributes. -->
 <html itemscope itemtype="http://schema.org/Product">
 
 <!-- Place this data between the <head> tags of your website -->
 <title>Page Title. Maximum length 60-70 characters</title>
 <meta name="description" content="Page description. No longer than 155 characters." />
 
 <!-- Schema.org markup for Google+ -->
 <meta itemprop="name" content="The Name or Title Here">
 <meta itemprop="description" content="This is the page description">
 <meta itemprop="image" content=" http://www.example.com/image.jpg">
 
 <!-- Twitter Card data -->
 <meta name="twitter:card" content="product">
 <meta name="twitter:site" content="@publisher_handle">
 <meta name="twitter:title" content="Page Title">
 <meta name="twitter:description" content="Page description less than 200 characters">
 <meta name="twitter:creator" content="@author_handle">
 <meta name="twitter:image" content=" http://www.example.com/image.html">
 <meta name="twitter:data1" content="$3">
 <meta name="twitter:label1" content="Price">
 <meta name="twitter:data2" content="Black">
 <meta name="twitter:label2" content="Color">
 
 <!-- Open Graph data -->
 <meta property="og:title" content="Title Here" />
 <meta property="og:type" content="article" />
 <meta property="og:url" content=" http://www.example.com/" />
 <meta property="og:image" content=" http://example.com/image.jpg" />
 <meta property="og:description" content="Description Here" />
 <meta property="og:site_name" content="Site Name, i.e. Moz" />
 <meta property="og:price:amount" content="15.00" />
 <meta property="og:price:currency" content="USD" />
 
 @brief metadata for page
 
 */

-(JDCode *)metadataSource:(IUPage *)page resourcePrefix:(NSString *)resourcePrefix{

    JDCode *code = [[JDCode alloc] init];
    //for google
    if(page.title && page.title.length != 0){
        [code addCodeLineWithFormat:@"<title>%@</title>", page.title];
        [code addCodeLineWithFormat:@"<meta property=\"og:title\" content=\"%@\" />", page.title];
        [code addCodeLineWithFormat:@"<meta name=\"twitter:title\" content=\"%@\">", page.title];
        [code addCodeLineWithFormat:@"<meta itemprop=\"name\" content=\"%@\">", page.title];

    }
    if(page.desc && page.desc.length != 0){
        [code addCodeLineWithFormat:@"<meta name=\"description\" content=\"%@\">", page.desc];
        [code addCodeLineWithFormat:@"<meta property=\"og:description\" content=\"%@\" />", page.desc];
        [code addCodeLineWithFormat:@"<meta name=\"twitter:description\" content=\"%@\">", page.desc];
        [code addCodeLineWithFormat:@"<meta itemprop=\"description\" content=\"%@\">", page.desc];
    }
    if(page.keywords && page.keywords.length != 0){
        [code addCodeLineWithFormat:@"<meta name=\"keywords\" content=\"%@\">", page.keywords];
    }
    if(page.project.author && page.project.author.length != 0){
        [code addCodeLineWithFormat:@"<meta name=\"author\" content=\"%@\">", page.project.author];
        [code addCodeLineWithFormat:@"<meta property=\"og:site_name\" content=\"%@\" />", page.project.author];
        [code addCodeLineWithFormat:@"<meta name=\"twitter:creator\" content=\"%@\">", page.project.author];

    }
    if(page.metaImage && page.metaImage.length !=0){
        NSString *imgSrc = [resourcePrefix stringByAppendingPathComponent:page.metaImage];
        [code addCodeLineWithFormat:@"<meta property=\"og:image\" content=\"%@\" />", imgSrc];
        [code addCodeLineWithFormat:@"<meta name=\"twitter:image\" content=\"%@\">", imgSrc];
        [code addCodeLineWithFormat:@"<meta itemprop=\"image\" content=\"%@\">", imgSrc];

    }
    if(page.project.favicon && page.project.favicon.length > 0){

        NSString *type = [page.project.favicon faviconType];
        if(type){
            NSString *imgSrc = [resourcePrefix stringByAppendingPathComponent:page.metaImage];
            [code addCodeLineWithFormat:@"<link rel=\"icon\" type=\"image/%@\" href=\"%@\">",type, imgSrc];
            
        }
    }
    //for google analytics
    if(page.googleCode && page.googleCode.length != 0){
        [code addCodeLine:page.googleCode];
    }
    
    //js for tweet
    if([page containClass:[IUTweetButton class]]){
        [code addCodeLine:@"<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=\"https://platform.twitter.com/widgets.js\";fjs.parentNode.insertBefore(js,fjs);}}(document,\"script\",\"twitter-wjs\");</script>"];
        
    }
    


    return code;
}

- (JDCode *)wordpressMetaDataSource:(IUWordpressProject *)project{
    JDCode *code = [[JDCode alloc] init];
    /*
     
     Theme Name: Twenty Thirteen
     Theme URI: http://wordpress.org/themes/twentythirteen
     Author: the WordPress team
     Author URI: http://wordpress.org/
     Description: The 2013 theme for WordPress takes us back to the blog, featuring a full range of post formats, each displayed beautifully in their own unique way. Design details abound, starting with a vibrant color scheme and matching header images, beautiful typography and icons, and a flexible layout that looks great on any device, big or small.
     Version: 1.0
     License: GNU General Public License v2 or later
     License URI: http://www.gnu.org/licenses/gpl-2.0.html
     Tags: black, brown, orange, tan, white, yellow, light, one-column, two-columns, right-sidebar, flexible-width, custom-header, custom-menu, editor-style, featured-images, microformats, post-formats, rtl-language-support, sticky-post, translation-ready
     Text Domain: twentythirteen
     
     This theme, like WordPress, is licensed under the GPL.
     Use it to make something cool, have fun, and share what you've learned with others.
    
     */
    [code addCodeLine:@"/*"];
    [code addCodeLineWithFormat:@"Theme Name: %@", project.name];
    if(project.uri){
        [code addCodeLineWithFormat:@"Theme URI: %@", project.uri];
    }
    if(project.author){
        [code addCodeLineWithFormat:@"Author: %@", project.author];
    }
    if(project.themeDescription){
        [code addCodeLineWithFormat:@"Description: %@", project.themeDescription];
    }
    if(project.tags){
        [code addCodeLineWithFormat:@"Tags: %@", project.tags];
    }
    if(project.version){
        [code addCodeLineWithFormat:@"Version: %@", project.version];
    }
    [code addCodeLine:@"*/"];

    return code;
}

-(NSArray *)fontNameFromInnerHTMLDictionary:(NSDictionary *)dictionary{
    NSMutableArray *array = [NSMutableArray array];
    for(NSString *innerHTML in [dictionary allValues]){
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"font-family:[a-z,\\s-]*;" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *findStringArray = [regex matchesInString:innerHTML options:0 range:NSMakeRange(0, innerHTML.length)];
        
        for(NSTextCheckingResult *result in findStringArray){
        
            NSString *fontfamily = [innerHTML substringWithRange:[result range]];
            //** css font name만 남김
            fontfamily = [fontfamily substringWithRange:NSMakeRange(13, fontfamily.length-14)];
            NSString *fontName = [[LMFontController sharedFontController] fontNameForFontCSS:fontfamily];
            if(fontName && fontName.length > 0){
                [array addObject:@{IUCSSTagFontName:fontName}];
            }
        }
    }
    
    return array;
}


-(JDCode *)webfontImportSourceForOutput:(IUPage *)page{
    NSMutableArray *fontArray = [NSMutableArray array];

    for (IUBox *box in page.allChildren){
        
        for(NSNumber *viewport in [box.defaultStyleManager allViewPorts]){
            NSString *fontName = ((IUStyleStorage *)[box.defaultStyleManager storageForViewPort:[viewport integerValue]]).fontName;
            if(fontName && fontName.length >0 ){
                NSString *fontWeight = ((IUStyleStorage *)[box.defaultStyleManager storageForViewPort:[viewport integerValue]]).fontWeight;
                if(fontWeight){
                    [fontArray addObject:@{IUCSSTagFontName:fontName, IUCSSTagFontWeight:fontWeight}];
                }
                else{
                    [fontArray addObject:@{IUCSSTagFontName:fontName}];
                }
            }
        }
       
        if(box.propertyManager){
            NSDictionary *mqDict = [box.propertyManager dictionaryWithWidthForKey:@"innerHTML"];
            NSArray *innerFontArray = [self fontNameFromInnerHTMLDictionary:mqDict];
            if(innerFontArray.count > 0){
                [fontArray addObjectsFromArray:innerFontArray];
            }
        }
       

    }

    LMFontController *fontController = [LMFontController sharedFontController];
    return [fontController headerCodeForFont:fontArray];
}

#pragma mark default function

- (NSString *)resourcePathForTarget:(IUTarget)target{
    if(target == IUTargetEditor){
        return @"resource";
    }
    else{
        NSAssert(0, @"not yet coded");
        return nil;
        /*
        if(_rule == IUCompileRuleDjango){
            return @"/resource";
        }
        else if(_rule == IUCompileRuleWordpress){
            return @"\"<?php bloginfo('template_url'); ?>/resource/";
        }
        else{
            return @"resource";
        }
         */
    }
}


- (IUResourceRootItem *)resourceRootItem{
    return [(id<IUDocumentProtocol>)[[[NSApp mainWindow] windowController] document] resourceRootItem];
}


#pragma mark - html header

- (JDCode *)javascriptHeader:(IUBox *)sheet isEdit:(BOOL)isEdit{
    JDCode *code = [[JDCode alloc] init];
    if(isEdit){
        
        NSString *jqueryPath = [[NSBundle mainBundle] pathForResource:@"jquery-1.10.2" ofType:@"js"];
        NSString *jqueryPathCode = [NSString stringWithFormat:@"<script src='file:%@'></script>", jqueryPath];
        [code addCodeLine:jqueryPathCode];
        
        
        NSString *jqueryUIPath = [[NSBundle mainBundle] pathForResource:@"jquery-ui-1.11.1.min" ofType:@"js"];
        NSString *jqueryUIPathCode = [NSString stringWithFormat:@"<script src='file:%@'></script>", jqueryUIPath];
        [code addCodeLine:jqueryUIPathCode];

        
        for(NSString *filename in sheet.project.defaultEditorJSArray){
            NSString *jsPath = [[NSBundle mainBundle] pathForResource:[filename stringByDeletingPathExtension] ofType:[filename pathExtension]];
            [code addCodeLineWithFormat:@"<script type=\"text/javascript\" src=\"file:%@\"></script>", jsPath];
        }
        
        //text editor - tinymce
        [code addCodeLine:@"<script type=\"text/javascript\">"];
        NSString *currentFontList = [[LMFontController sharedFontController] mceFontList];
        [code addCodeLineWithFormat:@"var iuFontList = %@;", currentFontList];
        [code addCodeLine:@"</script>"];

        NSString *mcePath = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponents:@[@"tinymce",@"tinymce"]] stringByAppendingPathExtension:@"js"];
        [code addCodeLineWithFormat:@"<script src='file:%@'></script>", mcePath];
     
    }
    else{
        
        NSString *currentResourcePath = [self resourcePathForTarget:IUTargetOutput];
        [code addCodeLine:@"<script src='http://code.jquery.com/jquery-1.10.2.js'></script>"];
        [code addCodeLine:@"<script src='http://code.jquery.com/ui/1.11.1/jquery-ui.js'></script>"];
        
        for(NSString *filename in sheet.project.defaultOutputJSArray){
            [code addCodeLineWithFormat:@"<script type=\"text/javascript\" src=\"%@/js/%@\"></script>", currentResourcePath, filename];
        }
        //each js for sheet
        /*
         no js event now
        if(sheet.hasEvent){
            [code addCodeLineWithFormat:@"<script type=\"text/javascript\" src=\"%@/js/%@-event.js\"></script>",currentResourcePath, sheet.name];
        }
         */
        [code addCodeLineWithFormat:@"<script type=\"text/javascript\" src=\"%@/js/%@-init.js\"></script>",currentResourcePath, sheet.name];

        if([sheet containClass:[IUGoogleMap class]]){
            [code addCodeLine:@"<script src=\"http://maps.googleapis.com/maps/api/js?v=3.exp&sensor=true\"></script>"];
        }
        if([sheet containClass:[IUWebMovie class]]){
            [code addCodeLine:@"<script src=\"http://f.vimeocdn.com/js/froogaloop2.min.js\"></script>"];
        }
#if DEBUG
        [code addCodeLineWithFormat:@"<script type=\"text/javascript\" src=\"%@/js/stressTest.js\"></script>", currentResourcePath];
#endif
        //support ie 8
        [code addCodeLine:@"<!--[if lt IE 9]>"];
        [code increaseIndentLevelForEdit];
        [code addCodeLineWithFormat:@"<script type=\"text/javascript\" src=\"%@/js/ie/jquery.backgroundSize.js\"></script>", currentResourcePath];
        [code addCodeLineWithFormat:@"<script type=\"text/javascript\" src=\"%@/js/ie/respond.min.js\"></script>", currentResourcePath];
        [code decreaseIndentLevelForEdit];
        [code addCodeLine:@"<![endif]-->"];
        
    }
    return code;
}

- (JDCode *)cssHeader:(IUBox *)box isEdit:(BOOL)isEdit{
    JDCode *code = [[JDCode alloc] init];
    if(isEdit){
        NSString *resetCSSPath = [[NSBundle mainBundle] pathForResource:@"reset" ofType:@"css"];
        [code addCodeLineWithFormat:@"<link rel=\"stylesheet\" type=\"text/css\" href=\"file://%@\">", resetCSSPath];
        NSString *editorCSSPath = [[NSBundle mainBundle] pathForResource:@"iueditor" ofType:@"css"];
        [code addCodeLineWithFormat:@"<link rel=\"stylesheet\" type=\"text/css\" href=\"file://%@\">", editorCSSPath];
    }
    else{
        NSString *currentResourcePath =  [self resourcePathForTarget:IUTargetOutput];
        [code addCodeLineWithFormat:@"<link rel=\"stylesheet\" type=\"text/css\" href=\"%@/css/reset.css\">", currentResourcePath];
        [code addCodeLineWithFormat:@"<link rel=\"stylesheet\" type=\"text/css\" href=\"%@/css/iu.css\">", currentResourcePath];
        [code addCodeLineWithFormat:@"<link rel=\"stylesheet\" type=\"text/css\" href=\"%@/css/%@.css\">",currentResourcePath, box.name];
    }
    return code;
}



#pragma mark - editor body source

#pragma mark - cssSource


- (IUCSSCode*)cssCodeForIU:(IUBox*)iu{
    NSAssert(cssCompiler, @"cssCompiler is nil");
    return [cssCompiler cssCodeForIU:iu];
}

- (IUCSSCode*)cssCodeForIU:(IUBox *)iu target:(IUTarget)target viewport:(int)viewport{
    //TODO: optimize this function
    //currently, csscompiler makes whole css code
    return [cssCompiler cssCodeForIU:iu];
}

- (NSString *)outputCSSSource_storage:(IUPage *)sheet{
    if (sheet.project == nil){
        NSAssert(0, @"cannot make output css source without project information");
    }
    
    NSArray *mqSizeArray = sheet.project.mqSizes;
    
    //remove default size
    NSInteger largestWidth = [[mqSizeArray objectAtIndex:0] integerValue];
    
    JDCode *code = [[JDCode alloc] init];
    NSInteger minCount = mqSizeArray.count-1;
    
    for(int count=0; count<mqSizeArray.count; count++){
        int size = [[mqSizeArray objectAtIndex:count] intValue];
        /*
        //REVIEW: word press rule은 header에 붙임, 나머지는 .css파일로 따로 뽑아냄.
        if(_rule == IUCompileRuleWordpress){
            
            if(size == sheet.project.maxViewPort){
                [code addCodeLine:@"<style id=default>"];
            }
            else if(count < mqSizeArray.count-1){
                [code addCodeWithFormat:@"<style type=\"text/css\" media ='screen and (min-width:%dpx) and (max-width:%dpx)' id='style%d'>" , size, largestWidth-1, size];
                largestWidth = size;
            }
            else{
                [code addCodeWithFormat:@"<style type=\"text/css\" media ='screen and (max-width:%dpx)' id='style%d'>" , largestWidth-1, size];
                
            }
        }
        else{
         */
            if(size != sheet.project.maxViewPort){
                //build는 css파일로 따로 뽑아줌
                if(count < mqSizeArray.count-1){
                    [code addCodeWithFormat:@"@media screen and (min-width:%dpx) and (max-width:%dpx){" , size, largestWidth-1];
                    largestWidth = size;
                }
                else{
                    [code addCodeWithFormat:@"@media screen and (max-width:%dpx){" , largestWidth-1];
                }
//            }
        }
        //smallist size
        if(count==minCount && sheet.project.enableMinWidth){
            [code increaseIndentLevelForEdit];
            NSInteger minWidth;
            if(size == sheet.project.maxViewPort){
                minWidth = largestWidth;
            }
            else{
                minWidth = size;
            }
            [code addCodeLineWithFormat:@"body{ min-width:%ldpx; }", minWidth];
            [code decreaseIndentLevelForEdit];
            
        }
        
        if(size < IUMobileSize && sheet.allChildren ){
            if([sheet containClass:[IUMenuBar class]]){
                NSString *menubarMobileCSSPath = [[NSBundle mainBundle] pathForResource:@"menubarMobile" ofType:@"css"];
                NSString *menubarMobileCSS = [NSString stringWithContentsOfFile:menubarMobileCSSPath encoding:NSUTF8StringEncoding error:nil];
                [code increaseIndentLevelForEdit];
                [code addCodeLine:menubarMobileCSS];
                [code decreaseIndentLevelForEdit];
            }
        }
        
        [code increaseIndentLevelForEdit];
        
        NSDictionary *cssDict =  [[cssCompiler cssCodeForIU:sheet] stringTagDictionaryWithIdentifierForOutputViewport:size];
        for (NSString *identifier in cssDict) {
            if ([[cssDict[identifier] stringByTrim]length]) {
                [code addCodeLineWithFormat:@"%@ {%@}", identifier, cssDict[identifier]];
            }
        }
        
        NSSet *districtChildren = [NSSet setWithArray:sheet.allChildren];
        
        for (IUBox *obj in districtChildren) {
            NSDictionary *cssDict = [[cssCompiler cssCodeForIU:obj] stringTagDictionaryWithIdentifierForOutputViewport:size];
            for (NSString *identifier in cssDict) {
                if ([[cssDict[identifier] stringByTrim]length]) {
                    [code addCodeLineWithFormat:@"%@ {%@}", identifier, cssDict[identifier]];
                }
            }
        }
        [code decreaseIndentLevelForEdit];
        /*
        if(_rule == IUCompileRuleWordpress){
            [code addCodeLine:@"</style>"];
        }
        else if(size != sheet.project.maxViewPort){
         */
            [code addCodeLine:@"}"];
        //}
        
    }
    return code.string;
}

//to be deleted
-(JDCode *)cssSource:(IUSheet *)sheet cssSizeArray:(NSArray *)cssSizeArray{
    
    //remove default size
    NSInteger largestWidth = [[cssSizeArray objectAtIndex:0] integerValue];

    JDCode *code = [[JDCode alloc] init];
    NSInteger minCount = cssSizeArray.count-1;
    
    for(int count=0; count<cssSizeArray.count; count++){
        int size = [[cssSizeArray objectAtIndex:count] intValue];
        
        //REVIEW: word press rule은 header에 붙임, 나머지는 .css파일로 따로 뽑아냄.
        if(_rule == kIUCompileRuleWordpress){
            
            if(size == sheet.project.maxViewPort){
                [code addCodeLine:@"<style id=default>"];
            }
            else if(count < cssSizeArray.count-1){
                [code addCodeWithFormat:@"<style type=\"text/css\" media ='screen and (min-width:%dpx) and (max-width:%dpx)' id='style%d'>" , size, largestWidth-1, size];
                largestWidth = size;
            }
            else{
                [code addCodeWithFormat:@"<style type=\"text/css\" media ='screen and (max-width:%dpx)' id='style%d'>" , largestWidth-1, size];
                
            }
        }
        else{
            if(size != sheet.project.maxViewPort){
                //build는 css파일로 따로 뽑아줌
                if(count < cssSizeArray.count-1){
                    [code addCodeWithFormat:@"@media screen and (min-width:%dpx) and (max-width:%dpx){" , size, largestWidth-1];
                    largestWidth = size;
                }
                else{
                    [code addCodeWithFormat:@"@media screen and (max-width:%dpx){" , largestWidth-1];
                }
            }
        }
        //smallist size
        if(count==minCount && sheet.project.enableMinWidth){
            [code increaseIndentLevelForEdit];
            NSInteger minWidth;
            if(size == sheet.project.maxViewPort){
                minWidth = largestWidth;
            }
            else{
                minWidth = size;
            }
            [code addCodeLineWithFormat:@"body{ min-width:%ldpx; }", minWidth];
            [code decreaseIndentLevelForEdit];

        }
        
        if(size < IUMobileSize && sheet.allChildren ){
            if([sheet containClass:[IUMenuBar class]]){
                NSString *menubarMobileCSSPath = [[NSBundle mainBundle] pathForResource:@"menubarMobile" ofType:@"css"];
                NSString *menubarMobileCSS = [NSString stringWithContentsOfFile:menubarMobileCSSPath encoding:NSUTF8StringEncoding error:nil];
                [code increaseIndentLevelForEdit];
                [code addCodeLine:menubarMobileCSS];
                [code decreaseIndentLevelForEdit];
            }
        }
        
        [code increaseIndentLevelForEdit];
        
        NSDictionary *cssDict =  [[cssCompiler cssCodeForIU:sheet] stringTagDictionaryWithIdentifierForOutputViewport:size];
        for (NSString *identifier in cssDict) {
            if ([[cssDict[identifier] stringByTrim]length]) {
                [code addCodeLineWithFormat:@"%@ {%@}", identifier, cssDict[identifier]];
            }
        }
        
        NSSet *districtChildren = [NSSet setWithArray:sheet.allChildren];
        
        for (IUBox *obj in districtChildren) {
            NSDictionary *cssDict = [[cssCompiler cssCodeForIU:obj] stringTagDictionaryWithIdentifierForOutputViewport:size];
            for (NSString *identifier in cssDict) {
                if ([[cssDict[identifier] stringByTrim]length]) {
                    [code addCodeLineWithFormat:@"%@ {%@}", identifier, cssDict[identifier]];
                }
            }
        }
        [code decreaseIndentLevelForEdit];
        
        if(size != sheet.project.maxViewPort){
            [code addCodeLine:@"}"];
        }
        
    }
    return code;
}


- (void)dealloc{
    [JDLogUtil log:IULogDealloc string:@"IUCompiler"];
}

- (IUCSSCode *)editorIUCSSSource:(IUBox *)iu viewPort:(NSInteger)viewPort{
    return [cssCompiler cssCodeForIU:iu rule:_rule target:IUTargetEditor viewPort:viewPort option:nil];
}

- (BOOL)editorIUSource:(IUBox *)box htmlIDPrefix:(NSString *)htmlIDPrefix viewPort:(NSInteger)viewPort htmlSource:(NSString **)html nonInlineCSSSource:(NSDictionary **)nonInlineCSS {
    NSMutableDictionary *cssDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *nonInlineCSSDict = [NSMutableDictionary dictionary];
    NSMutableArray *arr = [NSMutableArray arrayWithObject:box];
    [arr addObjectsFromArray:box.allChildren];
    
    for ( IUBox *child in arr ) {
        IUCSSCode *cssCode = [cssCompiler cssCodeForIU:child rule:_rule target:IUTargetEditor viewPort:viewPort option:nil];
        [cssDict setObject:cssCode forKey:child.htmlID];
        NSDictionary *nonInlineDictOfChild = [cssCode nonInlineTagDictionaryForViewport:viewPort];
        for (NSString* selector in nonInlineDictOfChild) {
            NSString *style = [nonInlineDictOfChild objectForKey:selector];
            nonInlineCSSDict[selector] = style;
        }
    }
    JDCode *htmlCode = [htmlCompiler editorHTMLCode:box htmlIDPrefix:htmlIDPrefix rule:_rule viewPort:viewPort cssCodes:cssDict];
    if (html) {
        *html = htmlCode.string;
    }
    if (nonInlineCSS) {
        *nonInlineCSS = nonInlineCSSDict;
    }
    return YES;
}



- (NSString *)editorSource:(IUBox *)iu viewPort:(NSInteger)viewPort canvasWidth:(NSInteger)frameWidth {
    NSString *templateFilePath = [[NSBundle mainBundle] pathForResource:@"webTemplate" ofType:@"html"];
    if (templateFilePath == nil) {
        NSAssert(0, @"Template file name wrong");
        return nil;
    }
    
    NSMutableString *sourceString = [NSMutableString stringWithContentsOfFile:templateFilePath encoding:NSUTF8StringEncoding error:nil];
    
    JDCode *sourceCode = [[JDCode alloc] initWithCodeString:sourceString];
    
    
    JDCode *webFontCode = [[LMFontController sharedFontController] headerCodeForAllFont];
    [sourceCode replaceCodeString:@"<!--WEBFONT_Insert-->" toCode:webFontCode];
    
    JDCode *jsCode = [self javascriptHeader:iu isEdit:YES];
    [sourceCode replaceCodeString:@"<!--JAVASCRIPT_Insert-->" toCode:jsCode];
    
    
    JDCode *iuCSS = [self cssHeader:iu isEdit:YES];
    [sourceCode replaceCodeString:@"<!--CSS_Insert-->" toCode:iuCSS];
    
    //add for hover css
    
    NSDictionary *cssCodes;
    NSString *sheetHTMLCode;
    [self editorIUSource:iu htmlIDPrefix:nil viewPort:viewPort htmlSource:&sheetHTMLCode nonInlineCSSSource:&cssCodes];
    
    [sourceCode replaceCodeString:@"<!--CSS_Replacement-->" toCodeString:@"<style id=\"default\"></style>"];
    JDErrorLog(@"css should be updated");
    
    //change html
    JDCode *htmlCode = [[JDCode alloc] init];
    //REVIEW : sheetouter의 width를 변경시키며 editor에서 media query가 서포트 되는것 처럼 보이게 함.
    //webview의 사이즈를 바꾸지 않고 그대로 사용할 수 있다.
    //장점
    // - 페이지를 center로 보낼수있음
    // - media query 바깥의 IU들을 overflow : visible 을 통해서 보이게 할 수 있음.
    // - text editor를 불러올 수 있음.
    [htmlCode addCodeLineWithFormat:@"<div id=\"%@\" style='width:%dpx'>", IUSheetOuterIdentifier, frameWidth];
    [htmlCode addCodeLine:sheetHTMLCode];
    [htmlCode addString:@"<div>"];
    [sourceCode replaceCodeString:@"<!--HTML_Replacement-->" toCode:htmlCode];
    
    
    
    JDSectionInfoLog( IULogSource, @"source : %@", [@"\n" stringByAppendingString:sourceCode.string]);
    
    return sourceCode.string;
}


- (BOOL)outputHTMLSource:(IUPage *)document resourcePrefix:(NSString *)resourcePrefix html:(NSString **)html css:(NSString **)css {
#if 0

    if ([sheet isKindOfClass:[IUClass class]]) {
        return [self htmlCode:sheet target:IUTargetOutput].string;
    }
    NSString *templateFilePath = [[NSBundle mainBundle] pathForResource:self.webTemplateFileName ofType:@"html"];
    
    JDCode *sourceCode = [[JDCode alloc] initWithCodeString: [NSString stringWithContentsOfFile:templateFilePath encoding:NSUTF8StringEncoding error:nil]];
    
    //replace metadata;
    if([sheet isKindOfClass:[IUPage class]]){
        JDCode *metaCode = [self metadataSource:(IUPage *)sheet];
        [sourceCode replaceCodeString:@"<!--METADATA_Insert-->" toCode:metaCode];
        
        JDCode *webFontCode = [self webfontImportSourceForOutput:(IUPage *)sheet];
        [sourceCode replaceCodeString:@"<!--WEBFONT_Insert-->" toCode:webFontCode];
        
        JDCode *jsCode = [self javascriptHeaderForSheet:sheet isEdit:NO];
        [sourceCode replaceCodeString:@"<!--JAVASCRIPT_Insert-->" toCode:jsCode];
        
        JDCode *iuCSS = [self cssHeaderForSheet:sheet isEdit:NO];
        [sourceCode replaceCodeString:@"<!--CSS_Insert-->" toCode:iuCSS];
        
        if(_rule == kIUCompileRuleWordpress){
            NSString *cssString = [self outputCSSSource:sheet mqSizeArray:sheet.project.mqSizes];
            [sourceCode replaceCodeString:@"<!--CSS_Replacement-->" toCodeString:cssString];
        }
        else{
            [sourceCode replaceCodeString:@"<!--CSS_Replacement-->" toCodeString:@""];
            
        }
        
        //change html
        JDCode *htmlCode = [self htmlCode:sheet target:IUTargetOutput];
        [sourceCode replaceCodeString:@"<!--HTML_Replacement-->" toCode:htmlCode];
        
        JDSectionInfoLog( IULogSource, @"source : %@", [@"\n" stringByAppendingString:sourceCode.string]);
        
        if (_rule == kIUCompileRuleDjango) {
            [sourceCode replaceCodeString:@"\"resource/" toCodeString:@"\"/resource/"];
            [sourceCode replaceCodeString:@"./resource/" toCodeString:@"/resource/"];
            [sourceCode replaceCodeString:@"('resource/" toCodeString:@"('/resource/"];
        }
        if (_rule == kIUCompileRuleWordpress) {
            [sourceCode replaceCodeString:@"\"resource/" toCodeString:@"\"<?php bloginfo('template_url'); ?>/resource/"];
            [sourceCode replaceCodeString:@"./resource/" toCodeString:@"<?php bloginfo('template_url'); ?>/resource/"];
            [sourceCode replaceCodeString:@"('resource/" toCodeString:@"('<?php bloginfo('template_url'); ?>/resource/"];
        }
    }
    
    return sourceCode.string;
#endif
    return NO;
}

- (void)setJSBasePath:(NSString*)urlPath{
    _jsURLPath = [urlPath copy];
}

- (void)setCSSBasePath:(NSString*)urlPath{
    _cssURLPath = [urlPath copy];
}

- (void)setResourceBasePath:(NSString *)urlPath {
    _resourceURLPath = [urlPath copy];
}

/*
- (NSString *)outputCSSSource:(IUSheet*)sheet mqSizeArray:(NSArray *)mqSizeArray{
    
    //change css
    JDCode *cssCode = [self cssSource:sheet cssSizeArray:mqSizeArray];
    
    if(_rule == IUCompileRuleDefault || _rule == IUCompileRulePresentation){
        [cssCode replaceCodeString:@"\"resource/" toCodeString:@"../"];
        [cssCode replaceCodeString:@"./resource/" toCodeString:@"../"];
        [cssCode replaceCodeString:@"('resource/" toCodeString:@"('../"];
    }
    else if (_rule == IUCompileRuleDjango) {
        [cssCode replaceCodeString:@"\"resource/" toCodeString:@"\"/resource/"];
        [cssCode replaceCodeString:@"./resource/" toCodeString:@"/resource/"];
        [cssCode replaceCodeString:@"('resource/" toCodeString:@"('/resource/"];
    }
    else if (_rule == IUCompileRuleWordpress) {
        [cssCode replaceCodeString:@"\"resource/" toCodeString:@"\"<?php bloginfo('template_url'); ?>/resource/"];
        [cssCode replaceCodeString:@"./resource/" toCodeString:@"<?php bloginfo('template_url'); ?>/resource/"];
        [cssCode replaceCodeString:@"('resource/" toCodeString:@"('<?php bloginfo('template_url'); ?>/resource/"];
    }
    
    return cssCode.string;
}
*/

- (NSString *)jsEventFileName:(IUPage *)document {
    return [jsCompiler jsEventFileName:document];
}


- (NSString *)jsInitFileName:(IUPage *)document{
    return [jsCompiler jsInitFileName:document];
}

- (NSString *)jsInitSource:(IUPage *)document storage:(BOOL)storage{
    return [jsCompiler jsInitSource:document storage:storage];
}

- (NSString *)jsEventSource:(IUPage *)document{
    return [jsCompiler jsEventSource:document];
}



@end
