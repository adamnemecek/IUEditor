//
//  IUCSSBaseCompiler.m
//  IUEditor
//
//  Created by Joodong Yang on 2014. 12. 18..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUCSSBaseCompiler.h"
#import "IUProjectProtocol.h"

@implementation IUCSSBaseCompiler

- (IUCSSCode*)cssCodeForIU:(IUBox*)iu target:(IUTarget)target viewPort:(NSInteger)viewPort option:(NSDictionary *)option {
    IUCSSCode *code = [[IUCSSCode alloc] init];
    [code setMainIdentifier:[NSString stringWithFormat:@".%@", iu.htmlID]];
    [code setInsertingTarget:target];
    [code setInsertingIdentifier:iu.cssIdentifier];
    
    if (target == IUTargetEditor) {
        [code setInsertingViewPort:viewPort];
        IUPositionStorage *storage = (iu.positionManager.currentViewPort == viewPort) ? iu.positionManager.cascadingStorage : (IUPositionStorage *)[[iu positionManager] cascadingStorageForViewPort:viewPort];
        [self updateCSSPositionCode:code IU:iu storage:storage option:option];
        
        IUStyleStorage *styleStorage = (iu.positionManager.currentViewPort == viewPort) ? iu.defaultStyleManager.cascadingStorage : [[iu defaultStyleManager] cascadingStorageForViewPort:viewPort];
        [self updateCSSWidthAndHeightCode:code IU:iu storage:styleStorage option:option];
        [self updateCSSAppearanceCode:code styleStorage:styleStorage option:option];
        [self updateCSSBackgroundCode:code target:target storage:styleStorage option:option];
        [self updateCSSFontCode:code styleStorage:styleStorage option:option];
        [self updateCSSRadiusAndBorderCode:code styleStorage:styleStorage option:option];
       /*
        if([iu.link isKindOfClass:[IUBox class]]){
#warning active class?
            [code setInsertingIdentifiers:@[iu.cssHoverClass, iu.cssActiveClass] withType:IUCSSIdentifierTypeNonInline];
        }
        else{
            [code setInsertingIdentifiers:@[iu.cssHoverClass] withType:IUCSSIdentifierTypeNonInline];
        }
        IUStyleStorage *hoverStyleStorage = (IUStyleStorage *)[[iu hoverStyleManager] cascadingStorageForViewPort:viewPort];
        [self updateCSSHoverCode:code hoverStyleStorage:hoverStyleStorage option:option];
        */
        
    }
    else {
        NSAssert(0, @"NOT YET CODED");
    }
    return code;
}

- (void)updateCSSPositionCode:(IUCSSCode *)code IU:(IUBox *)iu storage:(IUPositionStorage *)positionStorage option:(NSDictionary *)option{
    
    if(positionStorage.firstPosition){
        NSString *topTag;
        NSString *leftTag;
        bool enablebottom=NO;
        IUFirstPositionType positionType = [positionStorage.firstPosition intValue];
        /* insert position */
        /* Note */
        /* Cannot use'top' tag for relative position here.
         If parent is relative postion and do not have height,
         parent's height will be children's margintop + height.
         */
        
        switch (positionType) {
            case IUFirstPositionTypeAbsolute:{
                if(iu.enableVCenter == NO){
                    topTag = @"top";
                }
                if(iu.enableHCenter == NO){
                    leftTag = @"left";
                }
                break;
            }
            case IUFirstPositionTypeRelative:{
                [code insertTag:@"position" string:@"relative"];
                topTag = @"margin-top";
                if(iu.enableHCenter == NO){
                    leftTag = @"left";
                }
                break;
            }
            case IUFirstPositionTypeFixed:{
                [code insertTag:@"position" string:@"fixed"];
                [code insertTag:@"z-index" string:@"11"];
                if(iu.enableVCenter == NO){
                    topTag = @"top";
                }
                leftTag = @"left"; break;
            }
            default:
                NSAssert(0, @"WHAT THE FUCK");
        }
        
        if (positionStorage.secondPosition) {
            switch ([positionStorage.secondPosition intValue]) {
                case IUSecondPositionTypeFloatLeft:
                    [code insertTag:@"float" string:@"left"];
                    leftTag = @"margin-left";
                    break;
                case IUSecondPositionTypeFloatRight:
                    [code insertTag:@"float" string:@"right"];
                    leftTag = @"margin-right";
                    break;
                    
                case IUSecondPositionTypeBottom:
                    topTag = nil;
                    enablebottom = YES;
                    break;
                default:
                    break;
            }
        }
        //set x location
        if (enablebottom){
            [code insertTag:@"bottom" number:@(0) unit:IUCSSUnitPixel];
        }
        else if (positionStorage.x && iu.shouldCompileX && leftTag ) {
            if([positionStorage.secondPosition intValue] == IUSecondPositionTypeFloatRight){
                CGFloat right = [positionStorage.x floatValue] * (-1);
                [code insertTag:leftTag number:@(right) frameUnit:positionStorage.xUnit];
            }
            else{
                [code insertTag:leftTag number:positionStorage.x frameUnit:positionStorage.xUnit];
            }
        }
        //set y location
        if(positionStorage.y && iu.shouldCompileY && topTag){
            [code insertTag:topTag number:positionStorage.y frameUnit:positionStorage.yUnit];
        }
    }
}

