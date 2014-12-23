//
//  IUCSSCompiler.m
//  IUEditor
//
//  Created by jd on 2014. 8. 4..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUCSSCompiler.h"
#import "IUCSSBaseCompiler.h"


#import "IUFontController.h"
#import "IUCSS.h"
#import "IUProject.h"

#import "IUSection.h"
#import "IUHeader.h"
#import "IUFooter.h"

#import "PGPageLinkSet.h"
#import "IUMenuBar.h"
#import "IUMenuItem.h"
#import "IUCarousel.h"
#import "PGTextView.h"
#import "IUPageContent.h"

#import "WPMenu.h"

#import "WPSidebar.h"
#import "WPWidget.h"
#import "WPWidgetTitle.h"
#import "WPWidgetBody.h"

#import "WPPageLinks.h"
#import "WPPageLink.h"

#import "IUDataStorage.h"



@implementation IUCSSCompiler {
    IUCSSBaseCompiler *_baseCompiler;
}

- (id)init {
    self = [super init];
    _baseCompiler = [[IUCSSBaseCompiler alloc] init];
    return self;
}
- (void)setEditorResourcePrefix:(NSString *)editorResourcePrefix{
    _editorResourcePrefix = editorResourcePrefix;
    [_baseCompiler setEditorResourcePrefix:editorResourcePrefix];
}
- (void)setOutputResourcePrefix:(NSString *)outputResourcePrefix{
    _outputResourcePrefix = outputResourcePrefix;
    [_baseCompiler setEditorResourcePrefix:outputResourcePrefix];
}

- (IUCSSCode*)cssCodeForIU:(IUBox*)iu rule:(NSString*)rule target:(IUTarget)target viewPort:(NSInteger)viewPort option:(NSDictionary *)option {
    NSArray *classPedigree = [[iu class] classPedigreeTo:[IUBox class]].reversedArray;
    for (NSString *className in classPedigree) {
        NSString *str = [NSString stringWithFormat:@"cssCodeFor%@:rule:target:viewPort:option:", className];
        SEL selector = NSSelectorFromString(str);
        if ([self respondsToSelector:selector]) {
            IMP imp = [self methodForSelector:selector];
            IUCSSCode *(*func)(id, SEL, IUBox*, NSString*, IUTarget, NSInteger, NSDictionary*) = (void *)imp;
            IUCSSCode *code = func(self, selector, iu, rule, target, viewPort, option);
            return code;
        }
    }
    return nil;
}

- (IUCSSCode *)cssCodeForIUBox:(IUBox *)iu rule:(NSString *)rule target:(IUTarget)target viewPort:(NSInteger)viewPort option:(NSDictionary *)option {
    return [_baseCompiler cssCodeForIUBox:iu target:target viewPort:viewPort option:option];
}

- (IUCSSCode *)cssCodeForIUSection:(IUSection *)iu rule:(NSString *)rule target:(IUTarget)target viewPort:(NSInteger)viewPort option:(NSDictionary *)option {
    IUCSSCode *code = [self cssCodeForIUBox:iu rule:rule target:target viewPort:viewPort option:option];
    if(iu.heightAsWindowHeight && target==IUTargetEditor){
        [code setInsertingIdentifier:code.mainIdentifier];
        [code insertTag:@"height" number:@(720) unit:IUUnitPixel];
    }
    return code;
}

- (IUCSSCode *)cssCodeForIUMenuBar:(IUMenuBar *)iu rule:(NSString *)rule target:(IUTarget)target viewPort:(NSInteger)viewPort option:(NSDictionary *)option {
    NSAssert(0, @"not yet coded");
    IUCSSCode *code = [self cssCodeForIUBox:iu rule:rule target:target viewPort:viewPort option:option];
    
    if (target == IUTargetEditor) {
        [code setInsertingIdentifier:code.mainIdentifier];
        [code setInsertingTarget:target];
        [code setInsertingViewPort:viewPort];
        
        
    }
    return code;
}

