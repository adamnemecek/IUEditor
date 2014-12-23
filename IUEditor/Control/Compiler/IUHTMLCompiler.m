//
//  IUHTMLCompiler.m
//  IUEditor
//
//  Created by seungmi on 2014. 9. 19..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUHTMLCompiler.h"


#define IUAttributeDict NSMutableArray
@interface IUAttributeDict(HTMLAttribute)
- (void)addAttribute:(NSString *)attribute value:(NSString *)value;
- (NSString *)attributeStringValue;
@end

@implementation IUAttributeDict(HTMLAttribute)

- (void)addAttribute:(NSString *)attribute value:(NSString *)value {
    [self addObject:@[attribute,value]];
}

- (NSString *)attributeStringValue {
    NSMutableString *str = [NSMutableString string];
    for (NSArray *attr in self) {
        [str appendFormat:@"%@=\"%@\" ", attr[0], attr[1]];
    }
    if ([str length]) {
        [str trim];
    }
    return [str copy];
}


@end

/**
 @param attributeArray @{@"key":key; @"value":NSString *} 를 가진 어레이. dictionary가 아닌 array 로 구현하는 이유는 order를 맞추기 위하여. <div xxx></div>에 xxx부분에 들어간다.
 */
@implementation IUHTMLCompiler

- (JDCode *)editorHTMLCode:(IUBox *)iu htmlIDPrefix:(NSString *)htmlIDPrefix rule:(NSString *)rule viewPort:(NSInteger)viewPort cssCodes:(NSDictionary *)codes {
    JDCode *code = [self htmlCode:iu htmlIDPrefix:htmlIDPrefix target:IUTargetEditor rule:rule viewPort:viewPort cssCodes:codes option:nil];
    return code;
}


- (JDCode *)outputHTMLCode:(IUBox *)iu htmlIDPrefix:(NSString *)htmlIDPrefix rule:(NSString *)rule cssCodes:(NSDictionary *)codes {
    return [self htmlCode:iu htmlIDPrefix:htmlIDPrefix target:IUTargetOutput rule:rule viewPort:0 cssCodes:codes option:nil];
}


/**
 실제로 JDCode를 만들어서 리턴하는 부분을 담당한다.
 @param viewPort 만약에 target이 output이라면 viewPort는 무시된다.
 @param option 추가적 정보 option. 일단은 RFU
 */
- (JDCode *)htmlCode:(IUBox *)iu htmlIDPrefix:(NSString *)HTMLIDPrefix target:(IUTarget)target rule:(NSString*)rule viewPort:(NSInteger)viewPort cssCodes:(NSDictionary *)cssCodes option:(NSDictionary *)option{
    NSArray *classPedigree = [[iu class] classPedigreeTo:[IUBox class]];
    
    //find function and make source
    for (NSString *className in classPedigree) {
        NSString *str = [NSString stringWithFormat:@"htmlCodeAs%@:htmlIDPrefix:target:rule:viewPort:attributeDict:cssCodes:option:", className];
        SEL selector = NSSelectorFromString(str);
        
        if ([self respondsToSelector:selector]) {
            //call widget html
            IMP imp = [self methodForSelector:selector];
            IUCSSCode *cssCode = cssCodes[iu.htmlID];
            NSAssert(cssCode != nil, @"code is nil");
            NSString *cssStyle = [cssCode stringCodeWithMainIdentifieForTarget:target viewPort:viewPort];
            IUAttributeDict *attrDict = [self defaultAttributes:iu htmlIDPrefix:HTMLIDPrefix rule:rule target:target viewPort:viewPort style:cssStyle];
            
            JDCode *(*func)(id, SEL, IUBox *, NSString*, IUTarget, NSString *,  NSInteger, IUAttributeDict *, NSDictionary *, NSMutableDictionary *) = (void *)imp;
            JDCode *code = func(self, selector, iu, HTMLIDPrefix, target, rule, viewPort, attrDict, cssCodes, nil);
            
            //add link
            //나중에 코딩.
            /*
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
             */
            
            return code;
        }
    }
    NSAssert(0, @"should not come to here");
    return nil;
}

