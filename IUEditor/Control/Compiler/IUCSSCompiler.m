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

#import "IUDataStorage.h"



@implementation IUCSSCompiler {
}

- (IUCSSCode*)cssCodeForIU:(IUBox*)iu {
    IUCSSCode *code = [[IUCSSCode alloc] init];
    [code setMaxViewPort:iu.project.maxViewPort];

    NSArray *classPedigree = [[iu class] classPedigreeTo:[IUBox class]].reversedArray;
    for (NSString *className in classPedigree) {
        NSString *str = [NSString stringWithFormat:@"updateCSSCode:as%@:", className];
        SEL selector = NSSelectorFromString(str);
        if ([self respondsToSelector:selector]) {
            IMP imp = [self methodForSelector:selector];
            void (*func)(id, SEL, id, id) = (void *)imp;
            func(self, selector, code, iu);
        }
    }
    
    [self updateLinkCSSCode:code asIUBox:iu];


    return code;
}

- (IUCSSCode*)cssCodeForIU:(IUBox*)iu rule:(NSString*)rule target:(IUTarget)target viewPort:(NSInteger)viewPort option:(NSDictionary *)option {
    //FIXME: Not Coded
    return [self cssCodeForIU:iu];
}


- (void)updateLinkCSSCode:(IUCSSCode *)code asIUBox:(IUBox *)iu{
    //REVIEW: a tag는 밑으로 들어감. 상위에 있을 경우에 %사이즈를 먹어버림.
    //밑에 child 혹은 p tag 가 없을 경우에는 a tag의 사이즈가 0이 되기 때문에 size를 만들어줌
    return;
    NSAssert(0, @"not yet coded");
    
    /*
    if(iu.link && [_compiler hasLink:iu] && iu.children.count==0 ){
        if(iu.textInputType == IUTextInputTypeEditable){
            [code setInsertingIdentifier:[iu.cssIdentifier stringByAppendingString:@" a"]];
            [code setInsertingTarget:IUTargetBoth];
            
            [code insertTag:@"display" string:@"block"];
            [code insertTag:@"width" string:@"100%"];
            [code insertTag:@"height" string:@"100%"];
        }
    }
     */
}

- (void)updateCSSCode:(IUCSSCode*)code asIUBox:(IUBox*)_iu{
    //TODO : organize
    NSMutableArray *editWidths = [[_iu.defaultStyleManager allViewPorts] mutableCopy];
    for(NSNumber *viewport in [_iu.positionManager allViewPorts]){
        if ([editWidths containsObject:viewport] == NO) {
            [editWidths addObject:viewport];
        }
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
        [self updateCSSPositionCode:code asIUBox:_iu viewport:viewport];
        [self updateCSSApperanceCode:code asIUBox:_iu viewport:viewport];

        [self updateCSSFontCode:code asIUBox:_iu viewport:viewport];
        
        
        [self updateCSSRadiousAndBorderCode:code asIUBox:_iu viewport:viewport];
        [self updateCSSHoverCode:code asIUBox:_iu viewport:viewport];
    }
}

- (void)updateCSSHoverCode:(IUCSSCode*)code asIUBox:(IUBox*)_iu viewport:(int)viewport{
    
    if([_iu.link isKindOfClass:[IUBox class]]){
        [code setInsertingIdentifiers:@[_iu.cssHoverClass, _iu.cssActiveClass] withType:IUCSSIdentifierTypeNonInline];
    }
    else{
        [code setInsertingIdentifiers:@[_iu.cssHoverClass] withType:IUCSSIdentifierTypeNonInline];
    }
    
    
    IUStyleStorage *hoverStorage = (IUStyleStorage *)[_iu.hoverStyleManager storageForViewPort:viewport];
    if (hoverStorage) {
        [code setInsertingTarget:IUTargetBoth];
        
        //css has color or image
        if(hoverStorage.imageX || hoverStorage.imageY){
            if(hoverStorage.imageX){
                [code insertTag:@"background-position-x" number:hoverStorage.imageX unit:IUUnitPixel];
            }
            if(hoverStorage.imageY){
                [code insertTag:@"background-position-y" number:hoverStorage.imageY unit:IUUnitPixel];
            }
        }
        else if(hoverStorage.bgColor){
            NSString *outputColor = [hoverStorage.bgColor cssBGColorString];
            NSString *editorColor = [hoverStorage.bgColor rgbaString];
            if ([outputColor length] == 0) {
                outputColor = @"black";
                editorColor = @"black";
            }
            [code setInsertingTarget:IUTargetOutput];
            [code insertTag:@"background-color" string:outputColor];
            
            [code setInsertingTarget:IUTargetEditor];
            [code insertTag:@"background-color" string:editorColor];
            [code setInsertingTarget:IUTargetBoth];
            
            if(hoverStorage.bgColorDuration){
                [code setInsertingIdentifier:_iu.cssIdentifier];
                NSString *durationStr = [NSString stringWithFormat:@"background-color %lds", [hoverStorage.bgColorDuration integerValue]];
                [code insertTag:@"-webkit-transition" string:durationStr];
                [code insertTag:@"transition" string:durationStr];
                
            }
        }
        
        if(hoverStorage.fontColor){
            [code insertTag:@"color" color:hoverStorage.fontColor];
            
        }
        
    }

}


