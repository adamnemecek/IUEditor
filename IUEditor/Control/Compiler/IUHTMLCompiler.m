//
//  IUHTMLCompiler.m
//  IUEditor
//
//  Created by seungmi on 2014. 9. 19..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUHTMLCompiler.h"
#import "IUCompiler.h"

#import "IUBox.h"
#import "IUClass.h"
#import "IUSidebar.h"
#import "IUSection.h"

#import "IUImage.h"
#import "IUMovie.h"
#import "IUWebMovie.h"
#import "IUHTML.h"
#import "IUGoogleMap.h"

#import "IUTransition.h"
#import "IUCollection.h"
#import "IUCollectionView.h"
#import "IUCarouselItem.h"
#import "IUMenuBar.h"
#import "IUMenuItem.h"

#import "IUFBLike.h"
#import "IUTweetButton.h"

//django

#import "PGForm.h"
#import "PGPageLinkSet.h"
#import "PGTextField.h"
#import "PGTextView.h"
#import "PGSubmitButton.h"


//wordpress
#import "IUProtocols.h"
#import "WPPageLink.h"

@implementation IUHTMLCompiler


#pragma mark - general function

- (NSString *)linkHeaderString:(IUBox *)iu{
    //find link url
    NSString *linkStr;
    if([iu.link isKindOfClass:[NSString class]]){
        linkStr = iu.link;
    }
    else if([iu.link isKindOfClass:[IUBox class]]){
        linkStr = [((IUBox *)iu.link).htmlID lowercaseString];
    }
    NSString *linkURL = linkStr;
    if ([linkStr isHTTPURL] == NO) {
        if (_compiler.rule == IUCompileRuleDjango) {
            if(iu.divLink){
                if([linkStr isEqualToString:@"Self"]){
                    linkURL = [NSString stringWithFormat:@"#%@", ((IUBox *)iu.divLink).htmlID];
                }
                else{
                    linkURL = [NSString stringWithFormat:@"/%@#%@", linkStr , ((IUBox *)iu.divLink).htmlID];
                }
            }
            else{
                linkURL = [NSString stringWithFormat:@"/%@", linkStr];
            }
        }
        else {
            if(iu.divLink){
                if([linkStr isEqualToString:@"Self"]){
                    linkURL = [NSString stringWithFormat:@"#%@", ((IUBox *)iu.divLink).htmlID];
                }
                else{
                    linkURL = [NSString stringWithFormat:@"./%@.html#%@", linkStr, ((IUBox *)iu.divLink).htmlID];
                }
            }
            else{
                linkURL = [NSString stringWithFormat:@"./%@.html", linkStr];
            }
        }
    }
    
    JDCode *code = [[JDCode alloc] init];

    
    [code addCodeWithFormat:@"<a href='%@' ", linkURL];
    if(iu.linkTarget){
        [code addCodeWithFormat:@" target='_blank'"];
    }
    if(iu.divLink){
        [code addCodeWithFormat:@" divlink='1'"];
    }
    
    [code addCodeWithFormat:@">"];
    
    return code.string;
}


-(NSArray *)htmlClassForIU:(IUBox *)iu target:(IUTarget)target{
    NSMutableArray *classArray = [NSMutableArray array];
    NSArray *classPedigree = [[iu class] classPedigreeTo:[IUBox class]];
    [classArray addObjectsFromArray:classPedigree];
    [classArray insertObject:iu.htmlID atIndex:0];
#pragma mark IUCarouselItem
    if([iu isKindOfClass:[IUCarouselItem class]]){
        if(target == IUTargetEditor && ((IUCarouselItem *)iu).isActive){
            [classArray addObject:@"active"];
        }
    }
#pragma mark IUMenuBar, IUMenuItem
    else if([iu isKindOfClass:[IUMenuBar class]] ||
            [iu isKindOfClass:[IUMenuItem class]]){
        if(iu.children.count >0){
            [classArray addObject:@"has-sub"];
        }
        
        if([iu isKindOfClass:[IUMenuBar class]]){
            IUMenuBar *menuBar = (IUMenuBar *)iu;
            if(menuBar.align == IUMenuBarAlignRight){
                [classArray addObject:@"align-right"];
            }
        }
    }
    return classArray;
}


-(NSMutableDictionary *)htmlAttributeForIU:(IUBox *)iu target:(IUTarget)target withCSS:(BOOL)withCSS{
    NSMutableDictionary *attributeDict = [NSMutableDictionary dictionary];
    [attributeDict setObject:iu.htmlID forKey:@"id"];
    [attributeDict setObject:[self htmlClassForIU:iu target:target] forKey:@"class"];
    
    if(iu.enableHCenter){
        [attributeDict setObject:@"1" forKey:@"horizontalCenter"];
    }
    if(iu.enableVCenter){
        [attributeDict setObject:@"1" forKey:@"verticalCenter"];
    }

    /*
     Commented.
     For django for-loop (collection-class structure) default css does not supported.

    id value = [iu.css tagDictionaryForViewport:IUCSSDefaultViewPort][IUCSSTagImage];
    if([value isDjangoVariable] && _compiler.rule == IUCompileRuleDjango){
        NSString *imgSrc = value;
        if(imgSrc){
            NSString *styleValue = [NSString stringWithFormat:@"background-image:url(%@)", imgSrc];
            [attributeDict setObject:styleValue forKey:@"style"];
        }
    }
    */
    
    //target별 attribute
    if (target == IUTargetOutput){
        if (iu.opacityMove) {
            [attributeDict setObject:@(iu.opacityMove) forKey:@"opacityMove"];
        }
        if (iu.xPosMove) {
            [attributeDict setObject:@(iu.xPosMove) forKey:@"xPosMove"];
        }
        
        //active class를 add 하기 위한 attribute
        if(iu.link && [_compiler hasLink:iu] && [iu.link isKindOfClass:[IUBox class]]
           //image class는 a tag가 바깥으로 붙고, active상태를 이용하지 않음.
           && [iu isKindOfClass:[IUImage class]] == NO){
        
            [attributeDict setObject:@"1" forKey:@"iulink"];
        }
        if(iu.linkCaller){
            [attributeDict setObject:[NSNull null] forKey:@"iudivlink"];
            [attributeDict setObject:((IUBox *)iu.linkCaller).htmlID forKey:@"linkcaller"];

        }
    }
    else if (target == IUTargetEditor && withCSS) {
        NSAssert(self.cssCompiler, @"does not have css compiler");
        IUCSSCode *cssCode = [self.cssCompiler cssCodeForIU_storage:iu target:IUTargetEditor viewPort:IUDefaultViewPort];
        [attributeDict setObject:[cssCode stringCodeWithMainIdentifieForTarget:IUTargetEditor viewPort:IUDefaultViewPort] forKey:@"style"];
    }
    
    return attributeDict;
}

