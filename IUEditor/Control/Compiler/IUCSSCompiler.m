//
//  IUCSSCompiler.m
//  IUEditor
//
//  Created by jd on 2014. 8. 4..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUCSSCompiler.h"
#import "LMFontController.h"
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





@implementation IUCSSCompiler {
    __weak IUResourceManager *_resourceManager;
}



- (void)setResourceManager:(IUResourceManager*)resourceManager{
    _resourceManager = resourceManager;
}



- (IUCSSCode*)cssCodeForIU:(IUBox*)iu {
    IUCSSCode *code = [[IUCSSCode alloc] init];

    NSArray *classPedigree = [[iu class] classPedigreeTo:[IUBox class]].reversedArray;
    for (NSString *className in classPedigree) {
        NSString *str = [NSString stringWithFormat:@"updateCSSCode:as%@:storage:", className];
        SEL selector = NSSelectorFromString(str);
        if ([self respondsToSelector:selector]) {
            IMP imp = [self methodForSelector:selector];
            void (*func)(id, SEL, id, id, BOOL) = (void *)imp;
            func(self, selector, code, iu, NO);
        }
    }
    
    [self updateLinkCSSCode:code asIUBox:iu storage:NO];


    return code;
}


- (void)updateLinkCSSCode:(IUCSSCode *)code asIUBox:(IUBox *)iu storage:(BOOL)storage{
    //REVIEW: a tag는 밑으로 들어감. 상위에 있을 경우에 %사이즈를 먹어버림.
    //밑에 child 혹은 p tag 가 없을 경우에는 a tag의 사이즈가 0이 되기 때문에 size를 만들어줌
    if (storage) {
        assert(0);
    }
    else {
        if(iu.link && [_compiler hasLink:iu] && iu.children.count==0 ){
            if(iu.text == nil || iu.text.length ==0){
                [code setInsertingIdentifier:[iu.cssIdentifier stringByAppendingString:@" a"]];
                [code setInsertingTarget:IUTargetBoth];
                
                [code insertTag:@"display" string:@"block"];
                [code insertTag:@"width" string:@"100%"];
                [code insertTag:@"height" string:@"100%"];
            }
        }
    }
}

- (void)updateCSSCode:(IUCSSCode*)code asIUBox:(IUBox*)_iu storage:(BOOL)storage{
    NSArray *editWidths;
    if (storage) {
        editWidths = [_iu.cssManager allViewPorts];
    }
    else {
        editWidths = [_iu.css allViewports];;
    }
    
    for (NSNumber *viewportNumber in editWidths) {
        int viewport = [viewportNumber intValue];
        
        /* insert to editor and output, with default css identifier. */
        [code setInsertingIdentifier:_iu.cssIdentifier];
        [code setMainIdentifier:_iu.cssIdentifier];
        [code setInsertingTarget:IUTargetBoth];

        /* width can vary to data */
        [code setInsertingViewPort:viewport];

        /* update CSSCode */
        [self updateCSSPositionCode:code asIUBox:_iu viewport:viewport storage:storage];
        [self updateCSSApperanceCode:code asIUBox:_iu viewport:viewport storage:storage];

        if ([_iu shouldCompileFontInfo]) {
            [self updateCSSFontCode:code asIUBox:_iu viewport:viewport storage:storage];
        }
        
        [self updateCSSRadiousAndBorderCode:code asIUBox:_iu viewport:viewport storage:storage];
        [self updateCSSHoverCode:code asIUBox:_iu viewport:viewport storage:storage];
    }
}

- (void)updateCSSHoverCode:(IUCSSCode*)code asIUBox:(IUBox*)_iu viewport:(int)viewport storage:(BOOL)storage{
    NSDictionary *cssTagDict = [_iu.css tagDictionaryForViewport:viewport];

    if([_iu.link isKindOfClass:[IUBox class]]){
        [code setInsertingIdentifiers:@[_iu.cssHoverClass, _iu.cssActiveClass]];
    }
    else{
        [code setInsertingIdentifiers:@[_iu.cssHoverClass]];
    }
    
    if ([cssTagDict[IUCSSTagHoverBGImagePositionEnable] boolValue]) {
        [code insertTag:@"background-position-x" floatFromNumber:cssTagDict[IUCSSTagHoverBGImageX] unit:IUUnitPixel];
        [code insertTag:@"background-position-y" floatFromNumber:cssTagDict[IUCSSTagHoverBGImageY] unit:IUUnitPixel];
    }
    
    if ([cssTagDict[IUCSSTagHoverBGColorEnable] boolValue]){

        NSString *outputColor = [cssTagDict[IUCSSTagHoverBGColor] cssBGColorString];
        NSString *editorColor = [cssTagDict[IUCSSTagHoverBGColor] rgbaString];
        if ([outputColor length] == 0) {
            outputColor = @"black";
            editorColor = @"black";
        }
        [code setInsertingTarget:IUTargetOutput];
        [code insertTag:@"background-color" string:outputColor];
        
        [code setInsertingTarget:IUTargetEditor];
        [code insertTag:@"background-color" string:editorColor];
        
        [code setInsertingTarget:IUTargetOutput];
        if(cssTagDict[IUCSSTagHoverBGColorDuration]){
            [code setInsertingIdentifier:_iu.cssIdentifier];
            NSString *durationStr = [NSString stringWithFormat:@"background-color %lds", [cssTagDict[IUCSSTagHoverBGColorDuration] integerValue]];
            [code insertTag:@"-webkit-transition" string:durationStr];
            [code insertTag:@"transition" string:durationStr];
        }

    }
    
    
    if ([cssTagDict[IUCSSTagHoverTextColorEnable] boolValue]){
        [code insertTag:@"color" color:cssTagDict[IUCSSTagHoverTextColor]];
    }
}


