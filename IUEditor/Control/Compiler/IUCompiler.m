//
//  IUCompiler.m
//  IUEditor
//
//  Created by JD on 3/17/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUCompiler.h"
#import "IUProtocols.h"
#import "IUCSSCompiler.h"
#import "IUCSSWPCompiler.h"

#import "IUHTMLCompiler.h"


#import "NSString+JDExtension.h"
#import "IUSheet.h"
#import "NSDictionary+JDExtension.h"
#import "JDUIUtil.h"
#import "IUPage.h"
#import "IUHeader.h"
#import "IUPageContent.h"
#import "IUClass.h"
#import "IUBackground.h"
#import "PGTextView.h"

#import "IUHTML.h"
#import "IUImage.h"
#import "IUWebMovie.h"
#import "IUCarousel.h"
#import "IUItem.h"
#import "IUCarouselItem.h"
#import "IUCollection.h"
#import "PGSubmitButton.h"
#import "PGForm.h"
#import "PGPageLinkSet.h"
#import "IUTransition.h"
#import "JDCode.h"
#import "IUProject.h"
#import "IUMenuBar.h"
#import "IUMenuItem.h"
#import "IUTweetButton.h"
#import "IUGoogleMap.h"
#import "IUWordpressProject.h"
#import "IUCollectionView.h"


#import "WPPageLink.h"
#import "WPPageLinks.h"

#if CURRENT_TEXT_VERSION >= TEXT_SELECTION_VERSION
#import "IUText.h"
#endif

#import "LMFontController.h"
#import "WPArticle.h"

@implementation IUCompiler{
    IUCSSCompiler *cssCompiler;
    IUHTMLCompiler *htmlCompiler;
}

-(id)init{
    self = [super init];
    if (self) {
        self.webTemplateFileName = @"webTemplate";
    }
    return self;
}


- (void)setResourceManager:(IUResourceManager *)resourceManager{
    _resourceManager = resourceManager;
    if (resourceManager) {
        if (self.rule == IUCompileRuleWordpress) {
            cssCompiler = [[IUCSSWPCompiler alloc] initWithResourceManager:self.resourceManager];
        }
        else {
            cssCompiler = [[IUCSSCompiler alloc] initWithResourceManager:self.resourceManager];
            cssCompiler.compiler = self;
        }
    }
    
    htmlCompiler = [[IUHTMLCompiler alloc] init];
    htmlCompiler.compiler = self;
}

- (void)setRule:(IUCompileRule)rule{
    _rule = rule;
    if (_resourceManager) {
        if (self.rule == IUCompileRuleWordpress) {
            cssCompiler = [[IUCSSWPCompiler alloc] initWithResourceManager:self.resourceManager];
        }
        else {
            cssCompiler = [[IUCSSCompiler alloc] initWithResourceManager:self.resourceManager];
            cssCompiler.compiler = self;
        }
    }
    
    htmlCompiler = [[IUHTMLCompiler alloc] init];
    htmlCompiler.compiler = self;

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

-(JDCode *)metadataSource:(IUPage *)page{

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
        NSString *imgSrc = [self imagePathWithImageName:page.metaImage target:IUTargetOutput];
        [code addCodeLineWithFormat:@"<meta property=\"og:image\" content=\"%@\" />", imgSrc];
        [code addCodeLineWithFormat:@"<meta name=\"twitter:image\" content=\"%@\">", imgSrc];
        [code addCodeLineWithFormat:@"<meta itemprop=\"image\" content=\"%@\">", imgSrc];

    }
    if(page.project.favicon && page.project.favicon.length > 0){

        NSString *type = [page.project.favicon faviconType];
        if(type){
            NSString *imgSrc = [self imagePathWithImageName:page.project.favicon target:IUTargetOutput];
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
        NSString *fontName = box.css.effectiveTagDictionary[IUCSSTagFontName];
        if(fontName && fontName.length >0 ){
            if(box.css.effectiveTagDictionary[IUCSSTagFontWeight]){
                [fontArray addObject:@{IUCSSTagFontName:fontName, IUCSSTagFontWeight:box.css.effectiveTagDictionary[IUCSSTagFontWeight]}];
            }
            else{
                [fontArray addObject:@{IUCSSTagFontName:fontName}];
            }
        }
        NSDictionary *mqDict = [box.mqData dictionaryForTag:IUMQDataTagInnerHTML];
        NSArray *innerFontArray = [self fontNameFromInnerHTMLDictionary:mqDict];
        if(innerFontArray.count > 0){
            [fontArray addObjectsFromArray:innerFontArray];
        }

    }

    LMFontController *fontController = [LMFontController sharedFontController];
    return [fontController headerCodeForFont:fontArray];
}

- (NSArray *)outputClipArtArray:(IUSheet *)document{
    NSMutableArray *array = [NSMutableArray array];
    for (IUBox *box in document.allChildren){
        NSMutableArray *imageNames = [NSMutableArray array];
        if(box.imageName){
            [imageNames addObject:box.imageName];
        }
        
        if([box isKindOfClass:[IUCarousel class]]){
            IUCarousel *carousel = (IUCarousel *)box;
            if(carousel.leftArrowImage){
                [imageNames addObject:carousel.leftArrowImage];
            }
            if(carousel.rightArrowImage){
                [imageNames addObject:carousel.rightArrowImage];
            }
        }
        
        if(imageNames.count >0){
            for(NSString *imageName in imageNames){
                if(imageName && imageName.length > 0 && [[imageName pathComponents][0] isEqualToString:@"clipArt"]){
                    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"clipArtList" ofType:@"plist"];
                    NSDictionary *clipArtDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
                    
                    if([clipArtDict objectForKey:[imageName lastPathComponent]] != nil){
                        [array addObject:imageName];
                    }
                }
            }
        }
        
    }

    return array;
}