- (NSString *)attributeString:(NSDictionary *)dict{
    NSMutableString *attributeString = [NSMutableString string];
    
    for(NSString *attributeName in dict.allKeys){
        NSString *attributeValue;
        id value = [dict objectForKey:attributeName];
        
        if([attributeName isEqualToString:@"class"]){
            NSMutableString *classValue = [NSMutableString string];
            NSArray *classArray = (NSArray *)value;
            for(NSString *className in classArray){
                [classValue appendFormat:@"%@ ", className];
            }
            attributeValue = classValue;
        }
        else if ([attributeName isEqualToString:@"style"]){
            NSMutableString *classValue = [NSMutableString string];
            NSDictionary *cssDict = value;
            for(NSString *cssString in cssDict){
                [classValue appendFormat:@"%@: %@; ", cssString, cssDict[cssString]];
            }
            attributeValue = classValue;
        }
        //attribute w/o value
        else if([value isKindOfClass:[NSNull class]]){
            [attributeString appendFormat:@"%@ ", attributeName];
            continue;
        }
        else if([value isKindOfClass:[NSString class]]){
            attributeValue = value;
        }
        else if([value isKindOfClass:[NSNumber class]]){
            if(CFNumberIsFloatType((CFNumberRef)value)){
                attributeValue = [NSString stringWithFormat:@"%.1f", [value floatValue]];
            }
            else{
                attributeValue = [NSString stringWithFormat:@"%ld", [value integerValue]];
            }
        }
        
        [attributeString appendFormat:@"%@=\"%@\" ", attributeName, attributeValue];
    }
    
    return attributeString;
}

/**
 @brief 
 check code before build
 */
- (void)checkBeforeBuildCode:(IUBox *)iu target:(IUTarget)target{
    
    NSMutableArray *wholeIU = [NSMutableArray array];
    [wholeIU addObject:iu];
    [wholeIU addObjectsFromArray:iu.allChildren];
    
    for(IUBox *box in wholeIU){
        if(target == IUTargetOutput){
            if(box.divLink){
                IUBox *target = (IUBox *)box.divLink;
                target.linkCaller = box;
            }
        }
    }
}

- (JDCode *)wholeHTMLCode:(IUBox *)iu target:(IUTarget)target withCSS:(BOOL)withCSS{
    
    [self checkBeforeBuildCode:iu target:target];
    
    JDCode *code = [[JDCode alloc] init];
    [self htmlCode:iu target:target code:code withCSS:withCSS];
    return code;
}


/**
@brief code를 return값으로 돌려주지 않고 parameter로 code를 넘겨서 해당 값으로 저장해서 준다.
 
@param iu code가 만들어질 iu
@param target editor or build type
@param code code를 덧붙일때 사용함. 보통 child html콜할때 사용.
 
 */
- (void)htmlCode:(IUBox *)iu target:(IUTarget)target code:(JDCode *)code withCSS:(BOOL)withCSS{
    
    NSArray *classPedigree = [[iu class] classPedigreeTo:[IUBox class]];
    for (NSString *className in classPedigree) {
        NSString *str = [NSString stringWithFormat:@"htmlCodeAs%@:target:attributeDict:withCSS:", className];
        SEL selector = NSSelectorFromString(str);
        if ([self respondsToSelector:selector]) {
            
            //call widget html
            IMP imp = [self methodForSelector:selector];
            JDCode *(*func)(id, SEL, id, IUTarget, NSDictionary *, BOOL) = (void *)imp;
            NSMutableDictionary *attributeDict = [self htmlAttributeForIU:iu target:target withCSS:withCSS];
            
            [code addCodeWithIndent:(JDCode *)func(self, selector, iu, target, attributeDict, withCSS)];
            
            //add link
            if(target == IUTargetOutput){
                if (iu.link && [_compiler hasLink:iu]) {
                    NSString *linkStr = [self linkHeaderString:iu];
                    if([iu isKindOfClass:[IUImage class]]){
                        //닫는 태그가 없는 종류들은 a tag를 바깥으로 붙임.
                        [code wrapTextWithStartString:linkStr endString:@"</a>"];
                    }
                    else{
                        //REVIEW: a tag는 밑으로 들어감. 상위에 있을 경우에 %사이즈를 먹어버림.
                        [code wrapChildTextWithStartString:linkStr endString:@"</a>"];
                    }
                }
            }
            
            break;
        }
    }
}

#pragma mark - layout widget
- (JDCode *)htmlCodeAsIUSidebar:(IUSidebar *)sidebar target:(IUTarget)target attributeDict:(NSMutableDictionary *)attributeDict withCSS:(BOOL)withCSS {
    
    attributeDict[@"sidebarType"] = @(sidebar.type);
    
    JDCode *code = [self htmlCodeAsIUImport:sidebar target:target attributeDict:attributeDict withCSS:withCSS];
    
    return code;
}

- (JDCode *)htmlCodeAsIUSection:(IUSection *)section target:(IUTarget)target attributeDict:(NSMutableDictionary *)attributeDict withCSS:(BOOL)withCSS {
    if(target == IUTargetOutput && section.enableFullSize){
        attributeDict[@"enableFullSize"] = @"1";
    }
    JDCode *code = [self htmlCodeAsIUBox:section target:target attributeDict:attributeDict withCSS:withCSS];
    
    return code;
}

#pragma mark - default widget