- (void)updateCSSFontCode:(IUCSSCode*)code asIUBox:(IUBox*)_iu viewport:(int)viewport storage:(BOOL)storage{
    NSDictionary *cssTagDict = [_iu.css tagDictionaryForViewport:viewport];
    
    [code setInsertingTarget:IUTargetBoth];
    if (cssTagDict[IUCSSTagFontName] ) {
        NSString *fontFamily = [[LMFontController sharedFontController] cssForFontName:cssTagDict[IUCSSTagFontName]];
        if(fontFamily){
            [code insertTag:@"font-family" string:fontFamily];
        }
    }
    if (cssTagDict[IUCSSTagFontSize]) {
        [code insertTag:@"font-size" intFromNumber:cssTagDict[IUCSSTagFontSize] unit:IUUnitPixel];
    }
    if (cssTagDict[IUCSSTagFontColor]) {
        [code insertTag:@"color" color:cssTagDict[IUCSSTagFontColor]];
    }
    if ([cssTagDict[IUCSSTagTextLetterSpacing] floatValue]) {
        [code insertTag:@"letter-spacing" floatFromNumber:cssTagDict[IUCSSTagTextLetterSpacing] unit:IUUnitPixel];
    }
    if (cssTagDict[IUCSSTagFontWeight]) {
        [code insertTag:@"font-weight" string:cssTagDict[IUCSSTagFontWeight]];
    }
    if ([cssTagDict[IUCSSTagFontItalic] boolValue]) {
        [code insertTag:@"font-style" string:@"italic"];
    }
    if ([cssTagDict[IUCSSTagFontDecoration] boolValue]) {
        [code insertTag:@"text-decoration" string:@"underline"];
    }
    if (cssTagDict[IUCSSTagTextAlign]) {
        NSString *alignText;
        switch ([cssTagDict[IUCSSTagTextAlign] intValue]) {
            case IUAlignLeft: alignText = @"left"; break;
            case IUAlignCenter: alignText = @"center"; break;
            case IUAlignRight: alignText = @"right"; break;
            case IUAlignJustify: alignText = @"justify"; break;
            default: JDErrorLog(@"no align type"); NSAssert(0, @"no align type");
        }
        [code insertTag:@"text-align" string:alignText];
    }
    if (cssTagDict[IUCSSTagLineHeight]) {
        [code insertTag:@"line-height" floatFromNumber:cssTagDict[IUCSSTagLineHeight]];
    }
    if(_compiler.rule == IUCompileRuleDjango){
        if(cssTagDict[IUCSSTagEllipsis]){
            [code setInsertingTarget:IUTargetOutput];
            NSInteger line =  [cssTagDict[IUCSSTagEllipsis] integerValue];
            if(line > 0){
                if(line > 1){
                    [code insertTag:@"display" string:@"-webkit-box"];
                }
                else if(line == 1){
                    [code insertTag:@"white-space" string:@"nowrap"];
                }
                [code insertTag:@"overflow" string:@"hidden"];
                [code insertTag:@"text-overflow" string:@"ellipsis"];
                [code insertTag:@"-webkit-line-clamp" integer:(int)line unit:IUUnitNone];
                [code insertTag:@"-webkit-box-orient" string:@"vertical"];
                [code insertTag:@"height" integer:100 unit:IUUnitPercent];
            }
        }

    }
    
}

- (void)updateCSSRadiousAndBorderCode:(IUCSSCode*)code asIUBox:(IUBox*)_iu viewport:(int)viewport storage:(BOOL)storage{
    //REVIEW: border는 바깥으로 생김. child drop할때 position 계산 때문
    //IUMENUItem 은 예외 (width고정)
    NSDictionary *cssTagDict = [_iu.css tagDictionaryForViewport:viewport];

    [code setInsertingTarget:IUTargetBoth];

    if (cssTagDict[IUCSSTagBorderTopWidth]) {
        CGFloat width = [cssTagDict[IUCSSTagBorderTopWidth] floatValue];
        [code insertTag:@"border-top-width" floatValue:width unit:IUUnitPixel];
        id value = [_iu.css effectiveValueForTag:IUCSSTagBorderTopColor forViewport:viewport];
        [code insertTag:@"border-top-color" color:value];
    }

    if (cssTagDict[IUCSSTagBorderLeftWidth]) {
        CGFloat width = [cssTagDict[IUCSSTagBorderLeftWidth] floatValue];
        [code insertTag:@"border-left-width" floatValue:width unit:IUUnitPixel];
        id value = [_iu.css effectiveValueForTag:IUCSSTagBorderLeftColor forViewport:viewport];
        [code insertTag:@"border-left-color" color:value];

    }
    if (cssTagDict[IUCSSTagBorderRightWidth]) {
        CGFloat width = [cssTagDict[IUCSSTagBorderRightWidth] floatValue];
        [code insertTag:@"border-right-width" floatValue:width unit:IUUnitPixel];
        id value = [_iu.css effectiveValueForTag:IUCSSTagBorderRightColor forViewport:viewport];
        [code insertTag:@"border-right-color" color:value];

    }
    if (cssTagDict[IUCSSTagBorderBottomWidth]) {
        CGFloat width = [cssTagDict[IUCSSTagBorderBottomWidth] floatValue];
        [code insertTag:@"border-bottom-width" floatValue:width unit:IUUnitPixel];
        id value = [_iu.css effectiveValueForTag:IUCSSTagBorderBottomColor forViewport:viewport];
        [code insertTag:@"border-bottom-color" color:value];
    }

    if (cssTagDict[IUCSSTagBorderRadiusTopLeft]) {
        [code insertTag:@"border-top-left-radius" floatFromNumber:cssTagDict[IUCSSTagBorderRadiusTopLeft] unit:IUUnitPixel];
    }
    if (cssTagDict[IUCSSTagBorderRadiusTopRight]) {
        [code insertTag:@"border-top-right-radius" floatFromNumber:cssTagDict[IUCSSTagBorderRadiusTopRight] unit:IUUnitPixel];
    }
    if (cssTagDict[IUCSSTagBorderRadiusBottomLeft]) {
        [code insertTag:@"border-bottom-left-radius" floatFromNumber:cssTagDict[IUCSSTagBorderRadiusBottomLeft] unit:IUUnitPixel];
    }
    if (cssTagDict[IUCSSTagBorderRadiusBottomRight]) {
        [code insertTag:@"border-bottom-right-radius" floatFromNumber:cssTagDict[IUCSSTagBorderRadiusBottomRight] unit:IUUnitPixel];
    }

    NSInteger hOff = [cssTagDict[IUCSSTagShadowHorizontal] integerValue];
    NSInteger vOff = [cssTagDict[IUCSSTagShadowVertical] integerValue];
    NSInteger blur = [cssTagDict[IUCSSTagShadowBlur] integerValue];
    NSInteger spread = [cssTagDict[IUCSSTagShadowSpread] integerValue];
    NSColor *color = cssTagDict[IUCSSTagShadowColor];

    if (hOff || vOff || blur || spread){
        if (color == nil) {
            color = [NSColor blackColor];
        }
        [code insertTag:@"-moz-box-shadow" string:[NSString stringWithFormat:@"%ldpx %ldpx %ldpx %ldpx %@", hOff, vOff, blur, spread, [color rgbString]]];
        [code insertTag:@"-webkit-box-shadow" string:[NSString stringWithFormat:@"%ldpx %ldpx %ldpx %ldpx %@", hOff, vOff, blur, spread, [color rgbString]]];
        [code insertTag:@"box-shadow" string:[NSString stringWithFormat:@"%ldpx %ldpx %ldpx %ldpx %@", hOff, vOff, blur, spread, [color rgbString]]];
        
        //for IE5.5-7
        [code setInsertingTarget:IUTargetOutput];
        
        [code insertTag:@"filter" string:[NSString stringWithFormat:@"progid:DXImageTransform.Microsoft.Shadow(Strength=%ld, Direction=135, Color='%@')",spread, [color rgbString]]];
        
        //for IE 8
        [code insertTag:@"-ms-filter" string:[NSString stringWithFormat:@"\"progid:DXImageTransform.Microsoft.Shadow(Strength=%ld, Direction=135, Color='%@')",spread, [color rgbString]]];
        
        [code setInsertingTarget:IUTargetBoth];

    }
}

