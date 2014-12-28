//
//  IUJSCompiler.m
//  IUEditor
//
//  Created by Joodong Yang on 2014. 11. 14..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUJSCompiler.h"
#import "IUBoxes.h"

#import "JDCode.h"


@implementation IUJSCompiler

- (JDCode *)JSCodeForSheet:(IUSheet *)sheet rule:(NSString*)rule {
    return nil;
}

/* End-line function */

- (NSString *)jsEventFileName:(IUPage *)page{
    return [NSString stringWithFormat:@"%@-event.js", page.name];
}

- (NSString *)jsInitFileName:(IUPage *)page{
    return [NSString stringWithFormat:@"%@-init.js", page.name];
}

-(NSString *)jsInitSource:(IUSheet *)sheet storage:(BOOL)storage{
    
    JDCode *jsCode = [[JDCode alloc] init];
    
    [jsCode addCode:[self defaultInitJSCode:sheet]];
    
    [jsCode addCodeLine:@"$(document).ready(function(){"];
    
    JDCode *objectJSSource = [self jsInitSource_readyJSCode:sheet isEdit:NO];
    [jsCode addCodeWithIndent:objectJSSource];
    
    JDCode *classJSSource = [self jsInitSource_readyJSCodeFromInitForSheet:sheet];
    [jsCode addCodeWithIndent:classJSSource];
    [jsCode addNewLine];
    
    [jsCode addCodeLine:@"});"];
    
    //text media query
    [jsCode addCodeLine:@"function reloadTextMediaQuery(){"];
    if(storage){
        [jsCode addCodeWithIndent:[self jsInitSource_textMQJavascriptCode__storage:sheet]];
    }
    [jsCode addCodeLine:@"}"];
    
    
    //window load code
    [jsCode addCode:[self windowLoadJSCodeFromInitForSheet:sheet]];
    
    return jsCode.string;
}