- (JDCode *)htmlCodeAsIUTransition:(IUTransition *)transition target:(IUTarget)target attributeDict:(NSMutableDictionary *)attributeDict withCSS:(BOOL)withCSS {
    if ([transition.eventType length]) {
        if ([transition.eventType isEqualToString:kIUTransitionEventClick]) {
            attributeDict[@"transitionEvent"] =  @"click";
        }
        else if ([transition.eventType isEqualToString:kIUTransitionEventMouseOn]){
            attributeDict[@"transitionEvent"] = @"mouseOn";
        }
        else {
            NSAssert(0, @"Missing Code");
        }
        float duration = transition.duration;
        if(duration < 1){
            attributeDict[@"transitionDuration"] = @"0";
        }
        else{
            attributeDict[@"transitionDuration"] = @(duration*1000);
        }
    }
    if ([transition.animation length]) {
        attributeDict[@"transitionAnimation"] = [transition.animation lowercaseString];
    }
    
    
    JDCode *code = [self htmlCodeAsIUBox:transition target:target attributeDict:attributeDict withCSS:withCSS];
 
    return code;
}


- (JDCode *)htmlCodeAsIUMenuBar:(IUMenuBar *)menuBar target:(IUTarget)target attributeDict:(NSMutableDictionary *)attributeDict withCSS:(BOOL)withCSS {
    JDCode *code = [[JDCode alloc] init];
    [code addCodeLineWithFormat:@"<div %@>", [self attributeString:attributeDict]];
    NSString *title = menuBar.mobileTitle;
    if(title == nil){
        title = @"MENU";
    }
    [code addCodeLineWithFormat:@"<div class=\"mobile-button\">%@<div class='menu-top'></div><div class='menu-bottom'></div></div>", title];

    
    if(menuBar.children.count > 0){
        [code increaseIndentLevelForEdit];
        [code addCodeLine:@"<ul>"];
        
        for (IUBox *child in menuBar.children){
            [self htmlCode:child target:target code:code withCSS:withCSS];
        }
        [code addCodeLine:@"</ul>"];
        [code decreaseIndentLevelForEdit];
    }
    
    [code addCodeLine:@"</div>"];
    return code;
}

- (JDCode *)htmlCodeAsIUMenuItem:(IUMenuItem *)menuItem target:(IUTarget)target attributeDict:(NSMutableDictionary *)attributeDict withCSS:(BOOL)withCSS {
    JDCode *code = [[JDCode alloc] init];
    
    [code addCodeLineWithFormat:@"<li %@>", [self attributeString:attributeDict]];
    [code increaseIndentLevelForEdit];
    
    if(menuItem.text && menuItem.text.length > 0){
        if(target == IUTargetEditor){
            [code addCodeLineWithFormat:@"<a>%@</a>", menuItem.text];
        }
        else if(target == IUTargetOutput){
            if(menuItem.link){
                [code addCodeLineWithFormat:@"%@%@</a>", [self linkHeaderString:menuItem], menuItem.text];
            }
            else{
                [code addCodeLineWithFormat:@"<a href=''>%@</a>", menuItem.text];
            }
        }
    }
    if(menuItem.children.count > 0){
        //TODO: closure position property랑 connect 되면 소스 추가
        //        [code addCodeLine:@"<div class='closure'></div>"];
        [code addCodeLine:@"<ul>"];
        for(IUBox *child in menuItem.children){
            [self htmlCode:child target:target code:code withCSS:withCSS];
        }
        [code addCodeLine:@"</ul>"];
    }
    
    [code decreaseIndentLevelForEdit];
    [code addCodeLine:@"</li>"];
    return code;
}

- (JDCode *)htmlCodeAsIUCarousel:(IUCarousel *)carousel target:(IUTarget)target attributeDict:(NSMutableDictionary *)attributeDict withCSS:(BOOL)withCSS {
    JDCode *code = [[JDCode alloc] init];
    
    if(target == IUTargetEditor){
        [code addCodeLineWithFormat:@"<div %@>", [self attributeString:attributeDict]];
        //carousel item
        for(IUCarouselItem *item in carousel.children){
            [self htmlCode:item target:target code:code withCSS:withCSS];
        }
    }
    else if(target == IUTargetOutput){
        if(carousel.autoplay && carousel.timer > 0){
            [attributeDict setObject:@(carousel.timer*1000) forKey:@"timer"];
        }
        
        [code addCodeLineWithFormat:@"<div %@>", [self attributeString:attributeDict]];
        
        //carousel item
        [code addCodeLineWithFormat:@"<div class='wrapper' id='wrapper_%@'>", carousel.htmlID];
        for(IUItem *item in carousel.children){
            [self htmlCode:item target:target code:code withCSS:withCSS];
        }
        [code addCodeLine:@"</div>"];
    }
    
    //control
    [code addCodeLine:@"<div class='Next'></div>"];
    [code addCodeLine:@"<div class='Prev'></div>"];
    
    
    if(carousel.controlType == IUCarouselControlBottom){
        [code addCodeLine:@"<ul class='Pager'>"];
        [code increaseIndentLevelForEdit];
        for(int i=0; i<carousel.children.count; i++){
            [code addCodeLine:@"<li></li>"];
        }
        [code decreaseIndentLevelForEdit];
        [code addCodeLine:@"</ul>"];
    }
    
    [code addCodeLine:@"</div>"];
    
    return code;
}

- (JDCode *)htmlCodeAsIUImage:(IUImage *)image target:(IUTarget)target attributeDict:(NSMutableDictionary *)attributeDict withCSS:(BOOL)withCSS {
    JDCode *code = [[JDCode alloc] init];
    
    if (image.pgContentVariable && image.pgContentVariable.length > 0 && _compiler.rule == IUCompileRuleDjango) {
        if ([image.sheet isKindOfClass:[IUClass class]]) {
            attributeDict[@"src"] = [NSString stringWithFormat:@"{{ object.%@ }}", image.pgContentVariable];
        }
        else {
            attributeDict[@"src"] = [NSString stringWithFormat:@"{{ %@ }}", image.pgContentVariable];
        }
    }else{
        //image tag attributes
        if(image.imageName && image.imageName.length > 0){
            NSString *imgSrc = [_compiler imagePathWithImageName:image.imageName target:target forFilePath:IUFilePathHTML];
            if(imgSrc && imgSrc.length > 0){
                attributeDict[@"src"] = imgSrc;
            }

        }
        else if (target == IUTargetEditor){
            NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"image_default" ofType:@"png"];
            attributeDict[@"src"] = imagePath;

        }
        if(image.altText){
            attributeDict[@"alt"] = image.altText;
        }
    }
    
    [code addCodeLineWithFormat:@"<img %@ />", [self attributeString:attributeDict]];
    
    return code;
}