- (void)updateCSSApperanceCode:(IUCSSCode*)code asIUBox:(IUBox*)_iu viewport:(int)viewport storage:(BOOL)storage{
    [code setInsertingTarget:IUTargetBoth];
    NSDictionary *cssTagDict = [_iu.css tagDictionaryForViewport:viewport];
    
    if (viewport == IUCSSDefaultViewPort) {
        /* pointer */
        if (_iu.link) {
            [code insertTag:@"cursor" string:@"pointer"];
        }
        
        /* overflow */
        switch (_iu.overflowType) {
            case IUOverflowTypeHidden: break; //default is hidden
            case IUOverflowTypeVisible:{
                [code insertTag:@"overflow" string:@"visible"]; break;
            }
            case IUOverflowTypeScroll:{
                [code insertTag:@"overflow" string:@"scroll"]; break;
            }
        }
    }
    
    /* display */
    id value = cssTagDict[IUCSSTagDisplayIsHidden];
    if (value && [value boolValue]) {
        [code insertTag:@"display" string:@"none"];
    }
    else{
        if (storage == NO) {
            [code insertTag:@"display" string:@"inherit"];
        }
    }

    value = [_iu.css effectiveValueForTag:IUCSSTagEditorDisplay forViewport:viewport];
    if (value && [value boolValue] == NO) {
        [code insertTag:@"display" string:@"none" target:IUTargetEditor];
    }

    
    /* apperance */
    if (cssTagDict[IUCSSTagOpacity]) {
        float opacity = [cssTagDict[IUCSSTagOpacity] floatValue]/100;
        [code insertTag:@"opacity" floatFromNumber:@(opacity)];
        [code setInsertingTarget:IUTargetOutput];
        [code insertTag:@"filter" string:[NSString stringWithFormat:@"alpha(opacity=%d)",[cssTagDict[IUCSSTagOpacity] intValue]] ];
    }
    
    [code setInsertingTarget:IUTargetBoth];
    if (cssTagDict[IUCSSTagBGColor]) {
        [code insertTag:@"background-color" string:[cssTagDict[IUCSSTagBGColor] cssBGColorString]];

    }
    
    BOOL enableGraident = [cssTagDict[IUCSSTagBGGradient] boolValue];
    if(cssTagDict[IUCSSTagBGGradient] && enableGraident){
        NSColor *bgColor1 = cssTagDict[IUCSSTagBGGradientStartColor];
        NSColor *bgColor2 = cssTagDict[IUCSSTagBGGradientEndColor];
        
        if(enableGraident){
            if(bgColor2 == nil){
                bgColor2 = [NSColor rgbColorRed:0 green:0 blue:0 alpha:1];
            }
            if(bgColor1 == nil){
                bgColor1 = [NSColor rgbColorRed:0 green:0 blue:0 alpha:1];
            }
            [code insertTag:@"background-color" color:bgColor1];
            
            
            
            NSString *webKitStr = [NSString stringWithFormat:@"-webkit-gradient(linear, left top, left bottom, color-stop(0.05, %@), color-stop(1, %@));", bgColor1.rgbString, bgColor2.rgbString];
            NSString *mozStr = [NSString stringWithFormat:@"	background:-moz-linear-gradient( center top, %@ 5%%, %@ 100%% );", bgColor1.rgbString, bgColor2.rgbString];
            NSString *ieStr = [NSString stringWithFormat:@"filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='%@', endColorstr='%@', GradientType=0)", bgColor1.rgbStringWithTransparent, bgColor2.rgbStringWithTransparent];
            NSString *gradientStr = [webKitStr stringByAppendingFormat:@"%@ %@", mozStr, ieStr];
            
            [code setInsertingTarget:IUTargetOutput];
            [code insertTag:@"background" string:gradientStr];
            
            [code setInsertingTarget:IUTargetEditor];
            [code insertTag:@"background" string:webKitStr];
            
            
        }
        
    }
    //REVIEW: gradient와 background가 상충함, 동시에 실행안되게.
    else{
        //REVIEW: image전체로 bg image tag 검사하면 안됨, media query 지원 못하게 됨.
        if(cssTagDict[IUCSSTagImage]){
            NSString *imgSrc = [[_compiler imagePathWithImageName:cssTagDict[IUCSSTagImage] target:IUTargetEditor forFilePath:IUFilePathResource] CSSURLString];
            if(imgSrc){
                [code insertTag:@"background-image" string:imgSrc target:IUTargetEditor];
            }
            NSString *outputImgSrc = [[_compiler imagePathWithImageName:cssTagDict[IUCSSTagImage] target:IUTargetOutput forFilePath:IUFilePathResource] CSSURLString];
            if(outputImgSrc){
                [code insertTag:@"background-image" string:outputImgSrc target:IUTargetOutput];
            }
        }
        
        /* bg size & position */
        if(cssTagDict[IUCSSTagBGSize]){
            
            IUBGSizeType bgSizeType = [cssTagDict[IUCSSTagBGSize] intValue];
            switch (bgSizeType) {
                case IUBGSizeTypeStretch:
                    [code insertTag:@"background-size" string:@"100% 100%"];
                    break;
                case IUBGSizeTypeContain:
                    [code insertTag:@"background-size" string:@"contain"];
                    break;
                case IUBGSizeTypeFull:
                    [code insertTag:@"background-attachment" string:@"fixed"];
                case IUBGSizeTypeCover:
                    [code insertTag:@"background-size" string:@"cover"];
                    break;
                case IUBGSizeTypeAuto:
                    default:
                    break;
            }
            if(viewport != IUCSSDefaultViewPort && bgSizeType != IUBGSizeTypeFull){
                [code insertTag:@"background-attachment" string:@"initial"];
            }

        }
        
        if ([cssTagDict[IUCSSTagEnableBGCustomPosition] boolValue]) {
            /* custom bg position */
            [code insertTag:@"background-position-x" floatFromNumber:cssTagDict[IUCSSTagBGXPosition] unit:IUUnitPixel];
            [code insertTag:@"background-position-y" floatFromNumber:cssTagDict[IUCSSTagBGYPosition] unit:IUUnitPixel];
        }
        else {
            IUCSSBGVPostion vPosition = [cssTagDict[IUCSSTagBGVPosition] intValue];
            IUCSSBGHPostion hPosition = [cssTagDict[IUCSSTagBGHPosition] intValue];
            if (vPosition != IUCSSBGVPostionTop || hPosition != IUCSSBGHPostionLeft) {
                NSString *vPositionString, *hPositionString;
                switch (vPosition) {
                    case IUCSSBGVPostionTop: vPositionString = @"top"; break;
                    case IUCSSBGVPostionCenter: vPositionString = @"center"; break;
                    case IUCSSBGVPostionBottom: vPositionString = @"bottom"; break;
                        default: NSAssert(0, @"Cannot be default");  break;
                }
                switch (hPosition) {
                    case IUCSSBGHPostionLeft: hPositionString = @"left"; break;
                    case IUCSSBGHPostionCenter: hPositionString = @"center"; break;
                    case IUCSSBGVPostionBottom: hPositionString = @"right"; break;
                        default: NSAssert(0, @"Cannot be default");  break;
                }
                [code insertTag:@"background-position" string:[NSString stringWithFormat:@"%@ %@", vPositionString, hPositionString]];
            }
        }
        
        /* bg repeat */
        if ([cssTagDict[IUCSSTagBGRepeat] boolValue] == YES) {
            [code insertTag:@"background-repeat" string:@"repeat"];
        }
        else{
            if (storage == NO) {
                [code insertTag:@"background-repeat" string:@"no-repeat"];
            }
        }
    }
}