#pragma mark default function 

- (NSString *)imagePathWithImageName:(NSString *)imageName target:(IUTarget)target{
    NSString *imgSrc;
    
    if(imageName == nil || imageName.length==0){
        return nil;
    }
    
    if ([imageName isHTTPURL]) {
        return imageName;
    }
    //clipart
    //path : clipart/arrow_right.png
    else if([[imageName pathComponents][0] isEqualToString:@"clipArt"]){
        if(target == IUTargetEditor){
            imgSrc = [[NSBundle mainBundle] pathForImageResource:[imageName lastPathComponent]];
        }
        else{
            if(_rule == IUCompileRuleDjango){
                imgSrc = [@"/resource/" stringByAppendingString:imageName];
            }
            else{
                imgSrc = [@"resource/" stringByAppendingString:imageName];
            }
        }
    }
    else {
        IUResourceFile *file = [self.resourceManager resourceFileWithName:imageName];
        if(file){
            if(_rule == IUCompileRuleDjango && target == IUTargetOutput){
                imgSrc = [@"/" stringByAppendingString:[file relativePath]];
            }
            else{
                imgSrc = [file relativePath];
            }
        }
        
    }
    return imgSrc;
}

- (BOOL)hasLink:(IUBox *)iu{
    if([iu isKindOfClass:[PGPageLinkSet class]]
       || [iu isKindOfClass:[IUMenuBar class]]
       || [iu isKindOfClass:[IUMenuItem class]]){
        return NO;
    }
    
    return YES;
}

#pragma mark - html header