- (JDCode *)htmlCodeAsIUMovie:(IUMovie *)movie target:(IUTarget)target attributeDict:(NSMutableDictionary *)attributeDict withCSS:(BOOL)withCSS {
    JDCode *code = [[JDCode alloc] init];
    if(target == IUTargetOutput){
        if (movie.enableControl) {
            attributeDict[@"controls"] = [NSNull null];
        }
        if (movie.enableLoop) {
            attributeDict[@"loop"] = [NSNull null];
        }
        if (movie.enableMute) {
            attributeDict[@"muted"] = [NSNull null];
        }
        if (movie.enableAutoPlay) {
            attributeDict[@"autoplay"] = [NSNull null];
        }
        if (movie.posterPath) {
            attributeDict[@"poster"] = movie.posterPath;
        }
        [code addCodeLineWithFormat:@"<video %@>", [self attributeString:attributeDict]];
        if(movie.videoPath){
            NSMutableString *compatibilitySrc = [NSMutableString stringWithString:@"\
                                                 <source src=\"$moviename$\" type=\"video/$type$\">\n\
                                                 <object data=\"$moviename$\" width=\"100%\" height=\"100%\">\n\
                                                 <embed width=\"100%\" height=\"100%\" src=\"$moviename$\">\n\
                                                 </object>"];
            
            [compatibilitySrc replaceOccurrencesOfString:@"$moviename$" withString:movie.videoPath options:0 range:NSMakeRange(0, compatibilitySrc.length)];
            [compatibilitySrc replaceOccurrencesOfString:@"$type$" withString:movie.videoPath.pathExtension options:0 range:NSMakeRange(0, compatibilitySrc.length)];
            
            [code addCodeLine:compatibilitySrc];
        }
        if(movie.altText){
            [code addCodeLine:movie.altText];
        }
        
        [code addCodeLine:@"</video>"];
        
    }
    else if(target == IUTargetEditor){
        
        [code addCodeLineWithFormat:@"<div %@>", [self attributeString:attributeDict]];

        NSString *thumbnailPath;
        if(movie.videoPath && movie.posterPath){
            thumbnailPath = [NSString stringWithString:movie.posterPath];
        }
        else{
            thumbnailPath = [[NSBundle mainBundle] pathForResource:@"video_bg" ofType:@"png"];
        }
        
        [code addCodeLineWithFormat:@"<div style=\"background-image:url('%@');\
         background-size:contain;\
         background-repeat:no-repeat; \
         background-position:center; \
         width:100%%; height:100%%; \
         position:absolute; left:0; top:0\"></div>", thumbnailPath];
        
        
        NSString *videoPlayImagePath = [[NSBundle mainBundle] pathForResource:@"video_play" ofType:@"png"];
        [code addCodeLineWithFormat:@"<div style=\"background-image:url('%@'); \
         background-size:20%%;\
         background-repeat:no-repeat; \
         background-position:center; \
         position:absolute;  width:100%%; height:100%%; \"></div>", videoPlayImagePath];
        
        [code addCodeLine:@"</div>"];
    }
    

    return code;
}