-(JDCode *)jsInitSource_readyJSCodeFromInitForSheet:(IUSheet *)sheet{
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

-(JDCode *)jsInitSource_readyJSCode:(IUBox *)iu isEdit:(BOOL)isEdit{
    JDCode *code = [[JDCode alloc] init];
    if([iu isKindOfClass:[IUCarousel class]]){
        [code addCodeLine:@"\n"];
        [code addCodeLine:@"/* IUCarousel initialize */\n"];
        [code addCodeLineWithFormat:@"initCarousel('%@')", iu.htmlID];
        for (IUBox *child in iu.children) {
            [code addCodeWithIndent:[self jsInitSource_readyJSCode:child isEdit:isEdit]];
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
            NSAssert(0, @"not yet coded");
            /*
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
             */
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
            [code addCodeWithIndent:[self jsInitSource_readyJSCode:child isEdit:isEdit]];
        }
        
    }
    return code;
}

/*
 
to be removed : mqdata strucutre

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
 */

- (JDCode *)mqCodeForProperty__storage:(NSString *)property inIU:(IUBox *)iu{
    JDCode *code = [[JDCode alloc] init];
    NSDictionary *mqDict = [iu.propertyManager dictionaryWithWidthForKey:property];
    if(mqDict.count > 0){
        [code addCodeLine:@"{"];
        [code increaseIndentLevelForEdit];
        for(NSNumber *width in [mqDict allKeys]){
            [code addCodeLineWithFormat:@"%d:\"%@\",", [width intValue], [mqDict[width] JSEscape]];
            
        }
        [code decreaseIndentLevelForEdit];
        [code addCodeLine:@"}"];
    }
    return code;
}
- (JDCode *)jsInitSource_textMQJavascriptCode__storage:(IUBox *)iu{
    JDCode *code = [[JDCode alloc] init];
    if ([iu isKindOfClass:[IUBox class]]) {
        if([iu.propertyManager countOfValueForKey:@"innerHTML"]){
            [code addCodeLineWithFormat:@"var %@_textMQDict = ", iu.htmlID];
            [code addCode:[self mqCodeForProperty__storage:@"innerHTML" inIU:iu]];
            [code addCodeLineWithFormat:@"var %@_currentText = getCurrentData(%@_textMQDict)", iu.htmlID, iu.htmlID];
            [code addCodeLineWithFormat:@"$('.%@').html(%@_currentText)", iu.htmlID, iu.htmlID];
            
        }
        else{
            for (IUBox *child in iu.children) {
                [code addCode:[self jsInitSource_textMQJavascriptCode__storage:child]];
            }
        }
    }
    
    
    return code;
}
/*
 
 to be removed : mqdata strucutre 
 
 
- (JDCode *)jsInitSource_textMQJavascriptCode:(IUBox *)iu{
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
                [code addCode:[self jsInitSource_textMQJavascriptCode:child]];
            }
        }
    }
    
    
    return code;
}
*/


/**
 Javascript Generation Part
 */

- (NSString *)jsEventSource:(IUPage*)document{
    NSDictionary *variableDict = [document eventVariableDict];
    NSArray *variableArray = [variableDict allKeys];
    
    JDCode *header = [JDCode code];
    JDCode *bodyHeader = [JDCode code];
    JDCode *body = [JDCode code];
    JDCode *visibleFnCode = [JDCode code];
    JDCode *frameFnCode = [JDCode code];
    JDCode *initializeFn = [JDCode code];
    
    for(NSString *variable in variableArray){
        NSDictionary *oneDict = [variableDict objectForKey:variable];
        if(oneDict){
            [header addCodeLineWithFormat:@"var %@=0;", variable];
            
            id value;
#pragma mark initialize variable
            value = [oneDict objectForKey:IUEventTagInitialValue];
            if(value){
                NSInteger initial = [value integerValue];
                [header addCodeLineWithFormat:@"var INIT_IU_%@=%ld;", variable, initial];
                [bodyHeader addCodeLineWithFormat:@"%@ = INIT_IU_%@;", variable, variable];
            }
            
            value = [oneDict objectForKey:IUEventTagMaxValue];
            if(value){
                NSInteger max = [value integerValue];
                [header addCodeLineWithFormat:@"var MAX_IU_%@=%ld;", variable, max];
                
            }
            
#pragma mark make body;
            
            value = [oneDict objectForKey:IUEventTagIUID];
            if(value){
                IUEventActionType type = [[oneDict objectForKey:IUEventTagActionType] intValue];
                
#pragma mark make event innerJS
                NSArray *receiverArray = [oneDict objectForKey:IUEventTagReceiverArray];
                JDCode *innerfunctionCode = [JDCode code];
                
                for(NSDictionary *receiverDict in receiverArray){
#pragma mark Visible Src
                    value = [receiverDict objectForKey:IUEventTagVisibleEquation];
                    if(value){
                        NSString *visibleID = [receiverDict objectForKey:IUEventTagVisibleID];
                        
                        NSString *fnName;
                        if(type == IUEventActionTypeClick){
                            fnName =  [NSString stringWithFormat:@"%@ClickVisible%@Fn", variable, visibleID];
                        }
                        else if(type == IUEventActionTypeHover){
                            fnName =  [NSString stringWithFormat:@"%@HoverVisible%@Fn", variable, visibleID];
                        }
                        [innerfunctionCode addCodeLineWithFormat:@"%@();", fnName];
                        
                        JDCode *fnCode = [JDCode code];
                        NSInteger duration = [[receiverDict objectForKey:IUEventTagVisibleDuration] integerValue];
                        IUEventVisibleType type = [[receiverDict objectForKey:IUEventTagVisibleType] intValue];
                        NSString *typeStr = [self visibleType:type];
                        
                        [fnCode addCodeLineWithFormat:@"if( %@ ){", value];
                        
                        JDCode *innerJS = [JDCode code];
                        [innerJS addCodeLineWithFormat:@"$('.%@').css({'visibility':'initial','display':'none'});", visibleID];
                        [innerJS addCodeWithFormat:@"$(\".%@\").show(", visibleID];
                        NSString *reframe = [NSString stringWithFormat:@"function(){reframeCenterIU('.%@')}", visibleID];
                        
                        if(duration > 0){
                            [innerJS addCodeLineWithFormat:@"\"%@\", %ld, %@);", typeStr, duration*100, reframe];
                        }
                        else{
                            [innerJS addCodeLineWithFormat:@"\"%@\", 1, %@);", typeStr, reframe];
                        }
                        [innerJS addCodeLineWithFormat:@"$(\".%@\").data(\"run%@\", 1);", visibleID, fnName];
                        [innerJS addCode:[self checkForIUGoogleMap:[receiverDict objectForKey:IUEventTagVisibleIU]]];
                        
                        [fnCode addCodeWithIndent:innerJS];
                        [fnCode addCodeLine:@"}"];
                        
                        [fnCode addCodeLine:@"else{"];
                        
                        NSString *visibleString = [NSString stringWithFormat:@"function(){ $('.%@').css({\"visibility\":\"hidden\",\"display\":\"block\"}) }", visibleID];
                        
                        innerJS = [JDCode code];
                        [innerJS addCodeLineWithFormat:@"var clicked =$(\".%@\").data(\"run%@\");", visibleID,fnName];
                        [innerJS addCodeLineWithFormat:@"if(clicked == undefined){"];
                        [innerJS addCodeLineWithFormat:@"\t$(\".%@\").hide(0, %@);", visibleID, visibleString];
                        [innerJS addCodeLine:@"}"];
                        [innerJS addCodeLine:@"else{"];
                        
                        if(duration > 0){
                            [innerJS addCodeLineWithFormat:@"\t$(\".%@\").hide(\"%@\",%ld, %@);", visibleID, typeStr, duration*100, visibleString];
                        }
                        else{
                            [innerJS addCodeLineWithFormat:@"\t$(\".%@\").hide(\"%@\", 1, %@);", visibleID, typeStr, visibleString];
                        }
                        [innerJS addString:@"}"];
                        [fnCode addCodeWithIndent:innerJS];
                        
                        [fnCode addCodeLine:@"}"];
                        
                        [visibleFnCode addCodeLineWithFormat:@"function %@(){", fnName ];
                        [visibleFnCode addCodeWithIndent:fnCode];
                        [visibleFnCode addString:@"}"];
                        
                        
                        
                    }
#pragma mark Frame Src
                    value = [receiverDict objectForKey:IUEventTagFrameEquation];
                    if(value){
                        
                        NSString *frameID = [receiverDict objectForKey:IUEventTagFrameID];
                        
                        NSString *fnName;
                        if(type == IUEventActionTypeClick){
                            fnName =  [NSString stringWithFormat:@"%@ClickVisible%@Fn", variable, frameID];
                        }
                        else if(type == IUEventActionTypeHover){
                            fnName =  [NSString stringWithFormat:@"%@HoverVisible%@Fn", variable, frameID];
                        }
                        
                        [innerfunctionCode addCodeLineWithFormat:@"%@();", fnName];
                        
                        JDCode *fnCode = [JDCode code];
                        [fnCode addCodeLineWithFormat:@"if( %@ ){", value];
                        
                        JDCode *innerJS = [JDCode code];
                        
                        [innerJS addCodeLineWithFormat:@"$(\".%@\").data(\"run%@\", 1);", frameID, fnName];
                        [innerJS addCodeLineWithFormat:@"$(\".%@\").data(\"width\", $(\".%@\").css('width'));", frameID, frameID];
                        [innerJS addCodeLineWithFormat:@"$(\".%@\").data(\"height\", $(\".%@\").css('height'));", frameID, frameID];
                        [innerJS addCodeWithFormat:@"$(\".%@\").animate({", frameID];
                        
                        CGFloat width = [[receiverDict objectForKey:IUEventTagFrameWidth] floatValue];
                        CGFloat height = [[receiverDict objectForKey:IUEventTagFrameHeight] floatValue];
                        [innerJS addCodeWithFormat:@"width:\"%.2fpx\", height:\"%.2fpx\"}", width, height];
                        
                        NSInteger duration = [[receiverDict objectForKey:IUEventTagFrameDuration] integerValue];
                        NSString *reframe = [NSString stringWithFormat:@"function(){reframeCenterIU('.%@')}", frameID];
                        if(duration > 0){
                            [innerJS addCodeWithFormat:@", %ld, %@);", duration*100, reframe];
                        }
                        else{
                            [innerJS addCodeWithFormat:@", 1, %@);", reframe];
                        }
                        [innerJS addCode:[self checkForIUGoogleMap:[receiverDict objectForKey:IUEventTagFrameIU]]];
                        
                        
                        [fnCode addCodeWithIndent:innerJS];
                        
                        [fnCode addCodeLine:@"}"];
                        [fnCode addCodeLine:@"else{"];
                        
                        innerJS = [JDCode code];
                        [innerJS addCodeLineWithFormat:@"var clicked =$(\".%@\").data(\"run%@\");", frameID, fnName];
                        [innerJS addCodeLineWithFormat:@"var d_width =$(\".%@\").data(\"width\");", frameID];
                        [innerJS addCodeLineWithFormat:@"var d_height =$(\".%@\").data(\"height\");", frameID];
                        [innerJS addCodeWithFormat:@"if(clicked == undefined){"];
                        if(duration > 0){
                            [innerJS addCodeLineWithFormat:@"\t$(\".%@\").animate({width:d_width, height:d_height}, %ld);", frameID, duration*100];
                        }
                        else{
                            [innerJS addCodeLineWithFormat:@"\t$(\".%@\").animate({width:d_width, height:d_height}, 1 );", frameID];
                        }
                        [innerJS addCodeLine:@"}"];
                        [innerJS addCodeLine:@"else{"];
                        if(duration > 0){
                            [innerJS addCodeLineWithFormat:@"\t$(\".%@\").animate({width:d_width, height:d_height}, %ld);", frameID, duration*100];
                        }
                        else{
                            [innerJS addCodeLineWithFormat:@"\t$(\".%@\").animate({width:d_width, height:d_height} ,1);", frameID];
                        }
                        [innerJS addString:@"}"];
                        
                        
                        [fnCode addCodeWithIndent:innerJS];
                        
                        [fnCode addCodeLine:@"}"];
                        
                        [frameFnCode addCodeLineWithFormat:@"function %@(){", fnName ];
                        [frameFnCode addCodeWithIndent:fnCode];
                        [frameFnCode addCodeLineWithFormat:@"}"];
                    }
                }//End of receiverArray
                
                [initializeFn addCodeWithIndent:innerfunctionCode];
                
                //initialize source
                JDCode *eventCode = [JDCode code];
                NSArray *bindingIUArray = [oneDict objectForKey:IUEventTagIUID];;
                for(NSString *bindingIUID in bindingIUArray){
                    
                    [eventCode addCodeLineWithFormat:@"/* [IU:%@] Event Declaration */", bindingIUID];
                    if(type == IUEventActionTypeClick){
                        [eventCode addCodeLineWithFormat:@"$(\".%@\").css('cursor', 'pointer');", bindingIUID];
                    }
                    [eventCode addCodeWithFormat:@"$(\".%@\").", bindingIUID];
                    
                    if(type == IUEventActionTypeClick){
                        [eventCode addString:@"click(function(){"];
                    }
                    else if(type == IUEventActionTypeHover){
                        [eventCode addString:@"hover(function(){"];
                    }
                    else{
                        JDFatalLog(@"no action type");
                    }
                    [eventCode increaseIndentLevelForEdit];
                    [eventCode addCodeLineWithFormat:@"%@++;",variable];
                    [eventCode addCodeLineWithFormat:@"if( %@ > MAX_IU_%@ ){ %@ = INIT_IU_%@ }",variable, variable, variable, variable];
                    [eventCode addCodeWithIndent:innerfunctionCode];
                    [eventCode decreaseIndentLevelForEdit];
                    [eventCode addCodeLine:@"});"];
                    
                }
                [body addCodeWithIndent:eventCode];
                
            }
            
        }
        
    }
    
    JDTraceLog(@"header=====\n%@", header.string);
    JDTraceLog(@"body-header=====\n%@", bodyHeader.string);
    JDTraceLog(@"body======\n%@", body.string);
    
    JDCode *eventJSCode = [JDCode code];
    [eventJSCode addCodeWithIndent:header];
    
    [eventJSCode addCodeLine:@" /* Decleare Visible Fn */ "];
    [eventJSCode addCodeWithIndent:visibleFnCode];
    [eventJSCode addNewLine];
    
    [eventJSCode addCodeLine:@" /* Decleare Frame Fn */ "];
    [eventJSCode addCodeWithIndent:frameFnCode];
    
    [eventJSCode addCodeLine:@"$(document).ready(function(){"];
    [eventJSCode increaseIndentLevelForEdit];
    
    [eventJSCode addCodeLine:@"console.log('ready : iuevent.js');"];
    [eventJSCode addCodeWithIndent:bodyHeader];
    [eventJSCode addCodeWithIndent:body];
    [eventJSCode addCodeLine:@" /* initialize fn */ "];
    [eventJSCode addCodeWithIndent:initializeFn];
    
    [eventJSCode decreaseIndentLevelForEdit];
    
    [eventJSCode addCodeLine:@"});"];
    
    JDTraceLog(@"total======\n%@", eventJSCode.string);
    
    return eventJSCode.string;
}


#pragma mark visible event
- (NSString *)visibleType:(IUEventVisibleType)type{
    NSString *typeStr;
    switch (type) {
        case IUEventVisibleTypeBlind:
            typeStr = @"blind";
            break;
        case IUEventVisibleTypeBounce:
            typeStr = @"bounce";
            break;
        case IUEventVisibleTypeClip:
            typeStr = @"clip";
            break;
        case IUEventVisibleTypeDrop:
            typeStr = @"drop";
            break;
        case IUEventVisibleTypeExplode:
            typeStr = @"explode";
            break;
        case IUEventVisibleTypeFold:
            typeStr = @"fold";
            break;
        case IUEventVisibleTypeHide:
            typeStr = @"hide";
            break;
        case IUEventVisibleTypeHighlight:
            typeStr = @"highlight";
            break;
        case IUEventVisibleTypePuff:
            typeStr = @"puff";
            break;
        case IUEventVisibleTypePulsate:
            typeStr = @"pulsate";
            break;
        case IUEventVisibleTypeScale:
            typeStr = @"scale";
            break;
        case IUEventVisibleTypeShake:
            typeStr = @"shake";
            break;
        case IUEventVisibleTypeSize:
            typeStr = @"size";
            break;
        case IUEventVisibleTypeSlide:
            typeStr = @"slide";
            break;
        default:
            typeStr = nil;
            break;
    }
    
    return typeStr;
}

- (JDCode *)checkForIUGoogleMap:(IUBox *)iu{
    JDCode *code = [[JDCode alloc] init];
    
    NSArray *array = [[NSArray arrayWithObject:iu] arrayByAddingObjectsFromArray:iu.allChildren];
    
    for(IUBox *box in array){
        if([box isKindOfClass:[IUGoogleMap class]]){
            //redraw
            IUGoogleMap *map = (IUGoogleMap *)box;
            [code addCodeLineWithFormat:@"var center = new google.maps.LatLng(%@, %@);", map.latitude, map.longitude];
            [code addCodeLineWithFormat:@"google.maps.event.trigger(map_%@, 'resize');", map.htmlID];
            [code addCodeLineWithFormat:@"map_%@.setCenter(center);", map.htmlID];
        }
    }
    
    return code;
}


@end
