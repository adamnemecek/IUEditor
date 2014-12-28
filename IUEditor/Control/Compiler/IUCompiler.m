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
#import "IUCSSWPCompiler.h"
#import "IUJSCompiler.h"
#import "IUHTMLCompiler.h"

#import "IUResource.h"

#import "NSString+JDExtension.h"
#import "NSDictionary+JDExtension.h"
#import "IUFontController.h"

#import "IUProject.h"
#import "IUWordpressProject.h"

#import "IUBoxes.h"
#import "JDUIUtil.h"


@implementation IUCompiler{
    IUCSSCompiler *cssCompiler;
    IUHTMLCompiler *htmlCompiler;
    IUJSCompiler *jsCompiler;
    NSString *_editorResourcePath;
    NSString *_outputResourcePath;

}

-(id)init{
    self = [super init];
    if (self) {
        htmlCompiler = [[IUHTMLCompiler alloc] init];
        cssCompiler = [[IUCSSCompiler alloc] init];
        jsCompiler = [[IUJSCompiler alloc] init];
        
        _rule = IUCompileRuleHTML;
    }
    return self;
}

- (NSString *)editorSource:(IUSheet *)iu viewPort:(NSInteger)viewPort{
    JDCode *sourceCode = [[JDCode alloc] initWithMainBundleFileName:@"webTemplate.html"];
    
    
    JDCode *webFontCode = [[IUFontController sharedFontController] headerCodeForAllFont];
    [sourceCode replaceCodeString:@"<!--WEBFONT_Insert-->" toCode:webFontCode];
    
    JDCode *jsCode = [self javascriptHeader:iu target:IUTargetEditor URLPrefix:nil];
    [sourceCode replaceCodeString:@"<!--JAVASCRIPT_Insert-->" toCode:jsCode];
    
    
    JDCode *iuCSS = [self cssHeader:iu target:IUTargetEditor commonCSSURLPrefix:nil IUCSSURLPrefix:nil];
    [sourceCode replaceCodeString:@"<!--CSS_Insert-->" toCode:iuCSS];
    
    //add for hover css
    
    NSDictionary *cssCodes;
    NSString *sheetHTMLCode;
    [self editorIUSource:iu htmlIDPrefix:nil viewPort:viewPort htmlSource:&sheetHTMLCode nonInlineCSSSource:&cssCodes];
    
    [sourceCode replaceCodeString:@"<!--CSS_Replacement-->" toCodeString:@"<style id=\"default\"></style>"];
    JDErrorLog(@"css should be updated");
    
    //change html
    JDCode *htmlCode = [[JDCode alloc] init];
    [htmlCode addCodeLine:sheetHTMLCode];
    [sourceCode replaceCodeString:@"<!--HTML_Replacement-->" toCode:htmlCode];
    
    
    
    JDSectionInfoLog( IULogSource, @"source : %@", [@"\n" stringByAppendingString:sourceCode.string]);
    
    return sourceCode.string;
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


- (BOOL)build:(IUProject *)project rule:(NSString *)rule error:(NSError **)error{
    /*
     Note :
     Do not delete build path. Instead, overwrite files.
     If needed, remove all files (except hidden file started with '.'), due to issus of git, heroku and editer such as Coda.
     NSFileManager's (BOOL)createFileAtPath:(NSString *)path contents:(NSData *)contents attributes:(NSDictionary *)attributes automatically overwrites file.
     */
    
    /* make directory */
    NSAssert(project.buildPath != nil, @"");
    
    
    NSString *buildResourcePath = [project absoluteBuildResourcePath];
    
    [self build_prepareBuildDirectory:project rule:rule  error:error];
    [self build_copyDefaultResourceFile:project rule:rule error:error];
    
    /****** Copy Resource *****/
#warning Resource Files are not copied currently.
    //[[NSFileManager defaultManager] copyItemAtPath:project.resourceRootPath toPath:buildResourcePath error:error];
    
    
    /* build page */
    NSString *buildCSSPath = [self outputCSSResourcePath:buildResourcePath];
    NSString *buildJSPath = [self outputJSResourcePath:buildResourcePath];
    
    NSMutableArray *builtClasses = [NSMutableArray array];
    for (IUPage *page in project.allPages) {
        JDCode *sourceCode = [[JDCode alloc] initWithMainBundleFileName:@"webTemplate.html"];
        
        /* if resource prefix == nil,
         set resource prefix as relative path */
        JDCode *metaCode = [self metadataSource:page resourcePrefix:nil];
        [sourceCode replaceCodeString:@"<!--METADATA_Insert-->" toCode:metaCode];
        
        JDCode *webFontCode = [self webfontImportSourceForOutput:page];
        [sourceCode replaceCodeString:@"<!--WEBFONT_Insert-->" toCode:webFontCode];
        
        //relative path to js file
        //NSString *relativePath = @"../../../res/js"
        
        JDCode *jsHeaderCode =[self javascriptHeader:page target:IUTargetOutput URLPrefix:nil];
        [sourceCode replaceCodeString:@"<!--JAVASCRIPT_Insert-->" toCode:jsHeaderCode];
            
        JDCode *iuCSS = [self cssHeader:page target:IUTargetOutput commonCSSURLPrefix:nil IUCSSURLPrefix:nil];
        [sourceCode replaceCodeString:@"<!--CSS_Insert-->" toCode:iuCSS];

        JDCode *pageCode = [htmlCompiler outputHTMLCode:page rule:rule];
        [sourceCode replaceCodeString:@"<!--HTML_Replacement-->" toCode:pageCode];
        
        /* save page */
        NSString *filePath = [[project absoluteBuildPath] stringByAppendingPathComponent:[page path]];
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:sourceCode.UTF8Data attributes:nil];
        
        /* save js and css */
        JDCode *jsCode = [jsCompiler JSCodeForSheet:page rule:rule];
        NSString *jsPath =[buildJSPath stringByAppendingPathComponent:page.path];
        [[NSFileManager defaultManager] createFileAtPath:jsPath contents:jsCode.UTF8Data attributes:nil];
        
        JDCode *cssCode = [cssCompiler outputCSSCodeForSheet:page rule:rule];
        NSString *cssPath =[buildCSSPath stringByAppendingPathComponent:page.path];
        [[NSFileManager defaultManager] createFileAtPath:cssPath contents:cssCode.UTF8Data attributes:nil];
        
        
        /****** Make import src **********/
        
        NSSet *classes = page.includedClass;
        for (IUClass *aClass in classes) {
            if ([builtClasses containsObject:aClass]) {
                continue;
            }
            [builtClasses addObject:aClass];
            
            JDCode *jsClassCode = [jsCompiler JSCodeForSheet:aClass rule:rule];
            NSString *jsClassPath =[buildJSPath stringByAppendingPathComponent:aClass.path];
            [[NSFileManager defaultManager] createFileAtPath:jsClassPath contents:jsClassCode.UTF8Data attributes:nil];
            
            JDCode *cssClassCode = [cssCompiler outputCSSCodeForSheet:aClass rule:rule];
            NSString *cssClassPath =[buildCSSPath stringByAppendingPathComponent:aClass.path];
            [[NSFileManager defaultManager] createFileAtPath:cssClassPath contents:cssClassCode.UTF8Data attributes:nil];
        }
    }
    
    return YES;
}