- (JDCode *)htmlCodeAsIUWebMovie:(IUWebMovie *)webmovie target:(IUTarget)target attributeDict:(NSMutableDictionary *)attributeDict withCSS:(BOOL)withCSS {
    JDCode *code = [[JDCode alloc] init];
    
    if(webmovie.playType == IUWebMoviePlayTypeJSAutoplay){
        attributeDict[@"eventAutoplay"]= @"1";
        attributeDict[@"videoid"]= webmovie.thumbnailID;

        if(webmovie.movieType == IUWebMovieTypeYoutube){
            attributeDict[@"videotype"] =@"youtube";
        }
        else if (webmovie.movieType == IUWebMovieTypeVimeo){
            attributeDict[@"videotype"] =@"vimeo";
        }
    }

    [code addCodeLineWithFormat:@"<div %@ >", [self attributeString:attributeDict]];

    if(target == IUTargetOutput){
        if(webmovie.movieType == IUWebMovieTypeVimeo){
            [code addCodeWithFormat:@"<iframe src=\"http://player.vimeo.com/video/%@?api=1&player_id=%@_vimeo", webmovie.movieID, webmovie.htmlID];
            
        }
        else if (webmovie.movieType == IUWebMovieTypeYoutube){
            [code addCodeLineWithFormat:@"<object width=\"100%\" height=\"100%\">"];
            
            [code addCodeLineWithFormat:@"<param name=\"movie\" value=\"https://youtube.googleapis.com/%@?version=2&fs=1\"</param>", [webmovie.movieLink lastPathComponent]];
            [code addCodeLineWithFormat:@"<param name=\"allowFullScreen\" value=\"true\"></param>"];
            [code addCodeLineWithFormat:@"<param name=\"allowScriptAccess\" value=\"always\"></param>"];
            
            
            [code addCodeWithFormat:@"<embed id='%@_youtube'", webmovie.htmlID];
            [code addCodeWithFormat:@" src=\"http://www.youtube.com/v/%@?version=3&enablejsapi=1", [webmovie.movieLink lastPathComponent]];
            
            if([[webmovie.movieLink lastPathComponent] containsString:@"list"]){
                [code addString:@"&listType=playlist"];
            }
            [code addCodeWithFormat:@"&autohide=1&playerapiid=%@_youtube", webmovie.htmlID];
        }
        
        if(webmovie.movieType == IUWebMovieTypeYoutube || webmovie.movieType == IUWebMovieTypeVimeo){
            
            if(webmovie.playType == IUWebMoviePlayTypeAutoplay){
                [code addString:@"&autoplay=1"];
            }
            if(webmovie.enableLoop){
                [code addString:@"&loop=1"];
            }
            [code addString:@"\""];
            //end of video src embeded
            
            [code addString:@" webkitallowfullscreen mozallowfullscreen allowfullscreen frameborder=\"0\" width=\"100%\" height=\"100%\" "];
            
            if (webmovie.movieType == IUWebMovieTypeVimeo){
                [code addString:@"></iframe>"];
            }
            else if(webmovie.movieType == IUWebMovieTypeYoutube){
                [code addString:@"type=\"application/x-shockwave-flash\" allowscriptaccess=\"always\""];
                [code addString:@"></embed>"];
                [code addString:@"</object>"];
            }


        }
    }
    else if(target == IUTargetEditor){
        
        NSString *thumbnailPath;
        if(webmovie.thumbnail){
            thumbnailPath = [NSString stringWithString:webmovie.thumbnailPath];
        }
        else{
            thumbnailPath = [[NSBundle mainBundle] pathForResource:@"video_bg" ofType:@"png"];
        }
        
        [code addCodeLineWithFormat:@"<img src = \"%@\" width='100%%' height='100%%' style='position:absolute; left:0; top:0'>", thumbnailPath];
        
        NSString *videoPlayImagePath = [[NSBundle mainBundle] pathForResource:@"video_play" ofType:@"png"];
        [code addCodeLineWithFormat:@"<div style=\"background-image:url('%@'); \
         background-size:20%%;\
         background-repeat:no-repeat; \
         background-position:center; \
         position:absolute;  width:100%%; height:100%%; \"></div>", videoPlayImagePath];

    }
    
    
    [code addCodeLine:@"</div>"];


    
    return code;
}
- (JDCode *)htmlCodeAsIUHTML:(IUHTML *)html target:(IUTarget)target attributeDict:(NSMutableDictionary *)attributeDict withCSS:(BOOL)withCSS {
    JDCode *code = [[JDCode alloc] init];
    
    [code addCodeLineWithFormat:@"<div %@>", [self attributeString:attributeDict]];
    if(html.hasInnerHTML){
        [code addCodeLine:html.innerHTML];
    }
    if (html.children.count) {
        for (IUBox *child in html.children) {
            [self htmlCode:child target:target code:code withCSS:withCSS];
        }
    }
    [code addCodeLineWithFormat:@"</div>"];

    
    return code;
}
- (JDCode *)htmlCodeAsIUFBLike:(IUFBLike *)fblike target:(IUTarget)target attributeDict:(NSMutableDictionary *)attributeDict withCSS:(BOOL)withCSS {
    JDCode *code = [[JDCode alloc] init];
    
    if(target == IUTargetOutput){
        
        code = [self htmlCodeAsIUHTML:fblike target:target attributeDict:attributeDict withCSS:withCSS];
    }
    else if( target == IUTargetEditor ){
        [code addCodeLineWithFormat:@"<div %@ >", [self attributeString:attributeDict]];
        
        NSString *fbPath = [[NSBundle mainBundle] pathForResource:@"FBSampleImage" ofType:@"png"];
        NSString *editorHTML = [NSString stringWithFormat:@"<img src=\"%@\" align=\"middle\" style=\"float:left;margin:0 5px 0 0; \" ><p style=\"font-size:11px ; font-family:'Helvetica Neue', Helvetica, Arial, 'lucida grande',tahoma,verdana,arial,sans-serif\">263,929 people like this. Be the first of your friends.</p>", fbPath];
        
        [code addCodeLine:editorHTML];
        [code addCodeLine:@"</div>"];

    }
    
    return code;
}

- (JDCode *)htmlCodeAsIUTweetButton:(IUTweetButton *)tweet target:(IUTarget)target attributeDict:(NSMutableDictionary *)attributeDict withCSS:(BOOL)withCSS {
    JDCode *code = [[JDCode alloc] init];
    
    [code addCodeLineWithFormat:@"<div %@ >", [self attributeString:attributeDict]];

    if(target == IUTargetOutput){
        
        [code addString:@"<a href=\"https://twitter.com/share\" class=\"twitter-share-button\""];
        if(tweet.tweetText){
            [code addCodeWithFormat:@" data-text=\"%@\"", tweet.tweetText];
        }
        if(tweet.urlToTweet){
            [code addCodeWithFormat:@" data-url=\"%@\"", tweet.urlToTweet];
        }
        
        NSString *type;
        switch (tweet.countType) {
            case IUTweetButtonCountTypeVertical:
                type = @"vertical";
                break;
            case IUTweetButtonCountTypeHorizontal:
                type = @"horizontal";
                break;
            case IUTweetButtonCountTypeNone:
                type = @"none";
            default:
                break;
        }
        
        [code addCodeWithFormat:@" data-count=\"%@\"", type];
        if(tweet.sizeType == IUTweetButtonSizeTypeLarge){
            [code addCodeWithFormat:@" data-size=\"large\""];
        }
        
        [code addCodeLine:@">Tweet</a>"];
        
    }
    else if( target == IUTargetEditor ){
        
        
        NSString *imageName;
        switch (tweet.countType) {
            case IUTweetButtonCountTypeVertical:
                imageName = @"ttwidgetVertical";
                break;
            case IUTweetButtonCountTypeHorizontal:
                if(tweet.sizeType == IUTweetButtonSizeTypeLarge){
                    imageName = @"ttwidgetLargeHorizontal";
                }
                else{
                    imageName = @"ttwidgetHorizontal";
                }
                break;
            case IUTweetButtonCountTypeNone:
                if(tweet.sizeType == IUTweetButtonSizeTypeLarge){
                    imageName = @"ttwidgetLargeNone";
                }
                else{
                    imageName = @"ttwidgetNone";
                }
        }
        
        NSString *imagePath = [[NSBundle mainBundle] pathForImageResource:imageName];
        NSString *innerHTML = [NSString stringWithFormat:@"<img src=\"%@\" style=\"width:100%%; height:100%%\"></imbc>", imagePath];
        
        [code addCodeLine:innerHTML];
    }
    
    [code addCodeLine:@"</div>"];

    return code;
}