- (void)updateCSSWidthAndHeightCode:(IUCSSCode *)code IU:(IUBox *)iu storage:(IUStyleStorage *)styleStorage option:(NSDictionary *)option{
    if(iu.shouldCompileWidth){
        if(styleStorage.width){
            [code insertTag:@"width" number:styleStorage.width frameUnit:styleStorage.widthUnit];
        }
        if(styleStorage.minWidth){
            [code insertTag:@"min-width" number:styleStorage.minWidth frameUnit:@(IUFrameUnitPixel)];
        }
    }
    
    
    if(iu.shouldCompileHeight){
        if(styleStorage.height){
            [code insertTag:@"height" number:styleStorage.height frameUnit:styleStorage.heightUnit];
        }
        if(styleStorage.minHeight){
            [code insertTag:@"min-height" number:styleStorage.minHeight frameUnit:@(IUFrameUnitPixel)];
        }
    }
}

- (void)updateCSSBackgroundCode:(IUCSSCode *)code target:(IUTarget)target storage:(IUStyleStorage *)styleStorage option:(NSDictionary *)option{
    /* background-color */
    if (styleStorage.bgColor1) {
        if (styleStorage.bgColor2 == nil) {
            /* gradient == NO */
            [code insertTag:@"background-color" string:[styleStorage.bgColor1 cssBGColorString]];
        }
        //gradient
        else {
            NSString *webKitStr = [NSString stringWithFormat:@"-webkit-gradient(linear, left top, left bottom, color-stop(0.05, %@), color-stop(1, %@));", styleStorage.bgColor1.rgbString, styleStorage.bgColor2.rgbString];
            NSString *mozStr = [NSString stringWithFormat:@"	background:-moz-linear-gradient( center top, %@ 5%%, %@ 100%% );", styleStorage.bgColor2.rgbString, styleStorage.bgColor1.rgbString];
            NSString *ieStr = [NSString stringWithFormat:@"filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='%@', endColorstr='%@', GradientType=0)", styleStorage.bgColor1.rgbStringWithTransparent, styleStorage.bgColor2.rgbStringWithTransparent];
            
            NSString *gradientStr = [webKitStr stringByAppendingFormat:@"%@ %@", mozStr, ieStr];
            
            [code insertTag:@"background" string:gradientStr];
        }
    }
    
    /* background-image */
    if (styleStorage.imageName){
        NSString *prefixpath =  (target == IUTargetEditor) ? _editorResourcePrefix : _outputResourcePrefix;
        NSString *urlPath = (prefixpath == nil) ? [styleStorage.imageName CSSURLString] : [[prefixpath stringByAppendingPathComponent:styleStorage.imageName] CSSURLString];
        [code insertTag:@"background-image" string:urlPath target:IUTargetEditor];
    }
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
    /* basically, IU has background-repeat:no-repeat in iu.css */
    if([styleStorage.imageRepeat boolValue]){
        [code insertTag:@"background-repeat" string:@"repeat"];
    }
}


- (void)updateCSSFontCode:(IUCSSCode*)code styleStorage:(IUStyleStorage *)styleStorage option:(NSDictionary *)options{
    if(styleStorage.fontName){
#warning Cannot Use LMFontContrller at HERE
        /*
         NSString *fontFamily = [[LMFontController sharedFontController] cssForFontName:styleStorage.fontName];
         if(fontFamily){
         [code insertTag:@"font-family" string:fontFamily];
         }
         */
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

- (void)updateCSSRadiusAndBorderCode:(IUCSSCode*)code styleStorage:(IUStyleStorage *)styleStorage option:(NSDictionary *)options{
    if(styleStorage.borderWidth){
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
    }
    if (styleStorage.borderColor) {
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

#if 0
- (void)updateCSSHoverCode:(IUCSSCode*)code hoverStyleStorage:(IUStyleStorage *)hoverStyleStorage option:(NSDictionary *)option{
    //css has color or image
    if(hoverStyleStorage.imageX || hoverStyleStorage.imageY){
        if(hoverStyleStorage.imageX){
            [code insertTag:@"background-position-x" number:hoverStyleStorage.imageX unit:IUUnitPixel];
        }
        if(hoverStyleStorage.imageY){
            [code insertTag:@"background-position-y" number:hoverStyleStorage.imageY unit:IUUnitPixel];
        }
    }
    else if(hoverStyleStorage.bgColor1){
        NSString *outputColor = [hoverStyleStorage.bgColor1 cssBGColorString];
        NSString *editorColor = [hoverStyleStorage.bgColor1 rgbaString];
        if ([outputColor length] == 0) {
            outputColor = @"black";
            editorColor = @"black";
        }
        [code setInsertingTarget:IUTargetOutput];
        [code insertTag:@"background-color" string:outputColor];
        
        [code setInsertingTarget:IUTargetEditor];
        [code insertTag:@"background-color" string:editorColor];
        [code setInsertingTarget:IUTargetBoth];
        
        /*
        if(hoverStyleStorage.bgColorDuration){
            [code setInsertingIdentifier:_iu.cssIdentifier];
            NSString *durationStr = [NSString stringWithFormat:@"background-color %lds", [hoverStyleStorage.bgColorDuration integerValue]];
            [code insertTag:@"-webkit-transition" string:durationStr];
            [code insertTag:@"transition" string:durationStr];
        }
         */
    }
    
    if(hoverStyleStorage.fontColor){
        [code insertTag:@"color" color:hoverStyleStorage.fontColor];
        
    }
}
#endif


- (void)updateCSSAppearanceCode:(IUCSSCode*)code styleStorage:(IUStyleStorage *)styleStorage option:(NSDictionary *)option{
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
}

@end
