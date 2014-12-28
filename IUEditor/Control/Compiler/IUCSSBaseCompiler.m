//
//  IUCSSBaseCompiler.m
//  IUEditor
//
//  Created by Joodong Yang on 2014. 12. 18..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUCSSBaseCompiler.h"
#import "IUProjectProtocol.h"
#import "IUFontController.h"

@implementation IUCSSBaseCompiler

- (IUCSSCode*)cssCodeForIUBox:(IUBox*)iu target:(IUTarget)target viewPort:(NSInteger)viewPort option:(NSDictionary *)option {
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
        
        IUActionStorage *actionStorage = (iu.positionManager.currentViewPort == viewPort) ? iu.actionManager.cascadingStorage : [[iu actionManager] cascadingStorageForViewPort:viewPort];
        [self updateCSSHoverCode:code IU:iu actionStorage:actionStorage option:option];
        
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
        //NSAssert(0, @"NOT YET CODED");
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
            
            NSString *standardDirection, *webkitDirection, *mozDirection, *ieDirection;
            IUStyleColorDirection direction = [styleStorage.bgColorDirection intValue];
            switch (direction) {
                case IUStyleColorDirectionVertical:
                    webkitDirection = @"top";
                    standardDirection = @"to bottom";
                    mozDirection = @"bottom";
                    ieDirection = @"0";
                    break;
                case IUStyleColorDirectionHorizontal:
                    webkitDirection = @"left";
                    standardDirection = @"to right";
                    mozDirection = @"right";
                    ieDirection = @"1";
                    break;
                case IUStyleColorDirectionLeftTop:
                    webkitDirection = @"left top";
                    standardDirection = @"to bottom right";
                    mozDirection = @"bottom right";
                    ieDirection = @"0";
                    break;
                case IUStyleColorDirectionRightTop:
                    webkitDirection = @"right top";
                    standardDirection = @"to bottom left";
                    mozDirection = @"bottom left";
                    //FIXME : ieDirection
                    ieDirection = @"0";
                    break;
                default:
                    break;
            }
            
            NSString *colorString = [NSString stringWithFormat:@"%@, %@", [styleStorage.bgColor1 rgbaString], [styleStorage.bgColor2 rgbaString]];

            NSString *webKitStr = [NSString stringWithFormat:@"-webkit-linear-gradient(%@, %@)",webkitDirection, colorString];
            NSString *mozStr = [NSString stringWithFormat:@"-moz-linear-gradient(%@, %@)", mozDirection, colorString];
            NSString *standardStr = [NSString stringWithFormat:@"linear-gradient(%@, %@)",standardDirection, colorString];

            NSString *ieStr = [NSString stringWithFormat:@"filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='%@', endColorstr='%@', GradientType=%@)", styleStorage.bgColor1.rgbStringWithTransparent, styleStorage.bgColor2.rgbStringWithTransparent, ieDirection];
            
            NSString *gradientStr = [webKitStr stringByAppendingFormat:@"; background:%@ ; background:%@; %@", mozStr, standardStr, ieStr];
            [code setInsertingTarget:IUTargetOutput];
            [code insertTag:@"background" string:gradientStr];
            
            [code setInsertingTarget:IUTargetEditor];
            [code insertTag:@"background" string:standardStr];

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
        
         NSString *fontFamily = [[IUFontController sharedFontController] cssForFontName:styleStorage.fontName];
         if(fontFamily){
             [code insertTag:@"font-family" string:fontFamily];
         }
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
        NSNumber *weightNumber;
        if([styleStorage.fontWeight isEqualToNumber:[NSNumber numberWithInteger:0]]){
            weightNumber = [NSNumber numberWithInteger:300];
        }
        else if([styleStorage.fontWeight isEqualToNumber:[NSNumber numberWithInteger:1]]){
            weightNumber = [NSNumber numberWithInteger:400];
        }
        else if([styleStorage.fontWeight isEqualToNumber:[NSNumber numberWithInteger:2]]){
            weightNumber = [NSNumber numberWithInteger:700];
        }
        if(weightNumber){
            [code insertTag:@"font-weight" number:weightNumber];
        }
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
        //border width
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
        
        //border color
        if (styleStorage.borderColor) {
            if(styleStorage.borderColor == NSMultipleValuesMarker){
                if(styleStorage.topBorderColor){
                    [code insertTag:@"border-top-color" color:styleStorage.topBorderColor];
                }
                else{
                    [code insertTag:@"border-top-color" color:[NSColor blackColor]];
                }
                if(styleStorage.bottomBorderColor){
                    [code insertTag:@"border-bottom-color" color:styleStorage.bottomBorderColor];
                }
                else{
                    [code insertTag:@"border-bottom-color" color:[NSColor blackColor]];
                }
                if(styleStorage.leftBorderColor){
                    [code insertTag:@"border-left-color" color:styleStorage.leftBorderColor];
                }
                else{
                    [code insertTag:@"border-left-color" color:[NSColor blackColor]];
                }
                if(styleStorage.rightBorderColor){
                    [code insertTag:@"border-right-color" color:styleStorage.rightBorderColor];
                }
                else{
                    [code insertTag:@"border-right-color" color:[NSColor blackColor]];
                }
                
            }
            else{
                [code insertTag:@"border-color" color:styleStorage.borderColor];
            }
        }
        else{
            [code insertTag:@"border-color" color:[NSColor blackColor]];
        }
        
        //border style
        IUStyleBorderType borderType = [styleStorage.borderType intValue];
        NSString *borderStyle;
        switch (borderType) {
            case IUStyleBorderTypeSolid:
                break;
            case IUStyleBorderTypeDashed:
                borderStyle = @"dashed";
                break;
            case IUStyleBorderTypeDotted:
                borderStyle = @"dotted";
                break;
                
            default:
                break;
        }
        if(borderStyle){
            [code insertTag:@"border-style" string:borderStyle];
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
        if(styleStorage.shadowColor == nil){
            colorString = [[NSColor blackColor] rgbString];
        }
        
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

- (void)updateCSSHoverCode:(IUCSSCode*)code IU:(IUBox *)iu actionStorage:(IUActionStorage *)actionStorage option:(NSDictionary *)option{
    
    
    /* notice
     hover class의 경우에는 cascading order 에 의하여 inline이 더 나중에 적용하게 되기 때문에 editor모드에서는 important를 붙여서 사용하도록 한다.
     */
    [code setInsertingIdentifier:iu.cssHoverClass withType:IUCSSIdentifierTypeNonInline];
    //css has color or image
    if(actionStorage.hoverBGPositionX || actionStorage.hoverBGPositionY){
        if(actionStorage.hoverBGPositionX){
            [code setInsertingTarget:IUTargetOutput];
            [code insertTag:@"background-position-x" number:actionStorage.hoverBGPositionX unit:IUUnitPixel];
            [code setInsertingTarget:IUTargetEditor];
            [code insertTag:@"background-position-x" string:[NSString stringWithFormat:@"%ldpx !important", [actionStorage.hoverBGPositionX integerValue]]];


        }
        if(actionStorage.hoverBGPositionY){
            [code setInsertingTarget:IUTargetOutput];
            [code insertTag:@"background-position-y" number:actionStorage.hoverBGPositionY unit:IUUnitPixel];
            [code setInsertingTarget:IUTargetEditor];
            [code insertTag:@"background-position-y" string:[NSString stringWithFormat:@"%ldpx !important", [actionStorage.hoverBGPositionY integerValue]]];

        }
    }
    else if(actionStorage.hoverBGColor){
        NSString *outputColor = [actionStorage.hoverBGColor cssBGColorString];
        NSString *editorColor = [actionStorage.hoverBGColor rgbaString];
        if ([outputColor length] == 0) {
            outputColor = @"black";
            editorColor = @"black";
        }
        
        [code setInsertingTarget:IUTargetOutput];
        [code insertTag:@"background-color" string:outputColor];
        
        [code setInsertingTarget:IUTargetEditor];
        [code insertTag:@"background-color" string:[editorColor stringByAppendingString:@" !important"]];
        
    }
    
    if(actionStorage.hoverTextColor){
        [code setInsertingTarget:IUTargetOutput];
        [code insertTag:@"color" color:actionStorage.hoverTextColor];
        [code setInsertingTarget:IUTargetEditor];
        [code insertTag:@"color" string:[[actionStorage.hoverTextColor rgbaString] stringByAppendingString:@" !important"]];

    }
    
    
    /* hover code 이긴 하지만, in-out에 동작하려면 cssidentifier 로 들어가야함. hoverIdentifier로는 in에만 duration이 적용 */
    [code setInsertingIdentifier:iu.cssIdentifier];
    if(actionStorage.hoverBGDuration || actionStorage.hoverTextDuration){
        NSMutableString *timeStr = [NSMutableString string];
        if(actionStorage.hoverBGDuration){
            [timeStr appendString:[NSString stringWithFormat:@" background-color %lds ", [actionStorage.hoverBGDuration integerValue]]];
        }
        if(actionStorage.hoverBGDuration && actionStorage.hoverTextDuration){
            [timeStr appendString:@","];
        }
        if(actionStorage.hoverTextDuration){
            [timeStr appendString:[NSString stringWithFormat:@" color %lds ", [actionStorage.hoverTextDuration integerValue]]];
        }
        
        [code setInsertingTarget:IUTargetEditor];
        [code insertTag:@"transition" string:timeStr];

        [code setInsertingTarget:IUTargetOutput];
        NSString *webKitStr = [NSString stringWithFormat:@"-webkit-transition:%@", timeStr];
        NSString *baseStr = [NSString stringWithFormat:@"%@; %@", timeStr, webKitStr];
        [code insertTag:@"transition" string:baseStr];
        
        [code setInsertingTarget:IUTargetBoth];
    }

}


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
        [code insertTag:@"opacity" number:styleStorage.opacity unit:IUUnitNone];
        
        [code setInsertingTarget:IUTargetOutput];
        [code insertTag:@"filter" string:[NSString stringWithFormat:@"alpha(opacity=%.0f)",[styleStorage.opacity floatValue]*100] ];
        
        [code setInsertingTarget:IUTargetBoth];
    }
}

@end