- (JDCode *)htmlCodeAsIUCollectionView:(IUCollectionView *)collectionView target:(IUTarget)target attributeDict:(NSMutableDictionary *)attributeDict withCSS:(BOOL)withCSS {
    JDCode *code = [[JDCode alloc] init];
    
    if(target == IUTargetOutput){
        if (_compiler.rule == IUCompileRuleDjango ) {
            [code addCodeLineWithFormat:@"<div %@>", [self attributeString:attributeDict]];
            IUCollection *iuCollection = collectionView.collection;
            if(iuCollection){
                [code addCodeLineWithFormat:@"    {%% for object in %@ %%}", iuCollection.collectionVariable];
                [code addCodeLineWithFormat:@"        {%% include '%@.html' %%}", collectionView.prototypeClass.name];
                [code addCodeLine:@"    {% endfor %}"];
            }
            [code addCodeLineWithFormat:@"</div>"];
        }
        else {
            [code addCodeWithIndent:[self htmlCodeAsIUImport:collectionView target:target attributeDict:attributeDict withCSS:withCSS]];
        }
    }
    else if(target == IUTargetEditor){
        [code addCodeWithIndent:[self htmlCodeAsIUImport:collectionView target:target attributeDict:attributeDict withCSS:withCSS]];
    }
    
    return code;
}
- (JDCode *)htmlCodeAsIUImport:(IUImport *)import target:(IUTarget)target attributeDict:(NSMutableDictionary *)attributeDict withCSS:(BOOL)withCSS {
    JDCode *code = [[JDCode alloc] init];
    
    [code addCodeLineWithFormat:@"<div %@ >", [self attributeString:attributeDict]];

    
    if(target == IUTargetOutput){
        for (IUBox *child in import.children) {
            [self htmlCode:child target:target code:code withCSS:withCSS];
        }

    }
    else if(target == IUTargetEditor){
        //add prefix, <ImportedBy_[IUName]_ to all id html (including chilren)
        JDCode *importCode = [[JDCode alloc] init];
        [self htmlCode:import.prototypeClass target:target code:importCode withCSS:withCSS];
        NSString *idReplacementString = [NSString stringWithFormat:@" id=\"%@%@_",kIUImportEditorPrefix, import.htmlID];
        
        [importCode replaceCodeString:@" id=\"" toCodeString:idReplacementString];
        [code addCodeWithIndent:importCode];
    }
    
    [code addCodeLineWithFormat:@"</div>"];
    
    return code;
}


- (JDCode *)htmlCodeAsIUGoogleMap:(IUGoogleMap *)map target:(IUTarget)target attributeDict:(NSMutableDictionary *)attributeDict withCSS:(BOOL)withCSS {
    JDCode *code = [[JDCode alloc] init];
    if(target == IUTargetOutput){
        code = [self htmlCodeAsIUBox:map target:target attributeDict:attributeDict withCSS:withCSS];
    }
    else if(target == IUTargetEditor){
        [code addCodeLineWithFormat:@"<div %@ >", [self attributeString:attributeDict]];
        NSMutableString *mapImagePath = [NSMutableString stringWithString:@"http://maps.googleapis.com/maps/api/staticmap?"];
        if(map.currentApproximatePixelSize.width > 640 || map.currentApproximatePixelSize.height > 640){
            [mapImagePath appendString:@"scale=2"];
        }
        [mapImagePath appendFormat:@"&center=%@,%@",map.latitude, map.longitude];
        [mapImagePath appendFormat:@"&zoom=%ld", map.zoomLevel];
        
        [mapImagePath appendString:@"&size=640x640"];
        //marker
        if(map.enableMarkerIcon && map.markerIconName==nil ){
            [mapImagePath appendFormat:@"&markers=size=tiny|%@,%@",map.latitude, map.longitude];
        }
        //theme
        if(map.themeType != IUGoogleMapThemeTypeDefault){
            [mapImagePath appendString:map.innerCurrentThemeStyle];
        }
        
        //color
        //not supported in editor mode
        [code addCodeLineWithFormat:@"<div style=\"width:100%%;height:100%%;background-image:url('%@');background-position:center; background-repeat:no-repeat;position:absolute;", mapImagePath];
        if(map.currentApproximatePixelSize.width > 640 || map.currentApproximatePixelSize.height > 640){
            [code addCodeLine:@"background-size:cover"];
        }
        [code addCodeLine:@"\">"];
        
        //controller
        //pan
        if(map.panControl){
            NSString *imagePath = [[NSBundle mainBundle] pathForImageResource:@"map_position.png"];
            [code addCodeLineWithFormat:@"<img src=\"%@\" style=\"position:relative; margin-top:20px;left:20px;display:block\"></img>", imagePath];
        }
        //zoom
        if(map.zoomControl){
            NSString *imagePath = [[NSBundle mainBundle] pathForImageResource:@"map_zoom.png"];
            [code addCodeLineWithFormat:@"<img src=\"%@\" style=\"position:relative; margin-top:20px;left:35px;display:block;\"></img>", imagePath];
        }
        //marker icon
        if(map.markerIconName){
            NSString *imagePath = [_compiler imagePathWithImageName:map.markerIconName target:target forFilePath:IUFilePathHTML];
            [code addCodeLineWithFormat:@"<div style=\"background-image:url('%@'); \
             background-repeat:no-repeat; \
             background-position:center; \
             position:absolute;  width:100%%; height:100%%; \"></div>", imagePath];
            
        }
        [code addCodeLine:@"</div></div>"];
    }
    
    return code;
}

#pragma mark - Django widget

- (JDCode *)htmlCodeAsIUCollection:(IUCollection *)collection target:(IUTarget)target attributeDict:(NSMutableDictionary *)attributeDict withCSS:(BOOL)withCSS {
    JDCode *code = [[JDCode alloc] init];
    
    if(collection.responsiveSetting){
        NSData *data = [NSJSONSerialization dataWithJSONObject:collection.responsiveSetting options:0 error:nil];
        NSString *responsiveString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
        attributeDict[@"responsive"] = responsiveString;
        attributeDict[@"defaultItemCount"] = @(collection.defaultItemCount);
    }
    
    if(target == IUTargetOutput){
        if (_compiler.rule == IUCompileRuleDjango ) {
            [code addCodeLineWithFormat:@"<div %@>", [self attributeString:attributeDict]];
            [code addCodeLineWithFormat:@"    {%% for object in %@ %%}", collection.collectionVariable];
            [code addCodeLineWithFormat:@"        {%% include '%@.html' %%}", collection.prototypeClass.name];
            [code addCodeLine:@"    {% endfor %}"];
            [code addCodeLineWithFormat:@"</div>"];
        }
        else {
            [code addCodeWithIndent:[self htmlCodeAsIUImport:collection target:target attributeDict:attributeDict withCSS:withCSS]];
        }
        
    }
    else if(target == IUTargetEditor){
        code = [self htmlCodeAsIUImport:collection target:target attributeDict:attributeDict withCSS:withCSS];
    }
    
    return code;
}