- (void)updateCSSPositionCode:(IUCSSCode*)code asIUBox:(IUBox*)_iu viewport:(int)viewport storage:(BOOL)storage{
    [code setInsertingTarget:IUTargetBoth];
    if (storage) {
        IUCSSStorage *storage = [_iu.cssManager storageForViewPort:viewport selector:IUCSSSelectorDefault];
        if (storage) {
            if (storage.x) {
                if ([storage.xUnit integerValue] == IUFrameUnitPercent){
                    [code insertTag:@"left" floatFromNumber:storage.xUnit unit:IUUnitPercent];
                }
                else if ([storage.xUnit integerValue] == IUFrameUnitPixel) {
                    [code insertTag:@"left" floatFromNumber:storage.x unit:IUUnitPixel];
                }
                else {
                    NSAssert (0, @"no x unit");
                }
            }
        }
    }
    else {
        NSDictionary *cssTagDict = [_iu.css tagDictionaryForViewport:viewport];
        
        
        /*  X, Y, Width, Height */
        IUUnit xUnit = [[_iu.css effectiveValueForTag:IUCSSTagXUnitIsPercent forViewport:viewport] boolValue] ? IUUnitPercent : IUUnitPixel;
        IUUnit yUnit = [[_iu.css effectiveValueForTag:IUCSSTagYUnitIsPercent forViewport:viewport] boolValue] ? IUUnitPercent : IUUnitPixel;
        
        NSNumber *xValue = (xUnit == IUUnitPercent) ? cssTagDict[IUCSSTagPercentX] : cssTagDict[IUCSSTagPixelX];
        NSNumber *yValue = (yUnit == IUUnitPercent) ? cssTagDict[IUCSSTagPercentY] : cssTagDict[IUCSSTagPixelY];
        
        NSString *topTag;
        NSString *leftTag;
        bool enablebottom=NO;
        /* insert position */
        /* Note */
        /* Cannot use'top' tag for relative position here.
         If parent is relative postion and do not have height,
         parent's height will be children's margintop + height.
         */
        
        switch (_iu.positionType) {
            case IUPositionTypeAbsoluteBottom:{
                enablebottom = YES;
                if(_iu.enableHCenter == NO){
                    leftTag = @"left";
                }
                break;
            }
            case IUPositionTypeAbsolute:{
                if(_iu.enableVCenter == NO){
                    topTag = @"top";
                }
                if(_iu.enableHCenter == NO){
                    leftTag = @"left";
                }
                break;
            }
            case IUPositionTypeRelative:{
                [code insertTag:@"position" string:@"relative"];
                topTag = @"margin-top";
                if(_iu.enableHCenter == NO){
                    leftTag = @"left";
                }
                break;
            }
            case IUPositionTypeFloatLeft:{
                [code insertTag:@"position" string:@"relative"];
                [code insertTag:@"float" string:@"left"];
                topTag = @"margin-top"; leftTag = @"margin-left"; break;
                break;
            }
            case IUPositionTypeFloatRight:{
                [code insertTag:@"position" string:@"relative"];
                [code insertTag:@"float" string:@"right"];
                topTag = @"margin-top";
                leftTag = @"margin-right";
                float xValueFloat = [xValue floatValue] * (-1);
                xValue = @(xValueFloat);
                break;
            }
            case IUPositionTypeFixedBottom:{
                enablebottom = YES;
                [code insertTag:@"position" string:@"fixed"];
                [code insertTag:@"z-index" string:@"11"];
                leftTag = @"left"; break;
            }
            case IUPositionTypeFixed:{
                [code insertTag:@"position" string:@"fixed"];
                [code insertTag:@"z-index" string:@"11"];
                if(_iu.enableVCenter == NO){
                    topTag = @"top";
                }
                leftTag = @"left"; break;
            }
            default:
                break;
        }
        if (_iu.shouldCompileY && topTag) {
            [code insertTag:topTag floatFromNumber:yValue unit:yUnit];
        }
        if (_iu.shouldCompileX && leftTag) {
            [code insertTag:leftTag floatFromNumber:xValue unit:xUnit];
        }
        if (enablebottom){
            [code insertTag:@"bottom" integer:0 unit:IUCSSUnitPixel];
        }
        if (_iu.shouldCompileWidth) {
            
            IUUnit wUnit = [[_iu.css effectiveValueForTag:IUCSSTagWidthUnitIsPercent forViewport:viewport] boolValue] ? IUUnitPercent : IUUnitPixel;
            NSNumber *wValue = (wUnit == IUUnitPercent) ? cssTagDict[IUCSSTagPercentWidth] : cssTagDict[IUCSSTagPixelWidth];
            [code insertTag:@"width" floatFromNumber:wValue unit:wUnit];
            if(wUnit == IUUnitPercent && cssTagDict[IUCSSTagMinPixelWidth]){
                [code insertTag:@"min-width" intFromNumber:cssTagDict[IUCSSTagMinPixelWidth] unit:IUUnitPixel];
            }
        }
        
        if (_iu.shouldCompileHeight) {
            
            IUUnit hUnit = [[_iu.css effectiveValueForTag:IUCSSTagHeightUnitIsPercent forViewport:viewport] boolValue] ? IUUnitPercent : IUUnitPixel;
            NSNumber *hValue = (hUnit == IUUnitPercent) ? cssTagDict[IUCSSTagPercentHeight] : cssTagDict[IUCSSTagPixelHeight];
            [code insertTag:@"height" floatFromNumber:hValue unit:hUnit];
            
            if(hUnit == IUUnitPercent && cssTagDict[IUCSSTagMinPixelHeight]){
                [code insertTag:@"min-height" intFromNumber:cssTagDict[IUCSSTagMinPixelHeight] unit:IUUnitPixel];
            }
        }
    }
}