-(IUAttributeDict *)defaultAttributes:(IUBox *)iu htmlIDPrefix:(NSString *)htmlIDPrefix rule:(NSString *)rule target:(IUTarget)target viewPort:(NSInteger)viewPort style:(NSString *)style{
    IUAttributeDict *attrDict = [[IUAttributeDict alloc] init];
    
    // make path
    if (htmlIDPrefix) {
        [attrDict addAttribute:@"id" value:[htmlIDPrefix stringByAppendingString:iu.htmlID]];
    }
    else {
        [attrDict addAttribute:@"id" value:iu.htmlID];
    }
    
    [attrDict addAttribute:@"class" value:[self htmlClassForIU:iu target:target]];
    
    if(iu.enableHCenter){
        [attrDict addAttribute:@"horizontalCenter" value:@"1"];
    }
    if(iu.enableVCenter){
        [attrDict addAttribute:@"verticalCenter" value:@"1"];
    }
    
    //target별 attribute
    /*
    if (target == IUTargetOutput){
        //active class를 add 하기 위한 attribute
        if(iu.link && [self hasLink:iu] && [iu.link isKindOfClass:[IUBox class]]
           //image class는 a tag가 바깥으로 붙고, active상태를 이용하지 않음.
           && [iu isKindOfClass:[IUImage class]] == NO){
            
            [attributeDict setObject:@"1" forKey:@"iulink"];
        }
        if(iu.linkCaller){
            [attributeDict setObject:[NSNull null] forKey:@"iudivlink"];
            [attributeDict setObject:((IUBox *)iu.linkCaller).htmlID forKey:@"linkcaller"];
        }
    }
     */
    
    if (target == IUTargetEditor && style) {
        [attrDict addAttribute:@"style" value:style];
    }
    return attrDict;
}