- (JDCode *)htmlCodeAsPGPageLinkSet:(PGPageLinkSet *)pageLinkSet target:(IUTarget)target attributeDict:(NSMutableDictionary *)attributeDict withCSS:(BOOL)withCSS {
    JDCode *code = [[JDCode alloc] init];
    [code addCodeLineWithFormat:@"<div %@>", [self attributeString:attributeDict]];
    
    if(target == IUTargetOutput){
        NSString *linkStr;
        if([pageLinkSet.link isKindOfClass:[IUBox class]]){
            linkStr = [((IUBox *)pageLinkSet.link).htmlID lowercaseString];
        }
        
        if(linkStr){
            [code addCodeLine:@"    <div>"];
            [code addCodeLine:@"    <ul>"];
            [code addCodeLineWithFormat:@"{%%if %@_prev%%}", pageLinkSet.pageCountVariable];
            [code addCodeLineWithFormat:@"<a href=/%@/{{%@_prev}}><li>&#60;</li></a>",linkStr, pageLinkSet.pageCountVariable];
            [code addCodeLine:@"{% endif %}"];
            [code addCodeLineWithFormat:@"        {%% for i in %@ %%}", pageLinkSet.pageCountVariable];
              
            [code addCodeLineWithFormat:@"        <a href=/%@/{{i}}>", linkStr];
            [code addCodeLine:@"            <li> {{i}} </li>"];
            [code addCodeLine:@"        </a>"];
            
            [code addCodeLine:@"        {% endfor %}"];
            [code addCodeLineWithFormat:@"{%%if %@_next%%}", pageLinkSet.pageCountVariable];
            [code addCodeLineWithFormat:@"<a href=/%@/{{%@_next}}><li>&#62;</li></a>",linkStr, pageLinkSet.pageCountVariable];
            [code addCodeLine:@"{% endif %}"];
            [code addCodeLine:@"    </ul>"];
            [code addCodeLine:@"    </div>"];
        }
    }
    else if(target == IUTargetEditor){
        
        [code addCodeLine:@"    <div class='IUPageLinkSetClip'>"];
        [code addCodeLine:@"       <ul>"];
        [code addCodeLine:@"           <a><li>&#60;</li></a><a><li>1</li></a><a><li>2</li></a><a><li>3</li></a><a><li>&#62;</li></a>"];
        [code addCodeLine:@"       </ul>"];
        [code addCodeLine:@"    </div>"];
    }
    
    [code addCodeLine:@"</div>"];

    return code;
}

- (JDCode *)htmlCodeAsPGTextField:(PGTextField *)textfield target:(IUTarget)target attributeDict:(NSMutableDictionary *)attributeDict withCSS:(BOOL)withCSS {
    JDCode *code = [[JDCode alloc] init];
    
    if(textfield.inputName){
        attributeDict[@"name"] = textfield.inputName;
    }
    if(textfield.placeholder){
        attributeDict[@"placeholder"] = textfield.placeholder;
    }
    if(textfield.inputValue){
        attributeDict[@"value"] = textfield.inputValue;
    }
    if(textfield.type == IUTextFieldTypePassword){
        attributeDict[@"type"] = @"password";
    }
    else {
        attributeDict[@"type"] = @"text";
    }

    
    [code addCodeLineWithFormat:@"<input %@ >", [self attributeString:attributeDict]];
    
    
    return code;
}


- (JDCode *)htmlCodeAsPGTextView:(PGTextView *)textview target:(IUTarget)target attributeDict:(NSMutableDictionary *)attributeDict withCSS:(BOOL)withCSS {

    if(textview.placeholder){
        attributeDict[@"placeholder"] = textview.placeholder;
    }
    if(textview.inputName){
        attributeDict[@"name"] = textview.inputName;
    }

    
    JDCode *code = [[JDCode alloc] init];
    NSString *inputValue = [[textview inputValue] length] ? [textview inputValue] : @"";
    [code addCodeLineWithFormat:@"<textarea %@ >%@</textarea>", [self attributeString:attributeDict], inputValue];

    
    return code;
}
- (JDCode *)htmlCodeAsPGForm:(PGForm *)form target:(IUTarget)target attributeDict:(NSMutableDictionary *)attributeDict withCSS:(BOOL)withCSS {
    if(form.target){
        NSString *targetStr;
        if([form.target isKindOfClass:[NSString class]]){
            targetStr = form.target;
        }
        else if([form.target isKindOfClass:[IUBox class]]){
            targetStr = ((IUBox *)form.target).htmlID ;
        }
        
        attributeDict[@"action"] = targetStr;
    }
    
    attributeDict[@"method"] = @"post";
    
    JDCode *code = [[JDCode alloc] init];
    code = [self htmlCodeAsIUBox:form target:target attributeDict:attributeDict withCSS:withCSS];
    
    return code;
}

- (JDCode *)htmlCodeAsPGSubmitButton:(PGSubmitButton *)button target:(IUTarget)target attributeDict:(NSMutableDictionary *)attributeDict withCSS:(BOOL)withCSS {
    
    attributeDict[@"type"] = @"submit";
    attributeDict[@"value"] = button.label;

    JDCode *code = [[JDCode alloc] init];
    [code addCodeLineWithFormat:@"<input %@ >", [self attributeString:attributeDict]];

    return code;
}



/*
 - (JDCode *)htmlCodeAsIUBox:(IUBox *)iu type:(IUTarget)target attributeDict:(NSMutableDictionary *)attributeDict{
 JDCode *code = [[JDCode alloc] init];
 
 return code;
 }

 


- (JDCode *)htmlCodeAsWPPageLink:(WPPageLink *)wpPageLink target:(IUTarget)target attributeDict:(NSMutableDictionary *)attributeDict{
    return nil;
}
 */

/*
 If IU conforms IUSampleHTMLProtocol,
    If IU is responds sampleInnerHTML
 
 */