- (void)updateCSSFontCode:(IUCSSCode*)code asIUBox:(IUBox*)_iu viewport:(int)viewport{
    
    [code setInsertingTarget:IUTargetBoth];

    
    IUStyleStorage *styleStorage = (IUStyleStorage *)[_iu.defaultStyleManager storageForViewPort:viewport];
    if(styleStorage){
        if(styleStorage.fontName){
            NSString *fontFamily = [[LMFontController sharedFontController] cssForFontName:styleStorage.fontName];
            [code insertTag:@"font-family" string:fontFamily];
        }
        
        if(styleStorage.fontSize){
            [code insertTag:@"font-size" number:styleStorage.fontSize unit:IUUnitPixel];
        }
        
        if(styleStorage.fontColor){
            [code insertTag:@"color" color:styleStorage.fontColor];
        }
        
        if(styleStorage.fontLetterSpacing){
            [code insertTag:@"letter-spacing" number:styleStorage.fontLetterSpacing unit:IUUnitPixel];
        }
        
        if(styleStorage.fontWeight){
            [code insertTag:@"font-weight" string:styleStorage.fontWeight];
        }
        
        if(styleStorage.fontItalic && [styleStorage.fontItalic boolValue]){
            [code insertTag:@"font-style" string:@"italic"];
        }
        
        if(styleStorage.fontUnderline && [styleStorage.fontUnderline boolValue]){
            [code insertTag:@"text-decoration" string:@"underline"];
        }
        
        if(styleStorage.fontAlign){
            NSString *alignText;
            switch ([styleStorage.fontAlign intValue]) {
                case IUAlignLeft: alignText = @"left"; break;
                case IUAlignCenter: alignText = @"center"; break;
                case IUAlignRight: alignText = @"right"; break;
                case IUAlignJustify: alignText = @"justify"; break;
                default: JDErrorLog(@"no align type"); NSAssert(0, @"no align type");
            }
            [code insertTag:@"text-align" string:alignText];
        }
        
        if(styleStorage.fontLineHeight){
            [code insertTag:@"line-height" number:styleStorage.fontLineHeight unit:IUUnitNone];
        }
        /*
        if(_compiler.rule == IUCompileRuleDjango){
            if(styleStorage.fontEllipsis){
                [code setInsertingTarget:IUTargetOutput];
                NSInteger line =  [styleStorage.fontEllipsis integerValue];
                if(line > 0){
                    if(line > 1){
                        [code insertTag:@"display" string:@"-webkit-box"];
                    }
                    else if(line == 1){
                        [code insertTag:@"white-space" string:@"nowrap"];
                    }
                    [code insertTag:@"overflow" string:@"hidden"];
                    [code insertTag:@"text-overflow" string:@"ellipsis"];
                    [code insertTag:@"-webkit-line-clamp" number:styleStorage.fontEllipsis unit:IUUnitNone];
                    [code insertTag:@"-webkit-box-orient" string:@"vertical"];
                    [code insertTag:@"height" number:@(100) unit:IUUnitPercent];
                }
            }
        }
        */
    }
    
}