- (JDCode *)htmlCodeAsIUBox:(IUBox *)iu htmlIDPrefix:(NSString *)htmlIDPrefix target:(IUTarget)target rule:(NSString *)rule viewPort:(NSInteger)viewPort attributeDict:(IUAttributeDict *)dict cssCodes:(NSDictionary *)cssCodes option:(NSMutableDictionary *)option {
    JDCode *code = [[JDCode alloc] initWithCodeString:[NSString stringWithFormat:@"<div %@>", dict.attributeStringValue]];
    
    
    if(target == IUTargetOutput){
        NSAssert(0, @"not yet coded");
#if 0
        //TODO: WP
        if ([iu conformsToProtocol:@protocol(IUSampleHTMLProtocol)] && _compiler.rule == IUCompileRuleDefault){
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
#endif
    }
    if (target == IUTargetEditor || ( target == IUTargetOutput && [iu shouldCompileChildrenForOutput] )) {
        for (IUBox *child in iu.children) {
            JDCode *childCode = [self htmlCode:child htmlIDPrefix:htmlIDPrefix target:target rule:rule viewPort:viewPort cssCodes:cssCodes option:nil];
            if (childCode) {
                [code addCodeWithIndent:childCode];
            }
        }
    }
    /*
    
    if (target == IUTargetOutput && [iu conformsToProtocol:@protocol(IUPHPCodeProtocol)] && _compiler.rule == IUCompileRuleWordpress) {
        if ([iu respondsToSelector:@selector(codeAfterChildren)]) {
            NSString *phpCode = [((IUBox <IUPHPCodeProtocol>*)iu) codeAfterChildren];
            [code addCodeLine:phpCode];
        }
    }
    */
    
    [code addCodeLine:@"</div>"];
    /*
    if ([iu.pgVisibleConditionVariable length] && _compiler.rule == IUCompileRuleDjango) {
        [code addCodeLine:@"{% endif %}"];
    }
     */
    
    
    return code;
}





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
        /*
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
         */
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
        /*
        }
         */
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


-(NSString *)htmlClassForIU:(IUBox *)iu target:(IUTarget)target{
    NSMutableString *classString = [NSMutableString stringWithFormat:@"%@ ", iu.htmlID];
    NSArray *classPedigree = [[iu class] classPedigreeTo:[IUBox class]];
    for (NSString *className in classPedigree) {
        [classString appendFormat:@"%@ ", className];
    }

#pragma mark IUCarouselItem
    if([iu isKindOfClass:[IUCarouselItem class]]){
        if(target == IUTargetEditor && ((IUCarouselItem *)iu).isActive){
            [classString appendString:@"active "];
        }
    }
#pragma mark IUMenuBar, IUMenuItem
    else if([iu isKindOfClass:[IUMenuBar class]] ||
            [iu isKindOfClass:[IUMenuItem class]]){
        if(iu.children.count >0){
            [classString appendString:@"has-sub "];
        }
        
        if([iu isKindOfClass:[IUMenuBar class]]){
            IUMenuBar *menuBar = (IUMenuBar *)iu;
            if(menuBar.align == IUMenuBarAlignRight){
                [classString appendString:@"align-right "];
            }
        }
    }
    [classString trim];
    return [classString copy];
}




#pragma mark - layout widget
- (JDCode *)htmlCodeAsIUSidebar:(IUSidebar *)iu htmlIDPrefix:(NSString *)htmlIDPrefix target:(IUTarget)target rule:(NSString *)rule viewPort:(NSInteger)viewPort attributeDict:(IUAttributeDict *)attributeDict  cssCodes:(NSDictionary *)cssCodes option:(NSMutableDictionary *)option {
    
    [attributeDict addAttribute:@"sidebarType" value:[@(iu.type) stringValue]];
    JDCode *code = [self htmlCodeAsIUBox:iu htmlIDPrefix:htmlIDPrefix target:target rule:rule viewPort:viewPort attributeDict:attributeDict cssCodes:cssCodes option:option];
    return code;
}

- (JDCode *)htmlCodeAsIUSection:(IUSection *)section htmlIDPrefix:(NSString *)htmlIDPrefix target:(IUTarget)target rule:(NSString *)rule viewPort:(NSInteger)viewPort attributeDict:(IUAttributeDict *)attributeDict  cssCodes:(NSDictionary *)cssCodes option:(NSMutableDictionary *)option {
    if(target == IUTargetOutput && section.enableFullSize){
        [attributeDict addAttribute:@"enableFullSize" value:@"1"];
    }
    JDCode *code = [self htmlCodeAsIUBox:section htmlIDPrefix:htmlIDPrefix target:target rule:rule viewPort:viewPort attributeDict:attributeDict cssCodes:cssCodes option:option];
    
    return code;
}

#pragma mark - default widget

- (JDCode *)htmlCodeAsIUTransition:(IUTransition *)transition htmlIDPrefix:(NSString *)htmlIDPrefix target:(IUTarget)target rule:(NSString *)rule viewPort:(NSInteger)viewPort attributeDict:(IUAttributeDict *)attributeDict  cssCodes:(NSDictionary *)cssCodes option:(NSMutableDictionary *)option {
    if ([transition.eventType length]) {
        if ([transition.eventType isEqualToString:kIUTransitionEventClick]) {
            [attributeDict addAttribute:@"transitionEvent" value:@"click"];
        }
        else if ([transition.eventType isEqualToString:kIUTransitionEventMouseOn]){
            [attributeDict addAttribute:@"transitionEvent" value:@"mouseOn"];
        }
        else {
            NSAssert(0, @"Missing Code");
        }
        float duration = transition.duration;
        if(duration < 1){
            [attributeDict addAttribute:@"transitionDuration" value:@"0"];
        }
        else{
            [attributeDict addAttribute:@"transitionDuration" value:[@(duration*1000) stringValue]];
        }
    }
    if ([transition.animation length]) {
        [attributeDict addAttribute:@"transitionAnimation" value:[transition.animation lowercaseString]];
    }
    
    
    JDCode *code = [self htmlCodeAsIUBox:transition htmlIDPrefix:htmlIDPrefix target:target rule:rule viewPort:viewPort attributeDict:attributeDict cssCodes:cssCodes option:option];
 
    return code;
}


- (JDCode *)htmlCodeAsIUMenuBar:(IUMenuBar *)menuBar htmlIDPrefix:(NSString *)htmlIDPrefix target:(IUTarget)target rule:(NSString *)rule viewPort:(NSInteger)viewPort attributeDict:(IUAttributeDict *)attributeDict  cssCodes:(NSDictionary *)cssCodes option:(NSMutableDictionary *)option {
    JDCode *code = [[JDCode alloc] init];
    [code addCodeLineWithFormat:@"<div %@>", attributeDict.attributeStringValue];
    NSString *title = menuBar.mobileTitle;
    if(title == nil){
        title = @"MENU";
    }
    [code addCodeLineWithFormat:@"<div class=\"mobile-button\">%@<div class='menu-top'></div><div class='menu-bottom'></div></div>", title];

    
    if(menuBar.children.count > 0){
        [code increaseIndentLevelForEdit];
        [code addCodeLine:@"<ul>"];
        
        for (IUBox *child in menuBar.children){
            [self htmlCode:child htmlIDPrefix:htmlIDPrefix target:target rule:rule viewPort:viewPort cssCodes:cssCodes option:option];
        }
        [code addCodeLine:@"</ul>"];
        [code decreaseIndentLevelForEdit];
    }
    
    [code addCodeLine:@"</div>"];
    return code;
}

- (JDCode *)htmlCodeAsIUMenuItem:(IUMenuItem *)menuItem htmlIDPrefix:(NSString *)htmlIDPrefix target:(IUTarget)target rule:(NSString *)rule viewPort:(NSInteger)viewPort attributeDict:(IUAttributeDict *)attributeDict  cssCodes:(NSDictionary *)cssCodes option:(NSMutableDictionary *)option {
    JDCode *code = [[JDCode alloc] init];
    
    [code addCodeLineWithFormat:@"<li %@>", attributeDict.attributeStringValue];
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
            JDCode *childCode = [self htmlCode:child htmlIDPrefix:htmlIDPrefix target:target rule:rule viewPort:viewPort cssCodes:cssCodes option:nil];
            [code addCode:childCode];
        }
        [code addCodeLine:@"</ul>"];
    }
    
    [code decreaseIndentLevelForEdit];
    [code addCodeLine:@"</li>"];
    return code;
}

