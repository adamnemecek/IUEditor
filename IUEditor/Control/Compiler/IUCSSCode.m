//
//  IUCSSCode.m
//  IUEditor
//
//  Created by Joodong Yang on 2014. 11. 7..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUCSSCode.h"
#import "IUDataStorage.h"

@interface IUCSSCode() {
    IUTarget _currentTarget;
    int _currentViewPort;
    NSArray *_currentIdentifiers;
    NSMutableDictionary *_editorCSSDictWithViewPort; // data = key:width
    NSMutableDictionary *_outputCSSDictWithViewPort; // data = key:width
    NSArray *allViewports;
    NSString *_mainIdentifier;
    
    NSMutableDictionary *_identifierTypeDictionary;
}

@end


@implementation IUCSSCode

- (id)init{
    self = [super init];
    if (self) {
        _editorCSSDictWithViewPort = [NSMutableDictionary dictionary];
        _outputCSSDictWithViewPort = [NSMutableDictionary dictionary];
        _identifierTypeDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}


- (void)setInsertingTarget:(IUTarget)target{
    _currentTarget = target;
}

- (void)setInsertingViewPort:(int)viewport{
    _currentViewPort = viewport;
}

- (void)setInsertingIdentifier:(NSString *)identifier{
    [self setInsertingIdentifier:identifier withType:IUCSSIdentifierTypeInline];
}

- (void)setInsertingIdentifier:(NSString *)identifier withType:(IUCSSIdentifierType)type{
    _currentIdentifiers = @[[identifier copy]];
    if(_identifierTypeDictionary[identifier] == nil){
        _identifierTypeDictionary[identifier] = @(type);
    }
}

- (void)setMainIdentifier:(NSString *)identifier {
    _mainIdentifier = [identifier copy];
    
    if(_identifierTypeDictionary[identifier] == nil){
        _identifierTypeDictionary[identifier] = @(IUCSSIdentifierTypeInline);
    }
}

- (void)setInsertingIdentifiers:(NSArray *)identifiers{
    [self setInsertingIdentifiers:identifiers withType:IUCSSIdentifierTypeInline];
}

- (void)setInsertingIdentifiers:(NSArray *)identifiers withType:(IUCSSIdentifierType)type{
    _currentIdentifiers = [[NSArray alloc] initWithArray:identifiers copyItems:YES];
    for(NSString *identifier in identifiers){
        if(_identifierTypeDictionary[identifier] == nil){
            _identifierTypeDictionary[identifier] = @(type);
        }
    }
}

- (int)insertingViewPort{
    return _currentViewPort;
}

- (NSArray*)allIdentifiers{
    NSMutableArray *returnIdentifiers = [NSMutableArray array];
    NSArray *viewPortDatas = [_editorCSSDictWithViewPort allValues];
    for (NSDictionary *dict in viewPortDatas) {
        NSArray *identifierKeys = [dict allKeys];
        for (NSString *identifier in identifierKeys) {
            if ([returnIdentifiers containsObject:identifier] == NO) {
                [returnIdentifiers addObject:identifier];
            }
        }
    }
    
    viewPortDatas = [_outputCSSDictWithViewPort allValues];
    for (NSDictionary *dict in viewPortDatas) {
        NSArray *identifierKeys = [dict allKeys];
        for (NSString *identifier in identifierKeys) {
            if ([returnIdentifiers containsObject:identifier] == NO) {
                [returnIdentifiers addObject:identifier];
            }
        }
    }
    return [returnIdentifiers copy];
}


- (NSMutableDictionary*)tagDictionaryWithTarget:(IUTarget)target viewport:(int)viewport identifier:(NSString*)identifier{
    if (target == IUTargetEditor) {
        return [[_editorCSSDictWithViewPort objectForKey:@(viewport)] objectForKey:identifier];
    }
    else if (target == IUTargetOutput){
        return [[_outputCSSDictWithViewPort objectForKey:@(viewport)] objectForKey:identifier];
    }
    else {
        NSAssert(0, @"Cannot be IUTarget Both");
        return nil;
    }
}

/*

- (NSArray* )minusInlineTagSelector:(IUCSSCode *)code{
    NSMutableDictionary *dict = [[self inlineTagDictiony] mutableCopy];
    NSDictionary *minusDict = [code inlineTagDictiony];
    [minusDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [dict removeObjectForKey:key];
    }];
    return [dict allKeys];
}

- (NSArray *)minusNonInlineSelector:(IUCSSCode *)code{
    NSMutableDictionary *dict = [[self nonInlineTagDictionary] mutableCopy];
    NSDictionary *minusDict = [code nonInlineTagDictionary];
    [minusDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [dict removeObjectForKey:key];
    }];
    return [dict allKeys];
}
 
 */


/**
 insert css tag to receiver
 */

- (void)insertTag:(NSString*)tag color:(NSColor*)color{
    if (color == nil) {
        color = [NSColor blackColor];
    }
    //make it as RGB base.
    //Checking by -colorSpace raises an exception if the receiver is not based on a color space represented by an NSColorSpace object; see NSColor document
    color = [color colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
    
    NSString *colorString = [NSString stringWithFormat:@"%@; /* fallback */ %@: %@",[color rgbString], tag, [color rgbaString]];
    [self insertTag:tag string:colorString];
    
}

- (void)insertTag:(NSString*)tag string:(NSString*)stringValue{
    [self insertTag:tag string:stringValue target:_currentTarget];
}

- (void)insertTag:(NSString*)tag string:(NSString*)stringValue target:(IUTarget)target{
    if (target & IUTargetEditor ) {
        NSMutableDictionary *cssDictWithIdentifier = _editorCSSDictWithViewPort[@(_currentViewPort)];
        if (cssDictWithIdentifier == nil) { //does not have view port, so make new one
            _editorCSSDictWithViewPort[@(_currentViewPort)] = [NSMutableDictionary dictionary];
            _outputCSSDictWithViewPort[@(_currentViewPort)] = [NSMutableDictionary dictionary];
            cssDictWithIdentifier = _editorCSSDictWithViewPort[@(_currentViewPort)];
            [self updateViewports];
        }
        for (NSString *identifier in _currentIdentifiers) {
            NSMutableDictionary *tagDictionary = cssDictWithIdentifier[identifier];
            if (tagDictionary == nil) {
                tagDictionary = [NSMutableDictionary dictionary];
                cssDictWithIdentifier[identifier] = tagDictionary;
            }
            tagDictionary[tag] = [stringValue copy];
        }
    }
    if (target & IUTargetOutput ) {
        NSMutableDictionary *cssDictWithIdentifier = _outputCSSDictWithViewPort[@(_currentViewPort)];
        if (cssDictWithIdentifier == nil) { //does not have view port, so make new one
            _editorCSSDictWithViewPort[@(_currentViewPort)] = [NSMutableDictionary dictionary];
            _outputCSSDictWithViewPort[@(_currentViewPort)] = [NSMutableDictionary dictionary];
            cssDictWithIdentifier = _outputCSSDictWithViewPort[@(_currentViewPort)];
            [self updateViewports];
        }
        for (NSString *identifier in _currentIdentifiers) {
            NSMutableDictionary *tagDictionary = cssDictWithIdentifier[identifier];
            if (tagDictionary == nil) {
                tagDictionary = [NSMutableDictionary dictionary];
                cssDictWithIdentifier[identifier] = tagDictionary;
            }
            tagDictionary[tag] = [stringValue copy];
        }
    }
}

- (void)insertTag:(NSString*)tag floatFromNumber:(NSNumber*)floatNumber{
    [self insertTag:tag floatFromNumber:floatNumber unit:IUUnitNone];
}

- (void)insertTag:(NSString*)tag floatFromNumber:(NSNumber*)floatNumber unit:(IUUnit)unit{
    if (floatNumber) {
        if ([floatNumber intValue] == [floatNumber floatValue]) {
            [self insertTag:tag integer:[floatNumber intValue] unit:unit];
        }
        else {
            [self insertTag:tag floatValue:[floatNumber floatValue] unit:unit];
        }
    }
}

- (void)insertTag:(NSString*)tag number:(NSNumber*)number unit:(IUUnit)unit{
    if (number) {
        if ([number intValue] == [number floatValue]) {
            [self insertTag:tag integer:[number intValue] unit:unit];
        }
        else {
            [self insertTag:tag floatValue:[number floatValue] unit:unit];
        }
    }
}



- (void)insertTag:(NSString*)tag number:(NSNumber*)number frameUnit:(NSNumber *)frameUnit{
    if (number) {
        if ([number intValue] == [number floatValue]) {
            [self insertTag:tag integer:[number intValue] frameUnit:[frameUnit intValue]];
        }
        else {
            [self insertTag:tag floatValue:[number floatValue] frameUnit:[frameUnit intValue]];
        }
    }
}


- (void)insertTag:(NSString*)tag floatValue:(CGFloat)value frameUnit:(IUFrameUnit)frameUnit{
    NSString *unitString;
    switch (frameUnit) {
        case IUFrameUnitPercent: unitString = @"%"; break;
        case IUFrameUnitPixel: unitString = @"px"; break;
    }
    NSString *stringValue = [NSString stringWithFormat:@"%.2f%@",  value , unitString];
    [self insertTag:tag string:stringValue];
    
}

- (void)insertTag:(NSString*)tag integer:(int)integer frameUnit:(IUFrameUnit)frameUnit{
    NSString *unitString;
    switch (frameUnit) {
        case IUFrameUnitPercent: unitString = @"%"; break;
        case IUFrameUnitPixel: unitString = @"px"; break;
    }
    NSString *stringValue = [NSString stringWithFormat:@"%d%@", integer , unitString];
    [self insertTag:tag string:stringValue];
    
}



- (void)insertTag:(NSString*)tag floatValue:(CGFloat)value unit:(IUUnit)unit{
    NSString *unitString;
    switch (unit) {
        case IUUnitPercent: unitString = @"%"; break;
        case IUUnitPixel: unitString = @"px"; break;
        case IUUnitNone: unitString = @""; break;
    }
    NSString *stringValue = [NSString stringWithFormat:@"%.2f%@",  value , unitString];
    [self insertTag:tag string:stringValue];
    
}
- (void)insertTag:(NSString*)tag intFromNumber:(NSNumber*)intNumber{
    if(intNumber){
        [self insertTag:tag intFromNumber:intNumber unit:IUUnitNone];
    }
}

- (void)insertTag:(NSString*)tag intFromNumber:(NSNumber*)intNumber unit:(IUUnit)unit{
    [self insertTag:tag integer:[intNumber intValue] unit:unit];
}

- (void)insertTag:(NSString*)tag integer:(int)number unit:(IUUnit)unit{
    NSString *unitString;
    switch (unit) {
        case IUUnitPercent: unitString = @"%"; break;
        case IUUnitPixel: unitString = @"px"; break;
        case IUUnitNone: unitString = @""; break;
    }
    NSString *stringValue = [NSString stringWithFormat:@"%d%@", number , unitString];
    [self insertTag:tag string:stringValue];
}

- (NSString*)valueForTag:(NSString*)tag identifier:(NSString*)identifier largerThanViewport:(int)viewport target:(IUTarget)target{
    
    NSString* valueForOutput = nil;
    NSString* valueForEditor = nil;
    if (_currentTarget == IUTargetEditor) {
        for (NSNumber *currentViewport in self.allViewports) {
            if ([currentViewport intValue] <= viewport) {
                break;
            }
            if (_editorCSSDictWithViewPort[currentViewport][identifier][tag]) {
                valueForEditor = _editorCSSDictWithViewPort[@(IUCSSDefaultViewPort)][identifier][tag];
            }
        }
        return valueForEditor;
    }
    else if (_currentTarget == IUTargetOutput) {
        for (NSNumber *currentViewport in self.allViewports) {
            if ([currentViewport intValue] <= viewport) {
                break;
            }
            if (_outputCSSDictWithViewPort[currentViewport][identifier][tag]) {
                valueForOutput = _outputCSSDictWithViewPort[@(IUCSSDefaultViewPort)][identifier][tag];
            }
        }
        return valueForOutput;
    }
    else {
        for (NSNumber *currentViewport in self.allViewports) {
            if ([currentViewport intValue] <= viewport) {
                break;
            }
            if (_outputCSSDictWithViewPort[currentViewport][identifier][tag]) {
                valueForOutput = _outputCSSDictWithViewPort[@(IUCSSDefaultViewPort)][identifier][tag];
            }
            if (_editorCSSDictWithViewPort[currentViewport][identifier][tag]) {
                valueForEditor = _editorCSSDictWithViewPort[@(IUCSSDefaultViewPort)][identifier][tag];
            }
        }
        if ([valueForEditor isEqualToString:valueForOutput]) {
            return valueForEditor;
        }
        return nil;
    }
}


- (void)updateViewports{
    NSArray *widthsOne = [[_editorCSSDictWithViewPort allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSArray *widthsTwo = [[_outputCSSDictWithViewPort allKeys] sortedArrayUsingSelector:@selector(compare:)];
    if ([widthsOne isEqualToArray:widthsTwo]) {
        allViewports = [widthsOne reversedArray];
        return;
    }
    NSAssert (0, @"Two widths should be equal");
}

- (NSArray*)allViewports{
    return allViewports;
}

- (NSDictionary*)stringTagDictionaryWithIdentifier_storage:(IUTarget)target viewPort:(int)viewPort{
    if (target == IUTargetEditor) {
        /* make live storage by inheritance */
        NSMutableDictionary *returnDict = [NSMutableDictionary dictionary];
        
        for ( NSNumber *currentViewPort in allViewports ){
            if ([currentViewPort intValue] < viewPort) {
                break;
            }
            NSDictionary *sourceDict = _editorCSSDictWithViewPort[@(viewPort)];
            [sourceDict enumerateKeysAndObjectsUsingBlock:^(id key, NSDictionary* obj, BOOL *stop) {
                /* make source */
                returnDict[key] = [obj CSSCode];
            }];
        }
        return returnDict;
    }
    return nil;
}

- (NSDictionary*)stringTagDictionaryWithIdentifier:(int)viewport{
    NSMutableDictionary *returnDict = [NSMutableDictionary dictionary];
    NSDictionary *sourceDictWithViewPort = _editorCSSDictWithViewPort;
    NSDictionary *sourceDictWithIdentifier = sourceDictWithViewPort[@(IUCSSDefaultViewPort)];
    
    NSMutableSet *allKeys =  [NSMutableSet setWithArray:[sourceDictWithViewPort[@(IUCSSDefaultViewPort)] allKeys]];
    if(viewport != IUCSSDefaultViewPort){
        [allKeys addObjectsFromArray:[sourceDictWithViewPort[@(viewport)] allKeys]];
    }
    
    for (NSString *identifier in allKeys.allObjects) {
        NSDictionary *tagDict = sourceDictWithIdentifier[identifier];
        NSMutableDictionary *tagDictForReturn = [NSMutableDictionary dictionary];
        
        
        //TODO: optimize;
        //Review:defaultcss
        for (NSString *tag in tagDict) {
            NSString *value = tagDict[tag];
            //Review:
            // element에 style속성으로 지정하기 때문에 무조건 들어가야함.
            tagDictForReturn[tag] = value;
        }
        
        if(viewport != IUCSSDefaultViewPort){
            //viewport css
            tagDict = [sourceDictWithViewPort[@(viewport)] objectForKey:identifier];
            for (NSString *tag in tagDict) {
                NSString *value = tagDict[tag];
                //Review:
                // element에 style속성으로 지정하기 때문에 무조건 들어가야함.
                tagDictForReturn[tag] = value;
            }
        }
        
        if([identifier containsString:@"hover"]){
            NSString *cssCode = [[tagDictForReturn hoverCSSCode] stringByReplacingOccurrencesOfString:@".00px" withString:@"px"];
            [returnDict setObject:[cssCode stringByTrim] forKey:identifier];
        }
        else{
            NSString *cssCode = [[tagDictForReturn CSSCode] stringByReplacingOccurrencesOfString:@".00px" withString:@"px"];
            [returnDict setObject:[cssCode stringByTrim] forKey:identifier];
        }
    }
    
    
    
    return returnDict;
}

- (NSDictionary*)stringTagDictionaryWithIdentifierForTarget:(IUTarget)target viewPort:(int)viewport{
    NSAssert(0, @"not yet coded");
    return nil;
}

- (NSDictionary*)stringTagDictionaryWithIdentifierForOutputViewport:(int)viewport{
    
    NSMutableDictionary *returnDict = [NSMutableDictionary dictionary];
    NSDictionary *sourceDictWithViewPort = _outputCSSDictWithViewPort;
    NSDictionary *sourceDictWithIdentifier = sourceDictWithViewPort[@(viewport)];
    
    
    for (NSString *identifier in sourceDictWithIdentifier) {
        NSDictionary *tagDict = sourceDictWithIdentifier[identifier];
        NSMutableDictionary *tagDictForReturn = [NSMutableDictionary dictionary];
        
        for (NSString *tag in tagDict) {
            NSString *value = tagDict[tag];
            //Review:
            // style sheet가 min-max로 바뀌면서 defalut랑 다르면 무조건 들어가야함.
            if(viewport != IUCSSDefaultViewPort){
                NSString *defaultValue = [self valueForTag:tag identifier:identifier viewport:IUCSSDefaultViewPort target:IUTargetOutput];
                if ([value isEqualToString:defaultValue] == NO) {
                    tagDictForReturn[tag] = value;
                }
            }
            else{
                if ([tag isEqualToString:@"display"] && [value isEqualToString:@"inherit"]) {
                    continue;
                }
                if ([tag containsString:@"border"]) {
                    if ([tag containsString:@"width"] && [value isEqualToString:@"0.00px"]) {
                        continue;
                    }
                    if ([tag containsString:@"color"] && [value containsString:@"rgba(0,0,0,1.00)"]) {
                        continue;
                    }
                }
                if ([tag isEqualToString:@"background-repeat"] && [value containsString:@"no-repeat"]) {
                    continue;
                }
                if ([tag isEqualToString:@"display"] && [value isEqualToString:@"inherit"]) {
                    continue;
                }
                tagDictForReturn[tag] = value;
            }
        }
        NSString *cssCode = [[tagDictForReturn CSSCode] stringByReplacingOccurrencesOfString:@".00px" withString:@"px"];
        [returnDict setObject:cssCode forKey:identifier];
    }
    
    return returnDict;
}

- (NSString*)valueForTag:(NSString *)tag identifier:(NSString *)identifier viewport:(int)viewport target:(IUTarget)target{
    NSAssert(target != IUTargetBoth, @"target cannot be both");
    if (target == IUTargetOutput) {
        return _outputCSSDictWithViewPort[@(viewport)][identifier][tag];
    }
    else if (target == IUTargetEditor){
        return _editorCSSDictWithViewPort[@(viewport)][identifier][tag];
    }
    else return nil;
}

- (void)removeTag:(NSString*)tag identifier:(NSString*)identifier{
    for (NSMutableDictionary *dictWithIdentifier in [_editorCSSDictWithViewPort allValues]) {
        NSMutableDictionary *tagDict = [dictWithIdentifier objectForKey:identifier];
        [tagDict removeObjectForKey:tag];
    }
    for (NSMutableDictionary *dictWithIdentifier in [_outputCSSDictWithViewPort allValues]) {
        NSMutableDictionary *tagDict = [dictWithIdentifier objectForKey:identifier];
        [tagDict removeObjectForKey:tag];
    }
}

- (void)removeTag:(NSString*)tag identifier:(NSString*)identifier viewport:(NSInteger)viewport{
    
    NSDictionary *dictWithIdentifier = _editorCSSDictWithViewPort[@(viewport)];
    if(dictWithIdentifier){
        NSMutableDictionary *tagDict = [dictWithIdentifier objectForKey:identifier];
        [tagDict removeObjectForKey:tag];
    }
    
    dictWithIdentifier = _outputCSSDictWithViewPort[@(viewport)];
    if(dictWithIdentifier){
        NSMutableDictionary *tagDict = [dictWithIdentifier objectForKey:identifier];
        [tagDict removeObjectForKey:tag];
    }
    
}

- (void)renameIdentifier:(NSString*)fromIdentifier to:(NSString*)toIdentifier{
    if(_currentTarget == IUTargetEditor || _currentTarget == IUTargetBoth){
        [_editorCSSDictWithViewPort enumerateKeysAndObjectsUsingBlock:^(id key, NSMutableDictionary* identifierDict, BOOL *stop) {
            NSDictionary *copyDict = [identifierDict copy];
            [copyDict enumerateKeysAndObjectsUsingBlock:^(NSString* identifier, id obj, BOOL *stop) {
                if ([identifier isEqualToString:fromIdentifier]){
                    identifierDict[toIdentifier] = copyDict[identifier];
                    [identifierDict removeObjectForKey:identifier];
                    *stop = YES;
                }
            }];
        }];
    }
    if(_currentTarget == IUTargetOutput || _currentTarget == IUTargetBoth){
        [_outputCSSDictWithViewPort enumerateKeysAndObjectsUsingBlock:^(id key, NSMutableDictionary* identifierDict, BOOL *stop) {
            NSDictionary *copyDict = [identifierDict copy];
            [copyDict enumerateKeysAndObjectsUsingBlock:^(NSString* identifier, id obj, BOOL *stop) {
                if ([identifier isEqualToString:fromIdentifier]){
                    identifierDict[toIdentifier] = copyDict[identifier];
                    [identifierDict removeObjectForKey:identifier];
                    *stop = YES;
                }
            }];
        }];
    }
}


- (NSDictionary *)inlineTagDictionyForViewport:(int)viewport{ // css for inline insertion ( for example, main css )

    //내부 구조까지 같이 바꿀 필요가 있어보임 viewport가 두번들어오게됨.
    //한번에 호출가능하도록?
    NSDictionary *dict = [self stringTagDictionaryWithIdentifier_storage:IUTargetEditor viewPort:viewport];
    NSMutableDictionary *inlinedict = [NSMutableDictionary dictionary];
    
    for(NSString *identifier in [dict allKeys]){
        if([_identifierTypeDictionary[identifier] intValue] == IUCSSIdentifierTypeInline){
            inlinedict[identifier] = dict[identifier];
        }
    }
    
    return [inlinedict copy];
}
- (NSDictionary *)nonInlineTagDictionaryForViewport:(int)viewport{ // css for non-inline insertion (for example, hover or active )
    NSDictionary *dict = [self stringTagDictionaryWithIdentifier_storage:IUTargetEditor viewPort:viewport];
    NSMutableDictionary *inlinedict = [NSMutableDictionary dictionary];
    
    for(NSString *identifier in [dict allKeys]){
        if([_identifierTypeDictionary[identifier] intValue] == IUCSSIdentifierTypeNonInline){
            inlinedict[identifier] = dict[identifier];
        }
    }
    
    return [inlinedict copy];
}

/* uses inline code for IUDefaultViewPort and defaultIdentifier */
- (NSString *)mainIdentifier {
    return _mainIdentifier;
}

- (NSString *)stringCodeWithMainIdentifieForTarget:(IUTarget)target viewPort:(int)viewport{
    if (target == IUTargetEditor) {
        return _editorCSSDictWithViewPort[@(viewport)][self.mainIdentifier];
    }
    else {
        return _outputCSSDictWithViewPort[@(viewport)][self.mainIdentifier];
    }
}


@end