- (void)updateCSSRadiousAndBorderCode:(IUCSSCode*)code asIUBox:(IUBox*)_iu viewport:(int)viewport{
    
    [code setInsertingTarget:IUTargetBoth];
    
    
    IUStyleStorage *styleStorage = (IUStyleStorage *)[_iu.defaultStyleManager storageForViewPort:viewport];
    if (styleStorage) {
        if(styleStorage.borderWidth && styleStorage.borderColor){
            //width
            if(styleStorage.borderWidth == NSMultipleValuesMarker){
                if(styleStorage.topBorderWidth){
                    [code insertTag:@"border-top-width" number:styleStorage.topBorderWidth unit:IUUnitPixel];
                }
                if(styleStorage.bottomBorderWidth){
                    [code insertTag:@"border-bottom-width" number:styleStorage.bottomBorderWidth unit:IUUnitPixel];
                }
                if(styleStorage.leftBorderWidth){
                    [code insertTag:@"border-left-width" number:styleStorage.leftBorderWidth unit:IUUnitPixel];
                }
                if(styleStorage.rightBorderWidth){
                    [code insertTag:@"border-right-width" number:styleStorage.rightBorderWidth unit:IUUnitPixel];
                }
            }
            else{
                [code insertTag:@"border-width" number:styleStorage.borderWidth unit:IUUnitPixel];
            }
            //color
            if(styleStorage.borderColor == NSMultipleValuesMarker){
                if(styleStorage.topBorderColor){
                    [code insertTag:@"border-top-color" color:styleStorage.topBorderColor];
                }
                if(styleStorage.bottomBorderColor){
                    [code insertTag:@"border-bottom-color" color:styleStorage.bottomBorderColor];
                }
                if(styleStorage.leftBorderColor){
                    [code insertTag:@"border-left-color" color:styleStorage.leftBorderColor];
                }
                if(styleStorage.rightBorderColor){
                    [code insertTag:@"border-right-color" color:styleStorage.rightBorderColor];
                }
                
            }
            else{
                [code insertTag:@"border-color" color:styleStorage.borderColor];
            }
            
            //radius
            if(styleStorage.borderRadius){
                if(styleStorage.borderRadius == NSMultipleValuesMarker){
                    if (styleStorage.topLeftBorderRadius) {
                        [code insertTag:@"border-top-left-radius" number:styleStorage.topLeftBorderRadius unit:IUUnitPixel];
                    }
                    if (styleStorage.topLeftBorderRadius) {
                        [code insertTag:@"border-top-right-radius" number:styleStorage.topRightBorderRadius unit:IUUnitPixel];
                    }
                    if (styleStorage.bottomLeftborderRadius) {
                        [code insertTag:@"border-bottom-left-radius" number:styleStorage.bottomLeftborderRadius unit:IUUnitPixel];
                    }
                    if (styleStorage.bottomRightBorderRadius) {
                        [code insertTag:@"border-bottom-right-radius" number:styleStorage.bottomRightBorderRadius unit:IUUnitPixel];
                    }
                }
                else{
                    [code insertTag:@"border-radius" number:styleStorage.borderRadius unit:IUUnitPixel];
                }
                
            }
            
            //blur
            if(styleStorage.shadowColorBlur || styleStorage.shadowColorHorizontal || styleStorage.shadowColorVertical || styleStorage.shadowColorSpread){
                if(styleStorage.shadowColor){
                    
                    NSInteger hOff = [styleStorage.shadowColorHorizontal integerValue];
                    NSInteger vOff = [styleStorage.shadowColorVertical integerValue];
                    NSInteger blur = [styleStorage.shadowColorBlur integerValue];
                    NSInteger spread = [styleStorage.shadowColorSpread integerValue];
                    NSString *colorString = [styleStorage.shadowColor rgbaString];
                    
                    [code insertTag:@"-moz-box-shadow" string:[NSString stringWithFormat:@"%ldpx %ldpx %ldpx %ldpx %@", hOff, vOff, blur, spread, colorString]];
                    [code insertTag:@"-webkit-box-shadow" string:[NSString stringWithFormat:@"%ldpx %ldpx %ldpx %ldpx %@", hOff, vOff, blur, spread, colorString]];
                    [code insertTag:@"box-shadow" string:[NSString stringWithFormat:@"%ldpx %ldpx %ldpx %ldpx %@", hOff, vOff, blur, spread, colorString]];
                    
                    //for IE5.5-7
                    [code setInsertingTarget:IUTargetOutput];
                    [code insertTag:@"filter" string:[NSString stringWithFormat:@"progid:DXImageTransform.Microsoft.Shadow(Strength=%ld, Direction=135, Color='%@')",spread, colorString]];
                    
                    //for IE 8
                    [code insertTag:@"-ms-filter" string:[NSString stringWithFormat:@"\"progid:DXImageTransform.Microsoft.Shadow(Strength=%ld, Direction=135, Color='%@')",spread, colorString]];
                    [code setInsertingTarget:IUTargetBoth];
                    
                }
            }
            
        }
        
    }
   
}