- (void)updateCSSCode:(IUCSSCode*)code asIUMenuBar:(IUMenuBar*)menuBar{
    NSAssert(0, @"not yet coded");
    NSArray *editWidths = [menuBar.defaultStyleManager allViewPorts];
    for (NSNumber *viewportNumber in editWidths) {
        int viewport = [viewportNumber intValue];
        [code setInsertingViewPort:viewport];
        
        IUStyleStorage *styleStorage = (IUStyleStorage *)[menuBar.defaultStyleManager storageForViewPort:viewport];
        int height = [styleStorage.height intValue];

        [code setInsertingTarget:IUTargetBoth];
        if(viewport < IUMobileSize){
            
            
            if(height > 10){
                //mobile
                [code setInsertingIdentifier:menuBar.mobileButtonIdentifier withType:IUCSSIdentifierTypeNonInline];
                [code insertTag:@"line-height" number:@(height) unit:IUUnitPixel];
                [code insertTag:@"color" color:menuBar.mobileTitleColor];
                
                
                //mobile-menu
                [code setInsertingIdentifier:menuBar.topButtonIdentifier withType:IUCSSIdentifierTypeNonInline];
                int top = (height -10)/2;
                [code insertTag:@"top" number:@(top) unit:IUUnitPixel];
                [code insertTag:@"border-color" color:menuBar.iconColor];
                
                [code setInsertingIdentifier:menuBar.bottomButtonIdentifier withType:IUCSSIdentifierTypeNonInline];
                top =(height -10)/2 +10;
                [code insertTag:@"top" number:@(top) unit:IUUnitPixel];
                [code insertTag:@"border-color" color:menuBar.iconColor];
            }
            
            //editormode
            [code setInsertingIdentifier:menuBar.editorDisplayIdentifier withType:IUCSSIdentifierTypeNonInline];
            [code setInsertingTarget:IUTargetEditor];
            
            if(menuBar.isOpened){
                [code insertTag:@"display" string:@"block"];
            }
            else{
                [code insertTag:@"display" string:@"none"];
            }
            
        }
        
    }

    [code removeTag:@"width" identifier:menuBar.cssIdentifier viewport:menuBar.project.maxViewPort];
    
}

- (void)updateCSSCode:(IUCSSCode*)code asIUMenuItem:(IUMenuItem*)menuItem{

    NSMutableArray *editWidths = [menuItem.project.viewPorts mutableCopy];
    
    for (NSNumber *viewportNumber in editWidths) {
        int viewport = [viewportNumber intValue];
        [code setInsertingViewPort:viewport];
        
        //css identifier
        [code setInsertingIdentifier:[menuItem cssIdentifier]];
        [code setInsertingTarget:IUTargetBoth];
        
        
        //find appropriate height for depth
        id value;
        if(menuItem.depth == 1){
            IUStyleStorage *styleStorage = (IUStyleStorage *)[menuItem.parent.defaultStyleManager storageForViewPort:viewport];
            value = styleStorage.height;
        }
        else if(menuItem.depth == 2){
            IUStyleStorage *styleStorage = (IUStyleStorage *)[menuItem.defaultStyleManager storageForViewPort:viewport];
            value = styleStorage.height;
            
            if(value == nil){
                IUStyleStorage *parentStyleStorage = (IUStyleStorage *)[menuItem.parent.parent.defaultStyleManager storageForViewPort:viewport];
                value = parentStyleStorage.height;
            }
        }
        else{
            IUStyleStorage *styleStorage = (IUStyleStorage *)[menuItem.parent.defaultStyleManager storageForViewPort:viewport];
            value = styleStorage.height;
            
            if(value== nil){
                IUStyleStorage *parentStyleStorage = (IUStyleStorage *)[menuItem.parent.parent.parent.defaultStyleManager storageForViewPort:viewport];
                value = parentStyleStorage.height;
            }
        }
        
        
        int height = [value intValue];
        
        //item identifier
        [code setInsertingIdentifier:menuItem.itemIdentifier];
        [code setInsertingTarget:IUTargetBoth];
        IUStyleStorage *styleStorage = (IUStyleStorage *)[menuItem.defaultStyleManager storageForViewPort:viewport];
        if(styleStorage){
            if(styleStorage.bgColor1){
                [code insertTag:@"background-color" color:styleStorage.bgColor1];
            }
            if(styleStorage.fontColor){
                [code insertTag:@"color" color:styleStorage.fontColor];
            }
        }
        
        [code setInsertingIdentifier:[menuItem cssIdentifier]];
        [code setInsertingTarget:IUTargetBoth];
        
        if(viewport <= IUMobileSize && menuItem.children.count > 0){
            [code insertTag:@"height" string:@"initial"];
        }
        else{
            [code insertTag:@"height" number:@(height) unit:IUUnitPixel];
        }
        [code insertTag:@"line-height" number:@(height) unit:IUUnitPixel];
        
        
        //editor mode
        if(menuItem.editorDisplayIdentifier){
            [code setInsertingIdentifier:menuItem.editorDisplayIdentifier];
            [code setInsertingTarget:IUTargetEditor];
            
            if(viewport > IUMobileSize){
                if(menuItem.isOpened){
                    [code insertTag:@"display" string:@"block"];
                }
                else{
                    [code insertTag:@"display" string:@"none"];
                }
            }
            else{
                [code insertTag:@"display" string:@"block"];
            }
        }

    }
    
    [code setInsertingViewPort:menuItem.project.maxViewPort];
    [code setInsertingIdentifier:[menuItem cssIdentifier]];
    [code insertTag:@"box-sizing" string:@"border-box"];
    [code insertTag:@"-moz-box-sizing" string:@"border-box"];
    [code insertTag:@"-webkit-box-sizing" string:@"border-box"];
    
    //hover, active
    [code setInsertingIdentifiers:@[menuItem.hoverItemIdentifier, menuItem.activeItemIdentifier] withType:IUCSSIdentifierTypeNonInline];
    [code setInsertingTarget:IUTargetBoth];

    if(menuItem.bgActive){
        [code insertTag:@"background-color" color:menuItem.bgActive];
    }
    if(menuItem.fontActive){
        [code insertTag:@"color" color:menuItem.fontActive];
    }
    

}