- (JDCode *)javascriptHeaderForSheet:(IUSheet *)sheet isEdit:(BOOL)isEdit{
    JDCode *code = [[JDCode alloc] init];
    if(isEdit){
        
        NSString *jqueryPath = [[NSBundle mainBundle] pathForResource:@"jquery-1.10.2" ofType:@"js"];
        NSString *jqueryPathCode = [NSString stringWithFormat:@"<script src='%@'></script>", jqueryPath];
        [code addCodeLine:jqueryPathCode];
        
        
        NSString *jqueryUIPath = [[NSBundle mainBundle] pathForResource:@"jquery-ui-1.11.1.min" ofType:@"js"];
        NSString *jqueryUIPathCode = [NSString stringWithFormat:@"<script src='%@'></script>", jqueryUIPath];
        [code addCodeLine:jqueryUIPathCode];

        
        for(NSString *filename in sheet.project.defaultEditorJSArray){
            NSString *jsPath = [[NSBundle mainBundle] pathForResource:[filename stringByDeletingPathExtension] ofType:[filename pathExtension]];
            [code addCodeLineWithFormat:@"<script type=\"text/javascript\" src=\"%@\"></script>", jsPath];
        }
        
        //text editor - tinymce
        [code addCodeLine:@"<script type=\"text/javascript\">"];
        NSString *currentFontList = [[LMFontController sharedFontController] mceFontList];
        [code addCodeLineWithFormat:@"var iuFontList = %@;", currentFontList];
        [code addCodeLine:@"</script>"];

        NSString *mcePath = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponents:@[@"tinymce",@"tinymce"]] stringByAppendingPathExtension:@"js"];
        [code addCodeLineWithFormat:@"<script src='%@'></script>", mcePath];
     
    }
    else{
        [code addCodeLine:@"<script src='http://code.jquery.com/jquery-1.10.2.js'></script>"];
        [code addCodeLine:@"<script src='http://code.jquery.com/ui/1.11.1/jquery-ui.js'></script>"];
        
        for(NSString *filename in sheet.project.defaultOutputJSArray){
            [code addCodeLineWithFormat:@"<script type=\"text/javascript\" src=\"resource/js/%@\"></script>", filename];
        }
        //each js for sheet
        if(sheet.hasEvent){
            [code addCodeLineWithFormat:@"<script type=\"text/javascript\" src=\"resource/js/%@-event.js\"></script>", sheet.name];
        }
        [code addCodeLineWithFormat:@"<script type=\"text/javascript\" src=\"resource/js/%@-init.js\"></script>", sheet.name];

        if([sheet containClass:[IUGoogleMap class]]){
            [code addCodeLine:@"<script src=\"http://maps.googleapis.com/maps/api/js?v=3.exp&sensor=true\"></script>"];
        }
        if([sheet containClass:[IUWebMovie class]]){
            [code addCodeLine:@"<script src=\"http://f.vimeocdn.com/js/froogaloop2.min.js\"></script>"];
        }
#if DEBUG
        [code addCodeLine:@"<script type=\"text/javascript\" src=\"resource/js/stressTest.js\"></script>"];
#endif
        
    }
    return code;
}

- (JDCode *)cssHeaderForSheet:(IUSheet *)sheet isEdit:(BOOL)isEdit{
    IUProject *project = sheet.project;
    JDCode *code = [[JDCode alloc] init];
    if(isEdit){
        for(NSString *filename in project.defaultEditorCSSArray){
            NSString *cssPath = [[NSBundle mainBundle] pathForResource:[filename stringByDeletingPathExtension] ofType:[filename pathExtension]];
            [code addCodeLineWithFormat:@"<link rel=\"stylesheet\" type=\"text/css\" href=\"%@\">", cssPath];
        }
        
    }
    else{
        for(NSString *filename in project.defaultOutputCSSArray){
            [code addCodeLineWithFormat:@"<link rel=\"stylesheet\" type=\"text/css\" href=\"resource/css/%@\">", filename];
        }
        [code addCodeLineWithFormat:@"<link rel=\"stylesheet\" type=\"text/css\" href=\"resource/css/%@.css\">", sheet.name];
        
    }
    return code;
}



#pragma mark - output body source
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


-(NSString*)outputHTMLSource:(IUSheet*)sheet{
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
}

- (JDCode *)htmlCode:(IUBox *)iu target:(IUTarget)target{
    return [htmlCompiler wholeHTMLCode:iu target:target];
}


#pragma mark - editor body source