- (void)updateCSSCode:(IUCSSCode*)code asIUSection:(IUSection*)section storage:(BOOL)storage{
    if(section.enableFullSize){
        [code setInsertingTarget:IUTargetEditor];
        [code setInsertingIdentifier:section.cssIdentifier];
        [code insertTag:@"height" integer:720 unit:IUUnitPixel];
    }
}

- (void)updateCSSCode:(IUCSSCode*)code asIUHeader:(IUHeader*)header storage:(BOOL)storage{
    if(header.prototypeClass){
        NSArray *editWidths = [header.css allViewports];
        [code setInsertingIdentifier:header.cssIdentifier];
        
        
        for (NSNumber *viewportNumber in editWidths) {
            int viewport = [viewportNumber intValue];
            [code setInsertingViewPort:viewport];

            //IUHeader의 높이는 prototypeclass의 높이와 일치시킨다.
            NSDictionary *cssTagDict = [header.prototypeClass.css tagDictionaryForViewport:viewport];
            
            IUUnit hUnit = [[header.prototypeClass.css effectiveValueForTag:IUCSSTagHeightUnitIsPercent forViewport:viewport] boolValue] ? IUUnitPercent : IUUnitPixel;
            NSNumber *hValue = (hUnit == IUUnitPercent) ? cssTagDict[IUCSSTagPercentHeight] : cssTagDict[IUCSSTagPixelHeight];
            [code insertTag:@"height" floatFromNumber:hValue unit:hUnit];
            
            if(hUnit == IUUnitPercent && cssTagDict[IUCSSTagMinPixelHeight]){
                [code insertTag:@"min-height" intFromNumber:cssTagDict[IUCSSTagMinPixelHeight] unit:IUUnitPixel];
            }
        }
    }
}

- (void)updateCSSCode:(IUCSSCode*)code asIUFooter:(IUFooter*)footer storage:(BOOL)storage{
    if(footer.prototypeClass){
        NSArray *editWidths = [footer.css allViewports];
        [code setInsertingIdentifier:footer.cssIdentifier];
        
        
        for (NSNumber *viewportNumber in editWidths) {
            int viewport = [viewportNumber intValue];
            [code setInsertingViewPort:viewport];
            
            //IUHeader의 높이는 prototypeclass의 높이와 일치시킨다.
            if(footer.prototypeClass){
                NSDictionary *cssTagDict = [footer.prototypeClass.css tagDictionaryForViewport:viewport];
                
                IUUnit hUnit = [[footer.prototypeClass.css effectiveValueForTag:IUCSSTagHeightUnitIsPercent forViewport:viewport] boolValue] ? IUUnitPercent : IUUnitPixel;
                NSNumber *hValue = (hUnit == IUUnitPercent) ? cssTagDict[IUCSSTagPercentHeight] : cssTagDict[IUCSSTagPixelHeight];
                [code insertTag:@"height" floatFromNumber:hValue unit:hUnit];
                
                if(hUnit == IUUnitPercent && cssTagDict[IUCSSTagMinPixelHeight]){
                    [code insertTag:@"min-height" intFromNumber:cssTagDict[IUCSSTagMinPixelHeight] unit:IUUnitPixel];
                }
            }
        }
    }
    
}