- (void)updateCSSApperanceCode:(IUCSSCode*)code asIUBox:(IUBox*)_iu viewport:(int)viewport{
    [code setInsertingTarget:IUTargetBoth];
    IUStyleStorage *styleStorage = (IUStyleStorage *)[_iu.defaultStyleManager storageForViewPort:viewport];
    
    /* css for default view port */
    /* pointer */
    if (_iu.link) {
        [code insertTag:@"cursor" string:@"pointer"];
    }
    
    /*overflow*/
    if(styleStorage.overflowType){
        IUOverflowType overflow = [[styleStorage overflowType] intValue];
        switch (overflow) {
            case IUOverflowTypeVisible:
                [code insertTag:@"overflow" string:@"visible"];
                break;
            case IUOverflowTypeScroll:
                [code insertTag:@"overflow" string:@"scroll"];
                break;
            case IUOverflowTypeHidden:
                //default overflow type : hidden
            default:
                break;
        }
    }
    
    /* display */
    if(styleStorage.hidden){
        if([styleStorage.hidden boolValue]){
            [code insertTag:@"display" string:@"none"];
        }
        else{
            [code insertTag:@"display" string:@"inherit"];
        }
    }
    
    if(styleStorage.editorHidden && [styleStorage.editorHidden boolValue]){
        [code insertTag:@"display" string:@"none" target:IUTargetEditor];
    }
    
    /* opacity */
    if(styleStorage.opacity){
        float opacity = [styleStorage.opacity floatValue] / 100;
        [code insertTag:@"opacity" number:@(opacity) unit:IUUnitNone];
        
        [code setInsertingTarget:IUTargetOutput];
        [code insertTag:@"filter" string:[NSString stringWithFormat:@"alpha(opacity=%d)",[styleStorage.opacity intValue]] ];
        
        [code setInsertingTarget:IUTargetBoth];
    }
    
    
    /* background-color */
    if(styleStorage.bgGradientStartColor && styleStorage.bgGradientEndColor){
        
        [code insertTag:@"background-color" color:styleStorage.bgGradientStartColor];
        
        
        NSString *webKitStr = [NSString stringWithFormat:@"-webkit-gradient(linear, left top, left bottom, color-stop(0.05, %@), color-stop(1, %@));", styleStorage.bgGradientStartColor.rgbString, styleStorage.bgGradientEndColor.rgbString];
        NSString *mozStr = [NSString stringWithFormat:@"	background:-moz-linear-gradient( center top, %@ 5%%, %@ 100%% );", styleStorage.bgGradientStartColor.rgbString, styleStorage.bgGradientEndColor.rgbString];
        NSString *ieStr = [NSString stringWithFormat:@"filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='%@', endColorstr='%@', GradientType=0)", styleStorage.bgGradientStartColor.rgbStringWithTransparent, styleStorage.bgGradientEndColor.rgbStringWithTransparent];
        NSString *gradientStr = [webKitStr stringByAppendingFormat:@"%@ %@", mozStr, ieStr];
        
        [code setInsertingTarget:IUTargetOutput];
        [code insertTag:@"background" string:gradientStr];
        
        [code setInsertingTarget:IUTargetEditor];
        [code insertTag:@"background" string:webKitStr];
        
        
    }
    else{
        if(styleStorage.bgColor){
            [code insertTag:@"background-color" string:[styleStorage.bgColor cssBGColorString]];
            
        }
        
        /* background - image */
#if 0
        if(styleStorage.imageName){
            if (styleStorage.imageName) {
                <#statements#>
            }
            NSAssert(0, @"not yet coded");
            NSString *imgSrc = [[_compiler imagePathWithImageName:styleStorage.imageName target:IUTargetEditor] CSSURLString];
            if(imgSrc){
                [code insertTag:@"background-image" string:imgSrc target:IUTargetEditor];
            }
            NSString *outputImgSrc = [[_compiler imagePathWithImageName:styleStorage.imageName target:IUTargetOutput] CSSURLString];
            if(outputImgSrc){
                [code insertTag:@"background-image" string:outputImgSrc target:IUTargetOutput];
            }
            
            
            /* image size */
            if(styleStorage.imageSizeType){
                IUStyleImageSizeType sizetype = [styleStorage.imageSizeType intValue];
                switch (sizetype) {
                    case IUStyleImageSizeTypeStretch:
                        [code insertTag:@"background-size" string:@"100% 100%"];
                        break;
                    case IUStyleImageSizeTypeContain:
                        [code insertTag:@"background-size" string:@"contain"];
                        break;
                    case IUStyleImageSizeTypeCover:
                        [code insertTag:@"background-size" string:@"cover"];
                        break;
                    case IUStyleImageSizeTypeAuto:
                    default:
                        break;
                }
            }
            
            if(styleStorage.imageAttachment && [styleStorage.imageAttachment boolValue]){
                [code insertTag:@"background-attachment" string:@"fixed"];
            }
            
            /* image position */
            if(styleStorage.imageX || styleStorage.imageY){
                if(styleStorage.imageX){
                    [code insertTag:@"background-position-x" number:styleStorage.imageX unit:IUUnitPixel];
                }
                if(styleStorage.imageY){
                    [code insertTag:@"background-position-y" number:styleStorage.imageY unit:IUUnitPixel];
                }
            }
            else{
                if(styleStorage.imageVPosition){
                    IUCSSBGVPostion vPosition = [styleStorage.imageVPosition intValue];
                    NSString *vPositionString;
                    switch (vPosition) {
                        case IUCSSBGVPostionTop: vPositionString = @"top"; break;
                        case IUCSSBGVPostionCenter: vPositionString = @"center"; break;
                        case IUCSSBGVPostionBottom: vPositionString = @"bottom"; break;
                        default:
                            break;
                    }
                    [code insertTag:@"background-position-y" string:vPositionString];
                }
                if(styleStorage.imageHPosition){
                    IUCSSBGHPostion hPosition = [styleStorage.imageHPosition intValue];
                    NSString *hPositionString;
                    switch (hPosition) {
                        case IUCSSBGHPostionLeft: hPositionString = @"left"; break;
                        case IUCSSBGHPostionCenter: hPositionString = @"center"; break;
                        case IUCSSBGVPostionBottom: hPositionString = @"right"; break;
                        default: NSAssert(0, @"Cannot be default");  break;
                    }
                    [code insertTag:@"background-position-x" string:hPositionString];
                }
                
            }
            
            /* image repeat */
            if(styleStorage.imageRepeat){
                if ([styleStorage.imageRepeat boolValue]) {
                    [code insertTag:@"background-repeat" string:@"repeat"];
                }
                else{
                    [code insertTag:@"background-repeat" string:@"no-repeat"];
                }
            }
        }
#endif

    }
}