- (void)build_prepareBuildDirectory:(IUProject *)project rule:(NSString *)rule error:(NSError **)error{
    [[NSFileManager defaultManager] createDirectoryAtPath:project.absoluteBuildPath withIntermediateDirectories:YES attributes:nil error:error];
    [[NSFileManager defaultManager] createDirectoryAtPath:project.absoluteBuildResourcePath withIntermediateDirectories:YES attributes:nil error:error];
    
    NSString *resourceCSSPath = [self outputCSSResourcePath:project.absoluteBuildResourcePath];
    [[NSFileManager defaultManager] createDirectoryAtPath:resourceCSSPath withIntermediateDirectories:YES attributes:nil error:error];
    
    NSString *resourceJSPath = [self outputJSResourcePath:project.absoluteBuildResourcePath];
    [[NSFileManager defaultManager] createDirectoryAtPath:resourceJSPath withIntermediateDirectories:YES attributes:nil error:error];
}


- (void)build_copyDefaultResourceFile:(IUProject *)project rule:(NSString*)rule error:(NSError **)error{
    
    NSString *outputCSSPath = [self outputCSSResourcePath:project.absoluteBuildResourcePath];
    [[JDFileUtil util] overwriteBundleItem:@"reset.css" toDirectory:outputCSSPath error:nil];
    [[JDFileUtil util] overwriteBundleItem:@"iu.css" toDirectory:outputCSSPath error:nil];
    
    NSString *outputJSPath = [self outputJSResourcePath:project.absoluteBuildResourcePath];
    [[JDFileUtil util] overwriteBundleItem:@"iu.js" toDirectory:outputJSPath error:nil];
    [[JDFileUtil util] overwriteBundleItem:@"iueditor.js" toDirectory:outputJSPath error:nil];
    [[JDFileUtil util] overwriteBundleItem:@"iucarousel.js" toDirectory:outputJSPath error:nil];
    [[JDFileUtil util] overwriteBundleItem:@"jquery.event.move.js" toDirectory:outputJSPath error:nil];
    [[JDFileUtil util] overwriteBundleItem:@"jquery.event.swipe.js" toDirectory:outputJSPath error:nil];
    
#if DEBUG
    [[JDFileUtil util] overwriteBundleItem:@"stressTest.js" toDirectory:outputJSPath error:nil];
#endif
    
    // followings are needed for ie
    [[JDFileUtil util] overwriteBundleItem:@"jquery.backgroundSize.js" toDirectory:outputJSPath error:nil];
    [[JDFileUtil util] overwriteBundleItem:@"respond.min.js" toDirectory:outputJSPath error:nil];
}