- (void)updateCSSCode:(IUCSSCode*)code asIUCarousel:(IUCarousel*)carousel{
#if 0

    [code setInsertingViewPort:carousel.project.maxViewPort];
    if(carousel.deselectColor){
        [code setInsertingIdentifier:carousel.pagerID withType:IUCSSIdentifierTypeNonInline];
        [code insertTag:@"background-color" color:carousel.deselectColor];
    }
    if(carousel.selectColor){
        [code setInsertingIdentifier:[carousel pagerIDHover] withType:IUCSSIdentifierTypeNonInline];
        [code insertTag:@"background-color" color:carousel.selectColor];
    }
    if(carousel.selectColor){
        [code setInsertingIdentifier:[carousel pagerIDActive] withType:IUCSSIdentifierTypeNonInline];
        [code insertTag:@"background-color" color:carousel.selectColor];
    }
    
    
    [code setInsertingIdentifier:carousel.pagerWrapperID withType:IUCSSIdentifierTypeNonInline];
    if(carousel.pagerPosition){
        //FIXME: carousel width가 percent일 경우 width를 구해와야함!!
        NSInteger currentWidth = [carousel.defaultStyleStorage.width integerValue];
        
        if(carousel.pagerPosition < 50){
            [code insertTag:@"text-align" string:@"left"];
            int left = (int)((currentWidth) * ((CGFloat)carousel.pagerPosition/100));
            [code insertTag:@"left" number:@(left) unit:IUUnitPixel];
        }
        else if(carousel.pagerPosition == 50){
            [code insertTag:@"text-align" string:@"center"];
        }
        else if(carousel.pagerPosition < 100){
            [code insertTag:@"text-align" string:@"center"];
            int left = (int)((currentWidth) * ((CGFloat)(carousel.pagerPosition-50)/100));
            [code insertTag:@"left" number:@(left) unit:IUUnitPixel];
            
        }
        else if(carousel.pagerPosition == 100){
            int right = (int)((currentWidth) * ((CGFloat)(100-carousel.pagerPosition)/100));
            [code insertTag:@"text-align" string:@"right"];
            [code insertTag:@"right" number:@(right) unit:IUUnitPixel];
        }
    }
    
    [code setInsertingIdentifier:carousel.prevID withType:IUCSSIdentifierTypeNonInline];
    
    NSString *imageName = carousel.leftArrowImage;
    if(imageName){
        [code insertTag:@"left" number:@(carousel.leftX) unit:IUUnitPixel];
        [code insertTag:@"top" number:@(carousel.leftY) unit:IUUnitPixel];
        NSString *imgSrc = [_compiler imagePathWithImageName:imageName target:IUTargetEditor];
        if(imgSrc){
            [code insertTag:@"background" string:[imgSrc CSSURLString] target:IUTargetEditor];
        }
        
        NSString *outputImgSrc = [[_compiler imagePathWithImageName:imageName target:IUTargetOutput] CSSURLString];
        if(outputImgSrc){
            [code insertTag:@"background" string:outputImgSrc target:IUTargetOutput];
        }
        
        NSImage *arrowImage;
        
        if ([imageName isHTTPURL]) {
            arrowImage = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:imgSrc]];
        }
        else{
            arrowImage = [[NSImage alloc] initWithContentsOfFile:imgSrc];
            
        }
        
        if(arrowImage){
            [code insertTag:@"height" number:@(arrowImage.size.height) unit:IUCSSUnitPixel];
            [code insertTag:@"width" number:@(arrowImage.size.width) unit:IUCSSUnitPixel];
        }

    }
    
    [code setInsertingIdentifier:carousel.nextID withType:IUCSSIdentifierTypeNonInline];
    
    
    imageName = carousel.rightArrowImage;
    if(imageName){
        [code insertTag:@"right" number:@(carousel.rightX) unit:IUUnitPixel];
        [code insertTag:@"top" number:@(carousel.rightY) unit:IUUnitPixel];
        
        NSString * imgSrc = [_compiler imagePathWithImageName:imageName target:IUTargetEditor];
        if(imgSrc){
            [code insertTag:@"background" string:[imgSrc CSSURLString] target:IUTargetEditor];
        }
        
         NSString *outputImgSrc = [[_compiler imagePathWithImageName:imageName target:IUTargetOutput] CSSURLString];
        if(outputImgSrc){
            [code insertTag:@"background" string:outputImgSrc target:IUTargetOutput];
        }
        
        NSImage *arrowImage;

        
        if ([imageName isHTTPURL]) {
            arrowImage = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:imgSrc]];
        }
        else{
            arrowImage = [[NSImage alloc] initWithContentsOfFile:imgSrc];
        }
        
        if(arrowImage){
            [code insertTag:@"height" number:@(arrowImage.size.height) unit:IUCSSUnitPixel];
            [code insertTag:@"width" number:@(arrowImage.size.width) unit:IUCSSUnitPixel];
        }
    }
    
    NSArray *editWidths = [carousel.propertyManager allViewPorts];
    for (NSNumber *viewportNumber in editWidths) {
        int viewport = [viewportNumber intValue];
        
        [code setInsertingViewPort:viewport];
        [code setInsertingIdentifiers:@[carousel.prevID, carousel.nextID] withType:IUCSSIdentifierTypeNonInline];
        
        BOOL carouseldisable = [((IUPropertyStorage *)[carousel.propertyManager storageForViewPort:viewport]).carouselArrowDisable boolValue];
        
        if(carouseldisable){
            [code insertTag:@"display" string:@"none"];
        }
        else{
            [code insertTag:@"display" string:@"inherit"];
        }
    }