-(NSString*)editorSource:(IUSheet*)document mqSizeArray:(NSArray *)mqSizeArray{
    NSString *templateFilePath = [[NSBundle mainBundle] pathForResource:self.webTemplateFileName ofType:@"html"];
    if (templateFilePath == nil) {
        NSAssert(0, @"Template file name wrong");
        return nil;
    }
    
    NSMutableString *sourceString = [NSMutableString stringWithContentsOfFile:templateFilePath encoding:NSUTF8StringEncoding error:nil];
    
    JDCode *sourceCode = [[JDCode alloc] initWithCodeString:sourceString];
    
    
    JDCode *webFontCode = [[LMFontController sharedFontController] headerCodeForAllFont];
    [sourceCode replaceCodeString:@"<!--WEBFONT_Insert-->" toCode:webFontCode];
    
    JDCode *jsCode = [self javascriptHeaderForSheet:document isEdit:YES];
    [sourceCode replaceCodeString:@"<!--JAVASCRIPT_Insert-->" toCode:jsCode];
        
    
    JDCode *iuCSS = [self cssHeaderForSheet:document isEdit:YES];
    [sourceCode replaceCodeString:@"<!--CSS_Insert-->" toCode:iuCSS];
    
    //add for hover css
    [sourceCode replaceCodeString:@"<!--CSS_Replacement-->" toCodeString:@"<style id=\"default\"></style>"];

    
    //change html
    JDCode *htmlCode = [self htmlCode:document target:IUTargetEditor];
    [sourceCode replaceCodeString:@"<!--HTML_Replacement-->" toCode:htmlCode];
    

    
    JDSectionInfoLog( IULogSource, @"source : %@", [@"\n" stringByAppendingString:sourceCode.string]);

    return sourceCode.string;
}


#pragma mark - cssSource


- (IUCSSCode*)cssCodeForIU:(IUBox*)iu{
    return [cssCompiler cssCodeForIU:iu];
}