- (NSString *)outputCSSResourcePath:(NSString *)buildResourcePath {
    return [buildResourcePath stringByAppendingPathComponent:@"css"];
}

- (NSString *)outputJSResourcePath:(NSString *)buildResourcePath {
    return [buildResourcePath stringByAppendingPathComponent:@"js"];
}


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
            NSString *fontName = [[IUFontController sharedFontController] fontNameForFontCSS:fontfamily];
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

    IUFontController *fontController = [IUFontController sharedFontController];
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

- (JDCode *)javascriptHeader:(IUSheet *)page target:(IUTarget)target URLPrefix:(NSString *)prefix{
    JDCode *code = [[JDCode alloc] init];
    if(target == IUTargetEditor){
        NSString *jqueryPath = [[NSBundle mainBundle] pathForResource:@"jquery-1.10.2" ofType:@"js"];
        NSString *jqueryPathCode = [NSString stringWithFormat:@"<script src='file:%@'></script>", jqueryPath];
        [code addCodeLine:jqueryPathCode];
        
        
        NSString *jqueryUIPath = [[NSBundle mainBundle] pathForResource:@"jquery-ui-1.11.1.min" ofType:@"js"];
        NSString *jqueryUIPathCode = [NSString stringWithFormat:@"<script src='file:%@'></script>", jqueryUIPath];
        [code addCodeLine:jqueryUIPathCode];

        
        NSArray *jsFiles = @[@"iueditor.js", @"iuframe.js", @"iugooglemap_theme.js"];
        for(NSString *filename in jsFiles){
            NSString *jsPath = [[NSBundle mainBundle] pathForResource:[filename stringByDeletingPathExtension] ofType:[filename pathExtension]];
            [code addCodeLineWithFormat:@"<script type=\"text/javascript\" src=\"file:%@\"></script>", jsPath];
        }
        
        //text editor - tinymce
        [code addCodeLine:@"<script type=\"text/javascript\">"];
        NSString *currentFontList = [[IUFontController sharedFontController] mceFontList];
        [code addCodeLineWithFormat:@"var iuFontList = %@;", currentFontList];
        [code addCodeLine:@"</script>"];

        NSString *mcePath = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponents:@[@"tinymce",@"tinymce"]] stringByAppendingPathExtension:@"js"];
        [code addCodeLineWithFormat:@"<script src='file:%@'></script>", mcePath];
     
    }
    else{//output
        [code addCodeLine:@"<script src='http://code.jquery.com/jquery-1.10.2.js'></script>"];
        [code addCodeLine:@"<script src='http://code.jquery.com/ui/1.11.1/jquery-ui.js'></script>"];
        
#warning Currently, do not insert js file for each page
        if([page containClass:[IUGoogleMap class]]){
            [code addCodeLine:@"<script src=\"http://maps.googleapis.com/maps/api/js?v=3.exp&sensor=true\"></script>"];
        }
        if([page containClass:[IUWebMovie class]]){
            [code addCodeLine:@"<script src=\"http://f.vimeocdn.com/js/froogaloop2.min.js\"></script>"];
        }
        
        /*
        //support ie 8
        [code addCodeLine:@"<!--[if lt IE 9]>"];
        [code increaseIndentLevelForEdit];
        [code addCodeLineWithFormat:@"<script type=\"text/javascript\" src=\"%@/js/ie/jquery.backgroundSize.js\"></script>", currentResourcePath];
        [code addCodeLineWithFormat:@"<script type=\"text/javascript\" src=\"%@/js/ie/respond.min.js\"></script>", currentResourcePath];
        [code decreaseIndentLevelForEdit];
        [code addCodeLine:@"<![endif]-->"];
         */
    }
    return code;
}