- (JDCode *)htmlCodeAsIUCarousel:(IUCarousel *)carousel htmlIDPrefix:(NSString *)htmlIDPrefix target:(IUTarget)target rule:(NSString *)rule viewPort:(NSInteger)viewPort attributeDict:(IUAttributeDict *)attributeDict  cssCodes:(NSDictionary *)cssCodes option:(NSMutableDictionary *)option {
    JDCode *code = [[JDCode alloc] init];
    
    if(target == IUTargetEditor){
        [code addCodeLineWithFormat:@"<div %@>", attributeDict.attributeStringValue];
        //carousel item
        for(IUCarouselItem *item in carousel.children){
            JDCode *childCode = [self htmlCode:item htmlIDPrefix:htmlIDPrefix target:target rule:rule viewPort:viewPort cssCodes:cssCodes option:nil];
            [code addCode:childCode];
        }
    }
    else if(target == IUTargetOutput){
        if(carousel.autoplay && carousel.timer > 0){
            [attributeDict addAttribute:@"timer" value:[@(carousel.timer *1000) stringValue]];
        }
        
        [code addCodeLineWithFormat:@"<div %@>", attributeDict.attributeStringValue];
        
        //carousel item
        [code addCodeLineWithFormat:@"<div class='wrapper' id='wrapper_%@'>", carousel.htmlID];
        for(IUItem *item in carousel.children){
            JDCode *childCode = [self htmlCode:item htmlIDPrefix:htmlIDPrefix target:target rule:rule viewPort:viewPort cssCodes:cssCodes option:nil];
            [code addCode:childCode];
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
- (JDCode *)htmlCodeAsIUText:(IUText *)textIU htmlIDPrefix:(NSString *)htmlIDPrefix target:(IUTarget)target rule:(NSString *)rule viewPort:(NSInteger)viewPort attributeDict:(IUAttributeDict *)attributeDict  cssCodes:(NSDictionary *)cssCodes option:(NSMutableDictionary *)option{
    JDCode *code = [[JDCode alloc] init];
    
    NSString *tag  = @"div";
    
    if (textIU.textType == IUTextTypeH1){
        tag = @"h1";
    }
    else if (textIU.textType == IUTextTypeH2){
        tag = @"h2";
    }

    
    
    //before tag
    if(target == IUTargetOutput){
        /*
        if ([textIU.pgVisibleConditionVariable length] && rule == @"django") {
            [code addCodeLineWithFormat:@"{%%if %@%%}", textIU.pgVisibleConditionVariable];
        }
         */
    }
    
    //open tag
    [code addCodeLineWithFormat:@"<%@ %@>", tag, attributeDict.attributeStringValue];
    
    if(target == IUTargetOutput){
        /*
        if (_compiler.rule == IUCompileRuleDjango && textIU.pgContentVariable) {
            [code increaseIndentLevelForEdit];
            if ([textIU.sheet isKindOfClass:[IUClass class]]) {
                [code addCodeLineWithFormat:@"<p>{{object.%@|linebreaksbr}}</p>", textIU.pgContentVariable];
            }
            else {
                [code addCodeLineWithFormat:@"<p>{{%@|linebreaksbr}}</p>", textIU.pgContentVariable];
            }
            [code decreaseIndentLevelForEdit];
            
        }
         */
    }
    
    NSString *htmlText;
    if(htmlText){
        if(IUTargetEditor == target ||
           (IUTargetOutput == target && textIU.pgContentVariable == nil)){
            [code increaseIndentLevelForEdit];
            [code addCodeLineWithFormat:@"<p>%@</p>",htmlText];
            [code decreaseIndentLevelForEdit];
            
        }
    }
    if(textIU.propertyManager){
        /*
         IU has only one innerHTML
         */
        if([textIU.propertyManager countOfValueForKey:@"innerHTML"] == 1){
            IUPropertyStorage *propertyStorage = (IUPropertyStorage *)[textIU.propertyManager storageForViewPort:viewPort];
            if(propertyStorage.innerHTML && propertyStorage.innerHTML.length > 0){
                [code increaseIndentLevelForEdit];
                [code addCodeLine:propertyStorage.innerHTML];
                [code decreaseIndentLevelForEdit];
            }
        }
        /*
         if IU has multiple inner html, this goes to javascript
         */
        else if(target == IUTargetEditor){
            /* following code assumes propertyManager.currentViewPort should be equal parameter viewPort */
            NSAssert(viewPort == textIU.propertyManager.currentViewPort, @"not equal");
            
            if(textIU.cascadingPropertyStorage.innerHTML && textIU.cascadingPropertyStorage.innerHTML.length > 0){
                [code increaseIndentLevelForEdit];
                [code addCodeLine:textIU.currentPropertyStorage.innerHTML];
                [code decreaseIndentLevelForEdit];
            }
        }
        
    }
    
    [code addCodeLineWithFormat:@"</%@>", tag];
    /*
    if ([textIU.pgVisibleConditionVariable length] && _compiler.rule == IUCompileRuleDjango) {
        [code addCodeLine:@"{% endif %}"];
    }
     */
    return code;

}
- (JDCode *)htmlCodeAsIUImage:(IUImage *)image htmlIDPrefix:(NSString *)htmlIDPrefix target:(IUTarget)target rule:(NSString *)rule viewPort:(NSInteger)viewPort attributeDict:(IUAttributeDict *)attributeDict  cssCodes:(NSDictionary *)cssCodes option:(NSMutableDictionary *)option {
    /*
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
            NSString *imgSrc = [_compiler imagePathWithImageName:image.imageName target:target];
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
     */
    if (target == IUTargetEditor) {
        if(image.imagePath){
            if (_editorResourcePrefix) {
                [attributeDict addAttribute:@"src" value:[_editorResourcePrefix stringByAppendingPathComponent:image.imagePath]];
            }
            else {
                [attributeDict addAttribute:@"src" value:image.imagePath];
            }
        }
        else{
            NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"image_default" ofType:@"png"];
            [attributeDict addAttribute:@"src" value:imagePath];
        }
    }
    else {
        if (_outputResourcePrefix) {
            [attributeDict addAttribute:@"src" value:[_outputResourcePrefix stringByAppendingPathComponent:image.imagePath]];
        }
        else {
            [attributeDict addAttribute:@"src" value:image.imagePath];
        }
    }
    if(image.altText){
        [attributeDict addAttribute:@"alt" value:image.altText];
    }
    
    JDCode *code = [[JDCode alloc] initWithCodeString:[NSString stringWithFormat:@"<img %@>", attributeDict.attributeStringValue]];
    return code;
}


- (JDCode *)htmlCodeAsIUMovie:(IUMovie *)movie htmlIDPrefix:(NSString *)htmlIDPrefix target:(IUTarget)target rule:(NSString *)rule viewPort:(NSInteger)viewPort attributeDict:(IUAttributeDict *)attributeDict  cssCodes:(NSDictionary *)cssCodes option:(NSMutableDictionary *)option{
    /*
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
     */
    return nil;
}

- (JDCode *)htmlCodeAsIUWebMovie:(IUWebMovie *)webmovie htmlIDPrefix:(NSString *)htmlIDPrefix target:(IUTarget)target rule:(NSString *)rule viewPort:(NSInteger)viewPort attributeDict:(IUAttributeDict *)attributeDict  cssCodes:(NSDictionary *)cssCodes option:(NSMutableDictionary *)option{
    /*
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
     */
    return nil;
}

/* IUHTML does not have children */
- (JDCode *)htmlCodeAsIUHTML:(IUHTML *)html htmlIDPrefix:(NSString *)htmlIDPrefix target:(IUTarget)target rule:(NSString *)rule viewPort:(NSInteger)viewPort attributeDict:(IUAttributeDict *)attributeDict  cssCodes:(NSDictionary *)cssCodes option:(NSMutableDictionary *)option{

    JDCode *code = [[JDCode alloc] init];
    
    [code addCodeLineWithFormat:@"<div %@>", attributeDict.attributeStringValue];
    if(html.hasInnerHTML){
        [code addCodeLine:html.innerHTML];
    }
    [code addCodeLineWithFormat:@"</div>"];
    return code;
}


- (JDCode *)htmlCodeAsIUFBLike:(IUFBLike *)fblike htmlIDPrefix:(NSString *)htmlIDPrefix target:(IUTarget)target rule:(NSString *)rule viewPort:(NSInteger)viewPort attributeDict:(IUAttributeDict *)attributeDict  cssCodes:(NSDictionary *)cssCodes option:(NSMutableDictionary *)option{
    
    if (target == IUTargetOutput){
        return [self htmlCodeAsIUHTML:fblike htmlIDPrefix:htmlIDPrefix target:target rule:rule viewPort:viewPort attributeDict:attributeDict cssCodes:cssCodes option:nil];
    }
    else {
        JDCode *code = [[JDCode alloc] init];
        [code addCodeLineWithFormat:@"<div %@ >", attributeDict.attributeStringValue];
        
        NSString *fbPath = [[NSBundle mainBundle] pathForResource:@"FBSampleImage" ofType:@"png"];
        NSString *editorHTML = [NSString stringWithFormat:@"<img src=\"%@\" align=\"middle\" style=\"float:left;margin:0 5px 0 0; \" ><p style=\"font-size:11px ; font-family:'Helvetica Neue', Helvetica, Arial, 'lucida grande',tahoma,verdana,arial,sans-serif\">263,929 people like this. Be the first of your friends.</p>", fbPath];
        
        [code addCodeLine:editorHTML];
        [code addCodeLine:@"</div>"];
        return code;
    }
}

- (JDCode *)htmlCodeAsIUTweetButton:(IUTweetButton *)tweet htmlIDPrefix:(NSString *)htmlIDPrefix target:(IUTarget)target rule:(NSString *)rule viewPort:(NSInteger)viewPort attributeDict:(IUAttributeDict *)attributeDict  cssCodes:(NSDictionary *)cssCodes option:(NSMutableDictionary *)option{
    /*
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
     */
    return nil;
}


- (JDCode *)htmlCodeAsIUCollectionView:(IUCollectionView *)collectionView htmlIDPrefix:(NSString *)htmlIDPrefix target:(IUTarget)target rule:(NSString *)rule viewPort:(NSInteger)viewPort attributeDict:(IUAttributeDict *)attributeDict  cssCodes:(NSDictionary *)cssCodes option:(NSMutableDictionary *)option{
    /*
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
            [code addCodeWithIndent:[self htmlCodeAsIUImport:collectionView target:target attributeDict:attributeDict  viewPort:viewPort option:nil]];
        }
    }
    else if(target == IUTargetEditor){
        [code addCodeWithIndent:[self htmlCodeAsIUImport:collectionView target:target attributeDict:attributeDict  viewPort:viewPort option:nil]];
    }
    
    return code;
     */
    return nil;
}


- (JDCode *)htmlCodeAsIUGoogleMap:(IUGoogleMap *)map htmlIDPrefix:(NSString *)htmlIDPrefix target:(IUTarget)target rule:(NSString *)rule viewPort:(NSInteger)viewPort attributeDict:(IUAttributeDict *)attributeDict  cssCodes:(NSDictionary *)cssCodes option:(NSMutableDictionary *)option{
    /*
    JDCode *code = [[JDCode alloc] init];
    if(target == IUTargetOutput){
        code = [self htmlCodeAsIUBox:map target:target attributeDict:attributeDict  viewPort:viewPort option:nil];
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
            NSString *imagePath = [_compiler imagePathWithImageName:map.markerIconName target:target];
            [code addCodeLineWithFormat:@"<div style=\"background-image:url('%@'); \
             background-repeat:no-repeat; \
             background-position:center; \
             position:absolute;  width:100%%; height:100%%; \"></div>", imagePath];
            
        }
        [code addCodeLine:@"</div></div>"];
    }
    
    return code;
     */
    return nil;
}

#pragma mark - Django widget

- (JDCode *)htmlCodeAsIUCollection:(IUCollection *)collection htmlIDPrefix:(NSString *)htmlIDPrefix target:(IUTarget)target rule:(NSString *)rule viewPort:(NSInteger)viewPort attributeDict:(IUAttributeDict *)attributeDict  cssCodes:(NSDictionary *)cssCodes option:(NSMutableDictionary *)option{
    /*
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
            [code addCodeWithIndent:[self htmlCodeAsIUImport:collection target:target attributeDict:attributeDict  viewPort:viewPort option:nil]];
        }
        
    }
    else if(target == IUTargetEditor){
        code = [self htmlCodeAsIUImport:collection target:target attributeDict:attributeDict  viewPort:viewPort option:nil];
    }
    
    return code;
     */
    return nil;
}

- (JDCode *)htmlCodeAsPGPageLinkSet:(PGPageLinkSet *)pageLinkSet htmlIDPrefix:(NSString *)htmlIDPrefix target:(IUTarget)target rule:(NSString *)rule viewPort:(NSInteger)viewPort attributeDict:(IUAttributeDict *)attributeDict  cssCodes:(NSDictionary *)cssCodes option:(NSMutableDictionary *)option{
    /*
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
     */
    return nil;
}

- (JDCode *)htmlCodeAsPGTextField:(PGTextField *)textfield htmlIDPrefix:(NSString *)htmlIDPrefix target:(IUTarget)target rule:(NSString *)rule viewPort:(NSInteger)viewPort attributeDict:(IUAttributeDict *)attributeDict  cssCodes:(NSDictionary *)cssCodes option:(NSMutableDictionary *)option{
    /*
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
     */
    return nil;
}



- (JDCode *)htmlCodeAsPGTextView:(PGTextView *)textview  htmlIDPrefix:(NSString *)htmlIDPrefix target:(IUTarget)target rule:(NSString *)rule viewPort:(NSInteger)viewPort attributeDict:(IUAttributeDict *)attributeDict  cssCodes:(NSDictionary *)cssCodes option:(NSMutableDictionary *)option {
    if(textview.placeholder){
        [attributeDict addAttribute:@"placeholder" value:textview.placeholder];
    }
    if(textview.inputName){
        [attributeDict addAttribute:@"name" value:textview.inputName];
    }

    
    JDCode *code = [[JDCode alloc] init];
    NSString *inputValue = [[textview inputValue] length] ? [textview inputValue] : @"";
    [code addCodeLineWithFormat:@"<textarea %@ >%@</textarea>", attributeDict.attributeStringValue, inputValue];

    
    return code;
}

- (JDCode *)htmlCodeAsPGForm:(PGForm *)form htmlIDPrefix:(NSString *)htmlIDPrefix target:(IUTarget)target rule:(NSString *)rule viewPort:(NSInteger)viewPort attributeDict:(IUAttributeDict *)attributeDict  cssCodes:(NSDictionary *)cssCodes option:(NSMutableDictionary *)option{
    if(form.target){
        if([form.target isKindOfClass:[NSString class]]){
            [attributeDict addAttribute:@"action" value:form.target];
        }
        else if([form.target isKindOfClass:[IUBox class]]){
            [attributeDict addAttribute:@"action" value:((IUBox *)form.target).htmlID];
        }
    }
    
    [attributeDict addAttribute:@"method" value:@"post"];
    
    JDCode *code = [[JDCode alloc] init];
    
    //open tag
    [code addCodeLineWithFormat:@"<form %@>", attributeDict.attributeStringValue];
    
    for (IUBox *child in form.children) {
        JDCode *childCode = [self htmlCode:child htmlIDPrefix:htmlIDPrefix target:target rule:rule viewPort:viewPort cssCodes:cssCodes option:option];
        if (childCode) {
            [code addCodeWithIndent:childCode];
        }
    }
    
    [code addCodeLine:@"</form>"];
    
    return code;
}

- (JDCode *)htmlCodeAsPGSubmitButton:(PGSubmitButton *)button htmlIDPrefix:(NSString *)htmlIDPrefix target:(IUTarget)target rule:(NSString *)rule viewPort:(NSInteger)viewPort attributeDict:(IUAttributeDict *)attributeDict  cssCodes:(NSDictionary *)cssCodes option:(NSMutableDictionary *)option {

    [attributeDict addAttribute:@"type" value:@"submit"];
    if (button.label) {
        [attributeDict addAttribute:@"value" value:button.label];
    }
    
    JDCode *code = [[JDCode alloc] init];
    [code addCodeLineWithFormat:@"<input %@ >", attributeDict.attributeStringValue];

    return code;
}



@end