#endif

}

#pragma mark - WP Widgets
/*

- (void)updateCSSCode:(IUCSSCode*)code asWPMenu:(WPMenu*)wpmenu{
    [code setInsertingTarget:IUTargetBoth];
    [code setInsertingViewPort:wpmenu.project.maxViewPort];
    
    switch (wpmenu.align) {
        case IUAlignJustify:
            [code setInsertingIdentifier:wpmenu.containerIdentifier];
            [code insertTag:@"display" string:@"table"];
            [code insertTag:@"table-layout" string:@"fixed"];
            [code insertTag:@"width" string:@"100%"];
            
            [code setInsertingIdentifier:wpmenu.itemIdetnfier];
            [code insertTag:@"display" string:@"table-cell"];
            [code insertTag:@"text-align" string:@"center"];
            break;
        case IUAlignLeft:
            [code setInsertingIdentifier:wpmenu.itemIdetnfier];
            [code insertTag:@"float" string:@"left"];
        case IUAlignCenter:
            [code setInsertingIdentifier:wpmenu.containerIdentifier];
            [code insertTag:@"text-align" string:@"center"];
            break;
        case IUAlignRight:
            [code setInsertingIdentifier:wpmenu.containerIdentifier];
            [code insertTag:@"text-align" string:@"right"];

        default:
            break;
    }
    if(wpmenu.align != IUAlignJustify){
        [code setInsertingIdentifier:wpmenu.itemIdetnfier];
        [code insertTag:@"position" string:@"relative"];
        
        [code insertTag:@"padding" string:[NSString stringWithFormat:@"0 %ldpx", wpmenu.leftRightPadding]];
        [code insertTag:@"display" string:@"inline-block"];
    }
    
    [code setInsertingIdentifier:wpmenu.itemIdetnfier];
    for (NSNumber *viewport in [code allViewports]) {
        IUStyleStorage *styleStorage = (IUStyleStorage *)[wpmenu.defaultStyleManager storageForViewPort:[viewport intValue]];
        //IUTarget Editor value is equal to IUTargetOutput.
        if (styleStorage.height) {
            [code insertTag:@"line-height" number:styleStorage.height unit:IUUnitPixel];
        }
        
    }
}

- (void)updateCSSCode:(IUCSSCode*)code asWPPageLinks:(WPPageLinks*)wpPageLinks{
    [code setInsertingTarget:IUTargetBoth];
    [code setInsertingViewPort:wpPageLinks.project.maxViewPort];
    
    switch (wpPageLinks.align) {
        case IUAlignJustify:
            [code setInsertingIdentifier:wpPageLinks.containerIdentifier];
            [code insertTag:@"display" string:@"table"];
            [code insertTag:@"table-layout" string:@"fixed"];
            [code insertTag:@"width" string:@"100%"];            
            break;
        case IUAlignCenter:
            [code setInsertingIdentifier:wpPageLinks.containerIdentifier];
            [code insertTag:@"text-align" string:@"center"];
            break;
        case IUAlignRight:
            [code setInsertingIdentifier:wpPageLinks.containerIdentifier];
            [code insertTag:@"text-align" string:@"right"];
            
        default:
            break;
    }

}

- (void)updateCSSCode:(IUCSSCode*)code asWPPageLink:(WPPageLink *)_iu{
    [code setInsertingViewPort:_iu.project.maxViewPort];
    [code setInsertingTarget:IUTargetBoth];

    WPPageLinks *pageLinks = (WPPageLinks*)_iu.parent;

    [code setInsertingIdentifier:_iu.cssIdentifier];
    
    switch (pageLinks.align) {
        case IUAlignJustify:
            [code insertTag:@"display" string:@"table-cell"];
            [code insertTag:@"text-align" string:@"center"];
            break;
        case IUAlignLeft:
            [code insertTag:@"float" string:@"left"];
            break;
        default:
            break;
    }
    if(pageLinks.align != IUAlignJustify){
        
        [code insertTag:@"position" string:@"relative"];
        [code insertTag:@"margin-right" number:[NSNumber numberWithInteger:pageLinks.leftRightPadding] unit:IUUnitPixel];
        [code insertTag:@"display" string:@"inline-block"];
    }
    
    for (NSNumber *viewport in [code allViewports]) {
        
        
        IUStyleStorage *styleStorage = (IUStyleStorage *)[pageLinks.defaultStyleManager storageForViewPort:[viewport intValue]];
        //IUTarget Editor value is equal to IUTargetOutput.
        if(styleStorage.height){
            [code insertTag:@"line-height" number:styleStorage.height unit:IUUnitPixel];
        }
        

    }
    
    [code setInsertingTarget:IUTargetOutput];

    NSArray *identifiers = [code allIdentifiers];
    for (NSString *identifier in identifiers) {
        NSString *newIdentifier = [identifier stringByReplacingOccurrencesOfString:_iu.htmlID withString:[NSString stringWithFormat:@"%@ > ul > li" , pageLinks.htmlID]];
        [code renameIdentifier:identifier to:newIdentifier];
    }
    
}




- (void)updateCSSCode:(IUCSSCode*)code asWPWidgetBody:(WPWidgetBody*)_iu{
    NSArray *identifiers = [code allIdentifiers];
    WPSidebar *sidebar = (WPSidebar*)_iu.parent.parent;
    
    for (NSString *identifier in identifiers) {
        NSString *newIdentifier = [identifier stringByReplacingOccurrencesOfString:_iu.htmlID withString:[NSString stringWithFormat:@"%@ > .WPWidget > ul" , sidebar.htmlID]];
        [code renameIdentifier:identifier to:newIdentifier];
    }
}

- (void)updateCSSCode:(IUCSSCode*)code asWPWidgetTitle:(WPWidgetTitle*)_iu{
    NSArray *identifiers = [code allIdentifiers];
    
    WPSidebar *sidebar = (WPSidebar*)_iu.parent.parent;
    
    
    
    for (NSString *identifier in identifiers) {
        NSString *newIdentifier = [identifier stringByReplacingOccurrencesOfString:_iu.htmlID withString:[NSString stringWithFormat:@"%@ > .WPWidget > .WPWidgetTitle" , sidebar.htmlID]];
        [code renameIdentifier:identifier to:newIdentifier];
    }
}
*/