- (JDCode *)cssHeader:(IUSheet *)sheet target:(IUTarget)target commonCSSURLPrefix:(NSString *)commoneURLPrefix  IUCSSURLPrefix:(NSString *)cssURLPrefix{
    JDCode *code = [[JDCode alloc] init];
    if(target == IUTargetEditor){
        NSString *resetCSSPath = [[NSBundle mainBundle] pathForResource:@"reset" ofType:@"css"];
        [code addCodeLineWithFormat:@"<link rel=\"stylesheet\" type=\"text/css\" href=\"file://%@\">", resetCSSPath];
        NSString *editorCSSPath = [[NSBundle mainBundle] pathForResource:@"iueditor" ofType:@"css"];
        [code addCodeLineWithFormat:@"<link rel=\"stylesheet\" type=\"text/css\" href=\"file://%@\">", editorCSSPath];
    }
    else{
        [code addCodeLineWithFormat:@"<link rel=\"stylesheet\" type=\"text/css\" href=\"%@/common/reset.css\">", commoneURLPrefix];
        [code addCodeLineWithFormat:@"<link rel=\"stylesheet\" type=\"text/css\" href=\"%@/common/iu.css\">",commoneURLPrefix   ];
        [code addCodeLineWithFormat:@"<link rel=\"stylesheet\" type=\"text/css\" href=\"%@/css/%@.css\">",commoneURLPrefix, [sheet path]];
    }
    return code;
}



#pragma mark - editor body source

#pragma mark - cssSource



- (IUCSSCode*)cssCodeForIU:(IUBox *)iu target:(IUTarget)target viewport:(int)viewport{
    //TODO: optimize this function
    //currently, csscompiler makes whole css code
    return [cssCompiler cssCodeForIU:iu rule:IUCompileRuleHTML target:target viewPort:viewport option:nil];
}

- (NSString *)outputCSSSource_storage:(IUPage *)sheet{
    return nil;
#if 0
    if (sheet.project == nil){
        NSAssert(0, @"cannot make output css source without project information");
    }
    
    NSArray *mqSizeArray = sheet.project.viewPorts;
    
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
#endif
}

//to be deleted
-(JDCode *)cssSource:(IUSheet *)sheet cssSizeArray:(NSArray *)cssSizeArray{
    return nil;
    /*j
    
    //remove default size
    NSInteger largestWidth = [[cssSizeArray objectAtIndex:0] integerValue];

    JDCode *code = [[JDCode alloc] init];
    NSInteger minCount = cssSizeArray.count-1;
    
    for(int count=0; count<cssSizeArray.count; count++){
        int size = [[cssSizeArray objectAtIndex:count] intValue];
        
        //REVIEW: word press rule은 header에 붙임, 나머지는 .css파일로 따로 뽑아냄.
        if(_rule == IUCompileRuleWordpress){
            
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
     */
}


- (void)dealloc{
    JDSectionInfoLog(IULogDealloc, @"");
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
        
        if(_rule == IUCompileRuleWordpress){
            NSString *cssString = [self outputCSSSource:sheet mqSizeArray:sheet.project.viewPorts];
            [sourceCode replaceCodeString:@"<!--CSS_Replacement-->" toCodeString:cssString];
        }
        else{
            [sourceCode replaceCodeString:@"<!--CSS_Replacement-->" toCodeString:@""];
            
        }
        
        //change html
        JDCode *htmlCode = [self htmlCode:sheet target:IUTargetOutput];
        [sourceCode replaceCodeString:@"<!--HTML_Replacement-->" toCode:htmlCode];
        
        JDSectionInfoLog( IULogSource, @"source : %@", [@"\n" stringByAppendingString:sourceCode.string]);
        
        if (_rule == IUCompileRuleDjango) {
            [sourceCode replaceCodeString:@"\"resource/" toCodeString:@"\"/resource/"];
            [sourceCode replaceCodeString:@"./resource/" toCodeString:@"/resource/"];
            [sourceCode replaceCodeString:@"('resource/" toCodeString:@"('/resource/"];
        }
        if (_rule == IUCompileRuleWordpress) {
            [sourceCode replaceCodeString:@"\"resource/" toCodeString:@"\"<?php bloginfo('template_url'); ?>/resource/"];
            [sourceCode replaceCodeString:@"./resource/" toCodeString:@"<?php bloginfo('template_url'); ?>/resource/"];
            [sourceCode replaceCodeString:@"('resource/" toCodeString:@"('<?php bloginfo('template_url'); ?>/resource/"];
        }
    }
    
    return sourceCode.string;
#endif
    return NO;
}

- (void)setEditorResourceBasePath:(NSString *)path{
    _editorResourcePath = [path copy];
    [cssCompiler setEditorResourcePrefix:path];
    [htmlCompiler setEditorResourcePrefix:path];
    
}
- (void)setOutputResourceBasePath:(NSString *)path{
    _outputResourcePath = [path copy];
    //FIXME: compiler rule
    [cssCompiler setOutputResourcePrefix:path];
    [htmlCompiler setEditorResourcePrefix:path];
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


#pragma mark - IUCompilerProtocol

- (BOOL)hasLink:(IUBox *)iu{
    if([iu isKindOfClass:[PGPageLinkSet class]]
       || [iu isKindOfClass:[IUMenuBar class]]
       || [iu isKindOfClass:[IUMenuItem class]]){
        return NO;
    }
    
    return YES;
}



@end