- (void)updateCSSPositionCode:(IUCSSCode*)code asIUBox:(IUBox*)_iu viewport:(int)viewport{
    [code setInsertingTarget:IUTargetBoth];

    
    IUPositionStorage *positionStorage = (IUPositionStorage *)[_iu.positionManager storageForViewPort:viewport];
    if(positionStorage){
        if(positionStorage.position){
            NSString *topTag;
            NSString *leftTag;
            bool enablebottom=NO;
            IUPositionType positionType = [positionStorage.position intValue];
            /* insert position */
            /* Note */
            /* Cannot use'top' tag for relative position here.
             If parent is relative postion and do not have height,
             parent's height will be children's margintop + height.
             */
            
            switch (positionType) {
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
                    if (viewport == _iu.project.maxViewPort) {
                        NSAssert(0, @"cannot come here");
                    }
                    break;
            }
            
            //set x location
            if (enablebottom){
                [code insertTag:@"bottom" number:@(0) unit:IUCSSUnitPixel];
            }
            else if (positionStorage.x && _iu.shouldCompileX && leftTag ) {
                
                if(positionType == IUPositionTypeFloatRight){
                    CGFloat right = [positionStorage.x floatValue] * (-1);
                    [code insertTag:leftTag number:@(right) frameUnit:positionStorage.xUnit];
                }
                else{
                    [code insertTag:leftTag number:positionStorage.x frameUnit:positionStorage.xUnit];
                }
            }
            //set y location
            if(positionStorage.y && _iu.shouldCompileY && topTag){
                [code insertTag:topTag number:positionStorage.y frameUnit:positionStorage.yUnit];
            }
            
        }
    }
    else if (viewport == _iu.project.maxViewPort) {
        NSAssert(0, @"can not come to here");
    }
    
    IUStyleStorage *styleStorage = (IUStyleStorage *)[_iu.defaultStyleManager storageForViewPort:viewport];
    if (styleStorage) {
        
        if(_iu.shouldCompileWidth){
            
            if(styleStorage.width){
                [code insertTag:@"width" number:styleStorage.width frameUnit:styleStorage.widthUnit];
            }
            if(styleStorage.minWidth){
                [code insertTag:@"min-width" number:styleStorage.minWidth frameUnit:@(IUFrameUnitPixel)];
            }
        }
        
        
        if(_iu.shouldCompileHeight){
            
            if(styleStorage.height){
                [code insertTag:@"height" number:styleStorage.height frameUnit:styleStorage.heightUnit];
            }
            if(styleStorage.minHeight){
                [code insertTag:@"min-height" number:styleStorage.minHeight frameUnit:@(IUFrameUnitPixel)];
            }
        }
    }
    
}