/*
- (void)updateCSSCode:(IUCSSCode*)code asPGPageLinkSet:(PGPageLinkSet*)pageLinkSet{
    [code setInsertingTarget:IUTargetBoth];
    [code setInsertingViewPort:pageLinkSet.project.maxViewPort];
    
    //ul class
    [code setInsertingIdentifier:pageLinkSet.clipIdentifier];
    switch (pageLinkSet.pageLinkAlign) {
        case IUAlignLeft: break;
        case IUAlignRight: [code insertTag:@"float" string:@"right"]; break;
        case IUAlignCenter: [code insertTag:@"margin" string:@"auto"]; break;
        default:NSAssert(0, @"Error");
    }
    [code insertTag:@"display" string:@"block"];
    
    //li class - active, hover
    [code setInsertingIdentifiers:@[pageLinkSet.activeIdentifier, pageLinkSet.hoverIdentifier] withType:IUCSSIdentifierTypeNonInline];
    [code insertTag:@"background-color" color:pageLinkSet.selectedButtonBGColor];
    

    //li class
    [code setInsertingIdentifier:pageLinkSet.itemIdentifier];
    [code insertTag:@"display" string:@"block"];
    [code insertTag:@"margin-left" number:@(pageLinkSet.buttonMargin) unit:IUUnitPixel];
    [code insertTag:@"margin-right" number:@(pageLinkSet.buttonMargin) unit:IUUnitPixel];
    [code insertTag:@"background-color" color:pageLinkSet.defaultButtonBGColor];

    
    //li media query
    [code setInsertingIdentifier:pageLinkSet.itemIdentifier];
    for (NSNumber *viewPort in [pageLinkSet.defaultStyleManager allViewPorts]){
        [code setInsertingViewPort:[viewPort intValue]];
        
        IUStyleStorage *styleStorage = (IUStyleStorage *)[pageLinkSet.defaultStyleManager storageForViewPort:[viewPort intValue]];
        if(styleStorage.height){
            //FIXME: percent가 들어오면 어떻게 되는건지????
            [code insertTag:@"width" number:styleStorage.height frameUnit:@(IUFrameUnitPixel)];
            [code insertTag:@"height" number:styleStorage.height frameUnit:@(IUFrameUnitPixel)];
            [code insertTag:@"line-height" number:styleStorage.height unit:IUUnitPixel];
        }
    }
}
 */

/*
- (void)updateLinkCSSCode:(IUCSSCode *)code asIUBox:(IUBox *)iu{
    //REVIEW: a tag는 밑으로 들어감. 상위에 있을 경우에 %사이즈를 먹어버림.
    //밑에 child 혹은 p tag 가 없을 경우에는 a tag의 사이즈가 0이 되기 때문에 size를 만들어줌
    return;
    NSAssert(0, @"not yet coded");
    
    if(iu.link && [_compiler hasLink:iu] && iu.children.count==0 ){
        if(iu.textInputType == IUTextInputTypeEditable){
            [code setInsertingIdentifier:[iu.cssIdentifier stringByAppendingString:@" a"]];
            [code setInsertingTarget:IUTargetBoth];
            
            [code insertTag:@"display" string:@"block"];
            [code insertTag:@"width" string:@"100%"];
            [code insertTag:@"height" string:@"100%"];
        }
    }
}
     */
@end