-(JDCode *)cssSource:(IUSheet *)sheet cssSizeArray:(NSArray *)cssSizeArray{
    
    
    NSMutableArray *mqSizeArray = [cssSizeArray mutableCopy];
    //remove default size
    NSInteger largestWidth = [[mqSizeArray objectAtIndex:0] integerValue];
    [mqSizeArray removeObjectAtIndex:0];
    [mqSizeArray insertObject:@(IUCSSDefaultViewPort) atIndex:0];

    JDCode *code = [[JDCode alloc] init];
    NSInteger minCount = mqSizeArray.count-1;
    
    for(int count=0; count<mqSizeArray.count; count++){
        int size = [[mqSizeArray objectAtIndex:count] intValue];
        
        //REVIEW: word press rule은 header에 붙임, 나머지는 .css파일로 따로 뽑아냄.
        if(_rule == IUCompileRuleWordpress){
            
            if(size == IUCSSDefaultViewPort){
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
            if(size != IUCSSDefaultViewPort){
                //build는 css파일로 따로 뽑아줌
                if(count < mqSizeArray.count-1){
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
            if(size == IUCSSDefaultViewPort){
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
        
        if(_rule == IUCompileRuleWordpress){
            [code addCodeLine:@"</style>"];
        }
        else if(size != IUCSSDefaultViewPort){
            [code addCodeLine:@"}"];
        }
        
    }
    return code;
}


#pragma mark - manage JS source

-(JDCode *)outputJSInitializeSource:(IUSheet *)sheet{
    
    JDCode *jsCode = [[JDCode alloc] init];
    
    [jsCode addCode:[self defaultInitJSCode:sheet]];
    
    [jsCode addCodeLine:@"$(document).ready(function(){"];
    
    JDCode *objectJSSource = [self readyJSCode:sheet isEdit:NO];
    [jsCode addCodeWithIndent:objectJSSource];
    
    JDCode *classJSSource = [self readyJSCodeFromInitForSheet:sheet];
    [jsCode addCodeWithIndent:classJSSource];
    [jsCode addNewLine];
    
    [jsCode addCodeLine:@"});"];
    
    //text media query
    [jsCode addCodeLine:@"function reloadTextMediaQuery(){"];
    [jsCode addCodeWithIndent:[self textMQJavascriptCode:sheet]];
    [jsCode addCodeLine:@"}"];
    
    
    //window load code
    [jsCode addCode:[self windowLoadJSCodeFromInitForSheet:sheet]];
    
    return jsCode;
}

-(JDCode *)readyJSCodeFromInitForSheet:(IUSheet *)sheet{
    JDCode *jsCode = [[JDCode alloc] init];

    NSString *iuinitFilePath = [[NSBundle mainBundle] pathForResource:@"iuinit" ofType:@"js"];
    NSString *initJSStr = [NSString stringWithContentsOfFile:iuinitFilePath encoding:NSUTF8StringEncoding error:nil];
    
    if([sheet containClass:[IUTransition class]]){
        [jsCode addJSBlockFromString:initJSStr WithIdentifier:@"IUTransition"];
    }
    if([sheet containClass:[IUMenuBar class]]){
        [jsCode addJSBlockFromString:initJSStr WithIdentifier:@"IUMenuBar"];
    }
    
    [jsCode addJSBlockFromString:initJSStr WithIdentifier:@"Default"];
    return jsCode;
}

-(JDCode *)windowLoadJSCodeFromInitForSheet:(IUSheet *)sheet{
    JDCode *jsCode = [[JDCode alloc] init];
    
    NSString *iuinitFilePath = [[NSBundle mainBundle] pathForResource:@"iuinit" ofType:@"js"];
    NSString *initJSStr = [NSString stringWithContentsOfFile:iuinitFilePath encoding:NSUTF8StringEncoding error:nil];
    [jsCode addJSBlockFromString:initJSStr WithIdentifier:@"WINDOW_LOAD"];
    return jsCode;
}

-(JDCode *)defaultInitJSCode:(IUBox *)iu{
    
    JDCode *code = [[JDCode alloc] init];
    
    if([iu isKindOfClass:[IUGoogleMap class]]){
        IUGoogleMap *map = (IUGoogleMap *)iu;
        [code addCodeLineWithFormat:@"var map_%@;", map.htmlID];
    }
    else if ([iu isKindOfClass:[IUBox class]]) {
        for (IUBox *child in iu.children) {
            [code addCodeWithIndent:[self defaultInitJSCode:child]];
        }
        
    }
    return code;
}

-(JDCode *)readyJSCode:(IUBox *)iu isEdit:(BOOL)isEdit{
    JDCode *code = [[JDCode alloc] init];
    if([iu isKindOfClass:[IUCarousel class]]){
        [code addCodeLine:@"\n"];
        [code addCodeLine:@"/* IUCarousel initialize */\n"];
        [code addCodeLineWithFormat:@"initCarousel('%@')", iu.htmlID];
        for (IUBox *child in iu.children) {
            [code addCodeWithIndent:[self readyJSCode:child isEdit:isEdit]];
        }
    }
    else if([iu isKindOfClass:[IUCollectionView class]]){
        IUCollectionView *collectionView = (IUCollectionView *)iu;
        if(collectionView){
            [code addCodeLine:@"/* IUCollectionView initialize */\n"];

            NSString *itemIdentifier = collectionView.collection.prototypeClass.htmlID;
            [code addCodeLineWithFormat:@"$('.%@').click(function(){", itemIdentifier];
            [code increaseIndentLevelForEdit];
            [code addCodeLine:@"var index = $(this).index();"];
            [code addCodeLineWithFormat:@"showCollectionView('%@', index);", collectionView.htmlID];
            [code decreaseIndentLevelForEdit];
            [code addCodeLine:@"})"];
            [code addCodeLineWithFormat:@"showCollectionView('%@', 0);", collectionView.htmlID];
            [code addCodeLineWithFormat:@"$('.%@').css('cursor', 'pointer')", itemIdentifier];

        }
    }
    else if([iu isKindOfClass:[IUGoogleMap class]]){
        IUGoogleMap *map = (IUGoogleMap *)iu;
        [code addCodeLine:@"/* IUGoogleMap initialize */\n"];
        
        //style option
        if(map.themeType != IUGoogleMapThemeTypeDefault){
            [code addCodeLineWithFormat:@"var %@_styles = %@; ", map.htmlID, [map currentThemeStyle]];
        }
        
        //option
        [code addCodeLineWithFormat:@"var %@_options = {", map.htmlID];
        [code increaseIndentLevelForEdit];
        [code addCodeLineWithFormat:@"center : new google.maps.LatLng(%@, %@),", map.latitude, map.longitude];
        [code addCodeLineWithFormat:@"zoom : %ld,", map.zoomLevel];
        if(map.zoomControl){
            [code addCodeLine:@"zoomControl: true,"];
        }
        else{
            [code addCodeLine:@"zoomControl: false,"];

        }
        if(map.panControl){
            [code addCodeLine:@"panControl: true,"];
        }
        else{
            [code addCodeLine:@"panControl: false,"];

        }
        [code addCodeLine:@"mapTypeControl: false,"];
        [code addCodeLine:@"streetViewControl: false,"];
        if(map.themeType != IUGoogleMapThemeTypeDefault){
            [code addCodeLineWithFormat:@"styles: %@_styles", map.htmlID];
        }
        
        [code decreaseIndentLevelForEdit];
        [code addCodeLine:@"};"];
        
        
        
        //map
        [code addCodeLineWithFormat:@"map_%@ = new google.maps.Map(document.getElementById('%@'), %@_options);", map.htmlID, map.htmlID, map.htmlID];
        
        //marker
        if(map.enableMarkerIcon){
            [code addCodeLineWithFormat:@"var marker_%@ = new google.maps.Marker({", map.htmlID];
            [code increaseIndentLevelForEdit];
            [code addCodeLineWithFormat:@"map: map_%@,", map.htmlID];
            [code addCodeLineWithFormat:@"position: map_%@.getCenter(),", map.htmlID];
            if(map.markerIconName){
                NSString *imgSrc = [self imagePathWithImageName:map.markerIconName target:IUTargetOutput];
                [code addCodeLineWithFormat:@"icon: '%@'", imgSrc];
            }
            [code decreaseIndentLevelForEdit];
            [code addCodeLine:@"});"];
         }
        //info window
        if(map.markerTitle){
            [code addCodeLineWithFormat:@"var infoWindow_%@ = new google.maps.InfoWindow();", map.htmlID];
            [code addCodeLineWithFormat:@"infoWindow_%@.setContent('<p>%@</p>');", map.htmlID, map.markerTitle];
            [code addCodeLineWithFormat:@"google.maps.event.addListener(marker_%@, 'click', function() { infoWindow_%@.open(map_%@, marker_%@); });", map.htmlID, map.htmlID, map.htmlID, map.htmlID];
        }
        
        //resize
        [code addCodeLine:@"google.maps.event.addDomListener(window, \"resize\", function() {"];
        [code increaseIndentLevelForEdit];
        [code addCodeLineWithFormat:@"var center = new google.maps.LatLng(%@, %@);", map.latitude, map.longitude];
        [code addCodeLineWithFormat:@"google.maps.event.trigger(map_%@, \"resize\");", map.htmlID];
        [code addCodeLineWithFormat:@"map_%@.setCenter(center);", map.htmlID];
        [code decreaseIndentLevelForEdit];
        [code addCodeLine:@"});"];
        
        
    }
    else if ([iu isKindOfClass:[IUBox class]]) {
        for (IUBox *child in iu.children) {
            [code addCodeWithIndent:[self readyJSCode:child isEdit:isEdit]];
        }

    }
    return code;
}
- (JDCode *)mqCodeForTag:(IUMQDataTag)tag inIU:(IUBox *)iu{
    JDCode *code = [[JDCode alloc] init];
    NSDictionary *mqDict = [iu.mqData dictionaryForTag:tag];
    if(mqDict.count > 0){
        [code addCodeLine:@"{"];
        [code increaseIndentLevelForEdit];
        for(NSString *widthStr in [mqDict allKeys]){
            [code addCodeLineWithFormat:@"%@:\"%@\",", widthStr, [mqDict[widthStr] JSEscape]];
            
        }
        [code decreaseIndentLevelForEdit];
        [code addCodeLine:@"}"];
    }
    return code;
}

- (JDCode *)textMQJavascriptCode:(IUBox *)iu{
    JDCode *code = [[JDCode alloc] init];
    if ([iu isKindOfClass:[IUBox class]]) {
        NSDictionary *mqDict = [iu.mqData dictionaryForTag:IUMQDataTagInnerHTML];
        if(mqDict.count > 1){
            [code addCodeLineWithFormat:@"var %@_textMQDict = ", iu.htmlID];
            [code addCode:[self mqCodeForTag:IUMQDataTagInnerHTML inIU:iu]];
            [code addCodeLineWithFormat:@"var %@_currentText = getCurrentData(%@_textMQDict)", iu.htmlID, iu.htmlID];
            [code addCodeLineWithFormat:@"$('.%@').html(%@_currentText)", iu.htmlID, iu.htmlID];
            
        }
        else{
            for (IUBox *child in iu.children) {
                [code addCode:[self textMQJavascriptCode:child]];
            }
        }
    }

    
    return code;
}


- (void)dealloc{
    [JDLogUtil log:IULogDealloc string:@"IUCompiler"];
}
@end