- (JDCode *)htmlCodeAsIUBox:(IUBox *)iu target:(IUTarget)target attributeDict:(NSMutableDictionary *)attributeDict withCSS:(BOOL)withCSS {
    JDCode *code = [[JDCode alloc] init];
    
    //TODO: WP
    //wp- to be removed
    if (target == IUTargetEditor && [iu conformsToProtocol:@protocol(IUSampleHTMLProtocol)]){
        IUBox <IUSampleHTMLProtocol> *sampleProtocolIU = (id)iu;
        if ([sampleProtocolIU respondsToSelector:@selector(sampleInnerHTML)]) {
            NSString *sampleInnerHTML = [sampleProtocolIU sampleInnerHTML];
            [code addCodeLineWithFormat:@"<div %@ >%@</div>", [self attributeString:attributeDict], sampleInnerHTML];
            for (IUBox *child in iu.children) {
                JDCode *childCode = [[JDCode alloc] init];
                [self htmlCode:child target:target code:childCode withCSS:withCSS];
                if (childCode) {
                    [code addCodeWithIndent:childCode];
                }
            }
        }
        else if ([sampleProtocolIU respondsToSelector:@selector(sampleHTML)]) {
            [code addCodeLine: sampleProtocolIU.sampleHTML];
        }
        else {
            assert(0);
        }
        return code;
    }
    
    NSString *tag = @"div";
    if ([iu isKindOfClass:[PGForm class]]) {
        tag = @"form";
    }
    else if (iu.textType == IUTextTypeH1){
        tag = @"h1";
    }
    else if (iu.textType == IUTextTypeH2){
        tag = @"h2";
    }
    
    
    //before tag
    if(target == IUTargetOutput){
        if ([iu.pgVisibleConditionVariable length] && _compiler.rule == IUCompileRuleDjango) {
            [code addCodeLineWithFormat:@"{%%if %@%%}", iu.pgVisibleConditionVariable];
        }
        
    }
    
    //open tag
    [code addCodeLineWithFormat:@"<%@ %@>", tag, [self attributeString:attributeDict]];
    
    if(target == IUTargetOutput){
        if (_compiler.rule == IUCompileRuleDjango && [iu isKindOfClass:[PGForm class]]) {
            [code addCodeLine:@"{% csrf_token %}"];
        }
        
        if (_compiler.rule == IUCompileRuleDjango && iu.pgContentVariable) {
            [code increaseIndentLevelForEdit];
            if ([iu.sheet isKindOfClass:[IUClass class]]) {
                [code addCodeLineWithFormat:@"<p>{{object.%@|linebreaksbr}}</p>", iu.pgContentVariable];
            }
            else {
                [code addCodeLineWithFormat:@"<p>{{%@|linebreaksbr}}</p>", iu.pgContentVariable];
            }
            [code decreaseIndentLevelForEdit];
            
        }
        //TODO: WP
        else if ([iu conformsToProtocol:@protocol(IUSampleHTMLProtocol)] && _compiler.rule == IUCompileRuleDefault){
            /* for example, WORDPRESS can be compiled as HTML */
            IUBox <IUSampleHTMLProtocol> *sampleProtocolIU = (id)iu;
            if ([sampleProtocolIU respondsToSelector:@selector(sampleInnerHTML)]) {
                NSString *sampleInnerHTML = [sampleProtocolIU sampleInnerHTML];
                [code addCodeWithFormat:sampleInnerHTML];
            }
            else if ([sampleProtocolIU respondsToSelector:@selector(sampleHTML)]) {
                [code setCodeString: sampleProtocolIU.sampleHTML];
            }
            else {
                assert(0);
            }
        }
        else if ([iu conformsToProtocol:@protocol(IUPHPCodeProtocol)] && _compiler.rule == IUCompileRuleWordpress){
            NSString *phpCode = [((IUBox <IUPHPCodeProtocol>*)iu) code];
            [code addCodeLine:phpCode];
        }
    }
    
    NSString *htmlText;
    if(iu.text && iu.text.length > 0
       && [iu conformsToProtocol:@protocol(IUPHPCodeProtocol)] == NO){
        htmlText = [iu.text stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
        htmlText = [htmlText stringByReplacingOccurrencesOfString:@"  " withString:@" &nbsp;"];
    }
    if(htmlText){
        if(IUTargetEditor == target ||
           (IUTargetOutput == target && iu.pgContentVariable == nil)){
            [code increaseIndentLevelForEdit];
            [code addCodeLineWithFormat:@"<p>%@</p>",htmlText];
            [code decreaseIndentLevelForEdit];

        }
    }
    if ([iu.mqData dictionaryForTag:IUMQDataTagInnerHTML].count == 1){
        NSString *innerHTML = [iu.mqData valueForTag:IUMQDataTagInnerHTML forViewport:IUCSSDefaultViewPort];
        if(innerHTML && innerHTML.length > 0){
            [code increaseIndentLevelForEdit];
            [code addCodeLine:innerHTML];
            [code decreaseIndentLevelForEdit];
        }
    }
    else if(target == IUTargetEditor){
        NSString *innerHTML = [iu.mqData effectiveValueForTag:IUMQDataTagInnerHTML forViewport:iu.mqData.editViewPort];
        if(innerHTML && innerHTML.length > 0){
            [code increaseIndentLevelForEdit];
            [code addCodeLine:innerHTML];
            [code decreaseIndentLevelForEdit];
        }

    }
    
    if (target == IUTargetEditor || ( target == IUTargetOutput && [iu shouldCompileChildrenForOutput] )) {
        for (IUBox *child in iu.children) {
            JDCode *childCode = [[JDCode alloc] init];
            [self htmlCode:child target:target code:childCode withCSS:withCSS];
            if (childCode) {
                [code addCodeWithIndent:childCode];
            }
        }
    }
    
    if (target == IUTargetOutput && [iu conformsToProtocol:@protocol(IUPHPCodeProtocol)] && _compiler.rule == IUCompileRuleWordpress) {
        if ([iu respondsToSelector:@selector(codeAfterChildren)]) {
            NSString *phpCode = [((IUBox <IUPHPCodeProtocol>*)iu) codeAfterChildren];
            [code addCodeLine:phpCode];
        }
    }
    
    
    [code addCodeLineWithFormat:@"</%@>", tag];
    if ([iu.pgVisibleConditionVariable length] && _compiler.rule == IUCompileRuleDjango) {
        [code addCodeLine:@"{% endif %}"];
    }
    
    
    return code;
}




@end