- (void)updateCSSCode:(IUCSSCode*)code asPGPageLinkSet:(PGPageLinkSet*)pageLinkSet storage:(BOOL)storage{
    [code setInsertingTarget:IUTargetBoth];
    [code setInsertingViewPort:IUCSSDefaultViewPort];
    
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
    [code setInsertingIdentifiers:@[pageLinkSet.activeIdentifier, pageLinkSet.hoverIdentifier]];
    [code insertTag:@"background-color" color:pageLinkSet.selectedButtonBGColor];
    

    //li class
    [code setInsertingIdentifier:pageLinkSet.itemIdentifier];
    [code insertTag:@"display" string:@"block"];
    [code insertTag:@"margin-left" floatFromNumber:@(pageLinkSet.buttonMargin) unit:IUUnitPixel];
    [code insertTag:@"margin-right" floatFromNumber:@(pageLinkSet.buttonMargin) unit:IUUnitPixel];
    [code insertTag:@"background-color" color:pageLinkSet.defaultButtonBGColor];

    
    //li media query
    [code setInsertingIdentifier:pageLinkSet.itemIdentifier];
    for (NSNumber *viewPort in [pageLinkSet.css allViewports]) {
        [code setInsertingViewPort:[viewPort intValue]];
        id height = [pageLinkSet.css effectiveValueForTag:IUCSSTagPixelHeight forViewport:[viewPort intValue]];
        [code insertTag:@"height" floatFromNumber:height unit:IUUnitPixel];
        [code insertTag:@"width" floatFromNumber:height unit:IUUnitPixel];
        [code insertTag:@"line-height" floatFromNumber:height unit:IUUnitPixel];
        
    }
    
}

- (void)updateCSSCode:(IUCSSCode*)code asIUMenuBar:(IUMenuBar*)menuBar storage:(BOOL)storage{
    
    NSArray *editWidths = [menuBar.css allViewports];

    for (NSNumber *viewportNumber in editWidths) {
        int viewport = [viewportNumber intValue];
        [code setInsertingViewPort:viewport];
        int height = [[menuBar.css effectiveValueForTag:IUCSSTagPixelHeight forViewport:viewport] intValue];

        [code setInsertingTarget:IUTargetBoth];
        if(viewport < IUMobileSize){
            
            
            if(height > 10){
                //mobile
                [code setInsertingIdentifier:menuBar.mobileButtonIdentifier];
                [code insertTag:@"line-height" integer:height unit:IUUnitPixel];
                [code insertTag:@"color" color:menuBar.mobileTitleColor];
                
                
                //mobile-menu
                [code setInsertingIdentifier:menuBar.topButtonIdentifier];
                int top = (height -10)/2;
                [code insertTag:@"top" integer:top unit:IUUnitPixel];
                [code insertTag:@"border-color" color:menuBar.iconColor];
                
                [code setInsertingIdentifier:menuBar.bottomButtonIdentifier];
                top =(height -10)/2 +10;
                [code insertTag:@"top" integer:top unit:IUUnitPixel];
                [code insertTag:@"border-color" color:menuBar.iconColor];
            }
            
            //editormode
            [code setInsertingIdentifier:menuBar.editorDisplayIdentifier];
            [code setInsertingTarget:IUTargetEditor];
            
            if(menuBar.isOpened){
                [code insertTag:@"display" string:@"block"];
            }
            else{
                [code insertTag:@"display" string:@"none"];
            }
            
        }
        
    }

    [code removeTag:@"width" identifier:menuBar.cssIdentifier viewport:IUCSSDefaultViewPort];
    
}