- (void)updateCSSCode:(IUCSSCode*)code asIUSection:(IUSection*)section{
    if(section.enableFullSize){
        [code setInsertingTarget:IUTargetEditor];
        [code setInsertingIdentifier:section.cssIdentifier];
        [code insertTag:@"height" number:@(720) unit:IUUnitPixel];
    }
}

- (void)updateCSSCode:(IUCSSCode*)code asIUHeader:(IUHeader*)header{
    if(header.prototypeClass){
        
        NSArray *editWidths = [header.defaultStyleManager allViewPorts];
        [code setInsertingIdentifier:header.cssIdentifier];
        
        //FIXME : import가 css를 공유한다면 사라져도 될 코드임.
        for (NSNumber *viewportNumber in editWidths) {
            int viewport = [viewportNumber intValue];
            [code setInsertingViewPort:viewport];
            
            IUStyleStorage *styleStorage = (IUStyleStorage *)[header.prototypeClass.defaultStyleManager storageForViewPort:viewport];
            if(styleStorage.height){
                [code insertTag:@"height" number:styleStorage.height frameUnit:styleStorage.heightUnit];
            }
            
            if(styleStorage.minHeight && [styleStorage.heightUnit isEqualToNumber:@(IUFrameUnitPercent)]){
                [code insertTag:@"min-height" number:styleStorage.minHeight frameUnit:(IUFrameUnitPixel)];
                
            }
        }
    }
}

- (void)updateCSSCode:(IUCSSCode*)code asIUFooter:(IUFooter*)footer storage:(BOOL)storage{
    if(footer.prototypeClass){
        NSArray *editWidths = [footer.defaultStyleManager allViewPorts];
        [code setInsertingIdentifier:footer.cssIdentifier];
        
        
        //FIXME : import가 css를 공유한다면 사라져도 될 코드임.
        for (NSNumber *viewportNumber in editWidths) {
            int viewport = [viewportNumber intValue];
            [code setInsertingViewPort:viewport];
            
            IUStyleStorage *styleStorage = (IUStyleStorage *)[footer.prototypeClass.defaultStyleManager storageForViewPort:viewport];
            if(styleStorage.height){
                [code insertTag:@"height" number:styleStorage.height frameUnit:styleStorage.heightUnit];
            }
            
            if(styleStorage.minHeight && [styleStorage.heightUnit isEqualToNumber:@(IUFrameUnitPercent)]){
                [code insertTag:@"min-height" number:styleStorage.minHeight frameUnit:(IUFrameUnitPixel)];
                
            }
        }
    }
    
    
    
}



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

- (void)updateCSSCode:(IUCSSCode*)code asIUMenuBar:(IUMenuBar*)menuBar{
    
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

    NSMutableArray *editWidths = [menuItem.project.mqSizes mutableCopy];
    
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
            if(styleStorage.bgColor){
                [code insertTag:@"background-color" color:styleStorage.bgColor];
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