- (void)updateCSSCode:(IUCSSCode*)code asIUMenuItem:(IUMenuItem*)menuItem storage:(BOOL)storage{

    NSMutableArray *editWidths = [menuItem.project.mqSizes mutableCopy];
    [editWidths replaceObjectAtIndex:0 withObject:@(IUCSSDefaultViewPort)];
    
    for (NSNumber *viewportNumber in editWidths) {
        int viewport = [viewportNumber intValue];
        [code setInsertingViewPort:viewport];
        
        //css identifier
        [code setInsertingIdentifier:[menuItem cssIdentifier]];
        [code setInsertingTarget:IUTargetBoth];
        
        
        //set height for depth
        id value;
        if(menuItem.depth == 1){
            value = [menuItem.parent.css effectiveValueForTag:IUCSSTagPixelHeight forViewport:viewport];
        }
        else if(menuItem.depth == 2){
            value = [menuItem.css effectiveValueForTag:IUCSSTagPixelHeight forViewport:viewport];

            if(value == nil){
                value = [menuItem.parent.parent.css effectiveValueForTag:IUCSSTagPixelHeight forViewport:viewport];
            }
        }
        else{
            value = [menuItem.parent.css effectiveValueForTag:IUCSSTagPixelHeight forViewport:viewport];

            if(value== nil){
                value = [menuItem.parent.parent.parent.css effectiveValueForTag:IUCSSTagPixelHeight forViewport:viewport];
            }
        }
        

        int height = [value intValue];
        
        //item identifier
        [code setInsertingIdentifier:menuItem.itemIdentifier];
        [code setInsertingTarget:IUTargetBoth];
        
        value = [menuItem.css effectiveValueForTag:IUCSSTagBGColor forViewport:viewport];
        if(value){
            [code insertTag:@"background-color" color:value];
        }
        value = [menuItem.css effectiveValueForTag:IUCSSTagFontColor forViewport:viewport];
        if(value){
            [code insertTag:@"color" color:value];
        }
        
        [code setInsertingIdentifier:[menuItem cssIdentifier]];
        [code setInsertingTarget:IUTargetBoth];

        if(viewport <= IUMobileSize && menuItem.children.count > 0){
            [code insertTag:@"height" string:@"initial"];
        }
        else{
            [code insertTag:@"height" integer:height unit:IUUnitPixel];
        }
        [code insertTag:@"line-height" integer:height unit:IUUnitPixel];


        
        //clousre
        //closure removed 2014.10.20 @smchoi
        /*
        if(menuItem.closureIdentifier){
            [code setInsertingIdentifier:menuItem.closureIdentifier];
            value = [menuItem.css effectiveValueForTag:IUCSSTagFontColor forViewport:viewport];
            
            if(value){
                NSString *color = [[(NSColor *)value rgbString] stringByAppendingString:@" !important"];
                if(menuItem.depth == 1){
                    [code insertTag:@"border-top-color" string:color];
                }
                else if(menuItem.depth ==2){
                    IUMenuBar *menuBar = (IUMenuBar *)(menuItem.parent.parent);
                    if(viewport > IUMobileSize){
                        if(menuBar.align == IUMenuBarAlignLeft){
                            [code insertTag:@"border-left-color" string:color];
                        }
                        else if(menuBar.align == IUMenuBarAlignRight){
                            [code insertTag:@"border-right-color" string:color];
                        }
                    }
                    else{
                        if(menuBar.align == IUMenuBarAlignLeft){
                            [code insertTag:@"border-left-color" string:@"transparent !important"];
                        }
                        else if(menuBar.align == IUMenuBarAlignRight){
                            [code insertTag:@"border-right-color" string:@"transparent !important"];
                        }
                        [code insertTag:@"border-top-color" string:color];
                    }
                }
            }
            int top = (maxHeight- 10)/2;
            [code insertTag:@"top" integer:top unit:IUUnitPixel];
                
            
        }
         
        
        //clousre active, hover
        if(menuItem.closureHoverIdentifier){
            [code setInsertingIdentifiers:@[menuItem.closureActiveIdentifier, menuItem.closureHoverIdentifier]];
            NSString *color = [[menuItem.fontActive rgbString] stringByAppendingString:@" !important"];
            if(menuItem.depth == 1){
                [code insertTag:@"border-top-color" string:color];
            }
            else if(menuItem.depth ==2){
                IUMenuBar *menuBar = (IUMenuBar *)(menuItem.parent.parent);
                if(viewport > IUMobileSize){
                    if(menuBar.align == IUMenuBarAlignLeft){
                        [code insertTag:@"border-left-color" string:color];
                    }
                    else if(menuBar.align == IUMenuBarAlignRight){
                        [code insertTag:@"border-right-color" string:color];
                    }
                }
                else{
                    if(menuBar.align == IUMenuBarAlignLeft){
                        [code insertTag:@"border-left-color" string:@"transparent !important"];
                    }
                    else if(menuBar.align == IUMenuBarAlignRight){
                        [code insertTag:@"border-right-color" string:@"transparent !important"];
                    }
                    [code insertTag:@"border-top-color" string:color];
                }
            }
            int top = (maxHeight- 10)/2;
            [code insertTag:@"top" integer:top unit:IUUnitPixel];
            
        }
         */
        
        
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
    
    [code setInsertingViewPort:IUCSSDefaultViewPort];
    [code setInsertingIdentifier:[menuItem cssIdentifier]];
    [code insertTag:@"box-sizing" string:@"border-box"];
    [code insertTag:@"-moz-box-sizing" string:@"border-box"];
    [code insertTag:@"-webkit-box-sizing" string:@"border-box"];
    
    //hover, active
    [code setInsertingIdentifiers:@[menuItem.hoverItemIdentifier, menuItem.activeItemIdentifier]];
    [code setInsertingTarget:IUTargetBoth];

    if(menuItem.bgActive){
        [code insertTag:@"background-color" color:menuItem.bgActive];
    }
    if(menuItem.fontActive){
        [code insertTag:@"color" color:menuItem.fontActive];
    }
    

}

- (void)updateCSSCode:(IUCSSCode*)code asIUCarousel:(IUCarousel*)carousel storage:(BOOL)storage{
    
    [code setInsertingViewPort:IUCSSDefaultViewPort];
    if(carousel.deselectColor){
        [code setInsertingIdentifier:carousel.pagerID];
        [code insertTag:@"background-color" color:carousel.deselectColor];
    }
    if(carousel.selectColor){
        [code setInsertingIdentifier:[carousel pagerIDHover]];
        [code insertTag:@"background-color" color:carousel.selectColor];
    }
    if(carousel.selectColor){
        [code setInsertingIdentifier:[carousel pagerIDActive]];
        [code insertTag:@"background-color" color:carousel.selectColor];
    }
    
    
    [code setInsertingIdentifier:carousel.pagerWrapperID];
    if(carousel.pagerPosition){
        NSInteger currentWidth  = [[carousel.css effectiveValueForTag:IUCSSTagPixelWidth forViewport:IUCSSDefaultViewPort] integerValue];
        
        if(carousel.pagerPosition < 50){
            [code insertTag:@"text-align" string:@"left"];
            int left = (int)((currentWidth) * ((CGFloat)carousel.pagerPosition/100));
            [code insertTag:@"left" integer:left unit:IUUnitPixel];
        }
        else if(carousel.pagerPosition == 50){
            [code insertTag:@"text-align" string:@"center"];
        }
        else if(carousel.pagerPosition < 100){
            [code insertTag:@"text-align" string:@"center"];
            int left = (int)((currentWidth) * ((CGFloat)(carousel.pagerPosition-50)/100));
            [code insertTag:@"left" integer:left unit:IUUnitPixel];
            
        }
        else if(carousel.pagerPosition == 100){
            int right = (int)((currentWidth) * ((CGFloat)(100-carousel.pagerPosition)/100));
            [code insertTag:@"text-align" string:@"right"];
            [code insertTag:@"right" integer:right unit:IUUnitPixel];
        }
    }
    
    [code setInsertingIdentifier:carousel.prevID];
    
    NSString *imageName = carousel.leftArrowImage;
    if(imageName){
        [code insertTag:@"left" integer:carousel.leftX unit:IUUnitPixel];
        [code insertTag:@"top" integer:carousel.leftY unit:IUUnitPixel];
        
        NSString *imgSrc = [_compiler imagePathWithImageName:imageName target:IUTargetEditor forFilePath:IUFilePathResource];
        if(imgSrc){
            [code insertTag:@"background" string:[imgSrc CSSURLString] target:IUTargetEditor];
        }
        
        NSString *outputImgSrc = [[_compiler imagePathWithImageName:imageName target:IUTargetOutput forFilePath:IUFilePathResource] CSSURLString];
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
            [code insertTag:@"height" floatFromNumber:@(arrowImage.size.height) unit:IUCSSUnitPixel];
            [code insertTag:@"width" floatFromNumber:@(arrowImage.size.width) unit:IUCSSUnitPixel];
        }
    }
    
    [code setInsertingIdentifier:carousel.nextID];
    
    
    imageName = carousel.rightArrowImage;
    if(imageName){
        [code insertTag:@"right" integer:carousel.rightX unit:IUUnitPixel];
        [code insertTag:@"top" integer:carousel.rightY unit:IUUnitPixel];
        
        NSString * imgSrc = [_compiler imagePathWithImageName:imageName target:IUTargetEditor forFilePath:IUFilePathResource];
        if(imgSrc){
            [code insertTag:@"background" string:[imgSrc CSSURLString] target:IUTargetEditor];
        }
        
         NSString *outputImgSrc = [[_compiler imagePathWithImageName:imageName target:IUTargetOutput forFilePath:IUFilePathResource] CSSURLString];
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
            [code insertTag:@"height" floatFromNumber:@(arrowImage.size.height) unit:IUCSSUnitPixel];
            [code insertTag:@"width" floatFromNumber:@(arrowImage.size.width) unit:IUCSSUnitPixel];
        }
    }
    
    NSArray *editWidths = [carousel.css allViewports];
    for (NSNumber *viewportNumber in editWidths) {
        int viewport = [viewportNumber intValue];
        
        [code setInsertingViewPort:viewport];
        [code setInsertingIdentifiers:@[carousel.prevID, carousel.nextID]];
        
        BOOL carouseldisable = [[carousel.css effectiveValueForTag:IUCSSTagCarouselArrowDisable forViewport:viewport] boolValue];
        
        if(carouseldisable){
            [code insertTag:@"display" string:@"none"];
        }
        else{
            [code insertTag:@"display" string:@"inherit"];
        }
    }

}

#pragma mark - WP Widgets

- (void)updateCSSCode:(IUCSSCode*)code asWPMenu:(WPMenu*)wpmenu storage:(BOOL)storage{
    [code setInsertingTarget:IUTargetBoth];
    [code setInsertingViewPort:IUCSSDefaultViewPort];
    
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
        NSNumber *heightValue = [wpmenu.css effectiveValueForTag:IUCSSTagPixelHeight forViewport:[viewport intValue]];
        //IUTarget Editor value is equal to IUTargetOutput.
        if (heightValue) {
            [code insertTag:@"line-height" floatFromNumber:heightValue unit:IUUnitPixel];
        }
    }
}

- (void)updateCSSCode:(IUCSSCode*)code asWPPageLinks:(WPPageLinks*)wpPageLinks storage:(BOOL)storage{
    [code setInsertingTarget:IUTargetBoth];
    [code setInsertingViewPort:IUCSSDefaultViewPort];
    
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

- (void)updateCSSCode:(IUCSSCode*)code asWPPageLink:(WPPageLink *)_iu storage:(BOOL)storage{
    [code setInsertingViewPort:IUCSSDefaultViewPort];
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
        [code insertTag:@"margin-right" intFromNumber:[NSNumber numberWithInteger:pageLinks.leftRightPadding] unit:IUUnitPixel];
        [code insertTag:@"display" string:@"inline-block"];
    }
    
    for (NSNumber *viewport in [code allViewports]) {
        NSNumber *heightValue = [pageLinks.css effectiveValueForTag:IUCSSTagPixelHeight forViewport:[viewport intValue]];
        //IUTarget Editor value is equal to IUTargetOutput.
        if (heightValue) {
            [code insertTag:@"line-height" floatFromNumber:heightValue unit:IUUnitPixel];
        }
    }
    
    [code setInsertingTarget:IUTargetOutput];

    NSArray *identifiers = [code allIdentifiers];
    for (NSString *identifier in identifiers) {
        NSString *newIdentifier = [identifier stringByReplacingOccurrencesOfString:_iu.htmlID withString:[NSString stringWithFormat:@"%@ > ul > li" , pageLinks.htmlID]];
        [code renameIdentifier:identifier to:newIdentifier];
    }
    
}

- (IUCSSCode*)cssCodeForIU_storage:(IUBox *)iu{
    IUCSSCode *code = [[IUCSSCode alloc] init];
    
    NSArray *classPedigree = [[iu class] classPedigreeTo:[IUBox class]].reversedArray;
    for (NSString *className in classPedigree) {
        NSString *str = [NSString stringWithFormat:@"updateCSSCode:as%@:storage:", className];
        SEL selector = NSSelectorFromString(str);
        if ([self respondsToSelector:selector]) {
            IMP imp = [self methodForSelector:selector];
            void (*func)(id, SEL, id, id, BOOL) = (void *)imp;
            func(self, selector, code, iu, YES);
        }
    }
    
    [self updateLinkCSSCode:code asIUBox:iu storage:NO];
    return code;

}

- (IUCSSCode*)cssCodeForIU_storage:(IUBox*)iu target:(IUTarget)target viewPort:(int)viewPort{
    //FIXME: Not Coded
    return [self cssCodeForIU_storage:iu];
}

/*

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


@end
