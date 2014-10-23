//
//  IUCSS.m
//  IUEditor
//
//  Created by JD on 3/17/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUCSS.h"
#import "JDUIUtil.h"
#import "IUProject.h"

@interface IUCSS ()
@property NSMutableDictionary *cssDictWithViewPort;
@property (readwrite) NSMutableDictionary *effectiveTagDictionaryForEditWidth;
@end

@implementation IUCSS{
}


-(NSArray*)allViewports{
    NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self" ascending: NO];
    //FIXME: max가 바뀔때 frame이 제대로 동작안하는것 같음
    //상태 1280이 맥시멈인데 9999, 1280두개 다 존재함.
    NSMutableArray *array = [[[self.cssDictWithViewPort allKeys] sortedArrayUsingDescriptors:@[sortOrder]] mutableCopy];
        return array;
}

-(id)init{
    self = [super init];
    _cssDictWithViewPort = [[NSMutableDictionary alloc] init];
    _effectiveTagDictionaryForEditWidth = [NSMutableDictionary dictionary];

    self.editViewPort = IUCSSDefaultViewPort;
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_cssDictWithViewPort forKey:@"cssDictWithViewPort"];
}

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [self encodeWithCoder:(NSCoder*)aCoder];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    [[self.delegate undoManager] disableUndoRegistration];
    
    _cssDictWithViewPort = [aDecoder decodeObjectForKey:@"cssDictWithViewPort"];
    
    //////////////////////////////////////////////////////////////////////////////////////
    //FIXME: project에 달려있는 version check해서 들어가야할듯.
    //version control code
    
    if (_cssDictWithViewPort == nil) {
        _cssDictWithViewPort = [aDecoder decodeObjectForKey:@"cssFrameDict"];
    }
    
    //////////////////////////////////////////////////////////////////////////////////////

    self.editViewPort = IUCSSDefaultViewPort;
    _effectiveTagDictionaryForEditWidth = [NSMutableDictionary dictionary];

    [self updateEffectiveTagDictionary];
    
    [[self.delegate undoManager] enableUndoRegistration];
    return self;
}

- (id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [super init];
    [[self.delegate undoManager] disableUndoRegistration];
    
    _cssDictWithViewPort = [aDecoder decodeObjectForKey:@"cssDictWithViewPort"];
    self.editViewPort = IUCSSDefaultViewPort;
    _effectiveTagDictionaryForEditWidth = [NSMutableDictionary dictionary];
    [self updateEffectiveTagDictionary];
    
    [[self.delegate undoManager] enableUndoRegistration];
    return self;
}


- (id)copyWithZone:(NSZone *)zone{
    IUCSS *css = [[[self class] allocWithZone:zone] init];
    css.cssDictWithViewPort = [self.cssDictWithViewPort deepCopy];
    css.editViewPort = self.editViewPort;
    css.maxViewPort = self.maxViewPort;
    return css;
}



- (BOOL)isPercentTag:(IUCSSTag)tag{
    if([tag isEqualToString:IUCSSTagPercentX]){
        return YES;
    }
    else if([tag isEqualToString:IUCSSTagPercentY]){
        return YES;
    }
    else if([tag isEqualToString:IUCSSTagPercentWidth]){
        return YES;
    }
    else if([tag isEqualToString:IUCSSTagPercentHeight]){
        return YES;
    }
    return NO;
}

- (BOOL)isUndoTag:(IUCSSTag)tag{
    
    //각각 property에서 undo 설정이 들어간 tag 들은 css에서 관리하지 않음.
    if([tag isEqualToString:IUCSSTagImage]){
        return NO;
    }
    else if([tag isFrameTag]){
        return NO;
    }
    
    return YES;
}

//insert tag
//use css frame dict, and update affecting tag dictionary
-(void)setValue:(id)value forTag:(IUCSSTag)tag forViewport:(NSInteger)width{

    [self setValueWithoutUpdateCSS:value forTag:tag forViewport:width];
    [self.delegate updateCSS];
    
}

-(void)setValueWithoutUpdateCSS:(id)value forTag:(IUCSSTag)tag forViewport:(NSInteger)width{
    NSMutableDictionary *cssDict = _cssDictWithViewPort[@(width)];
    
    id currentValue = [cssDict objectForKey:tag];
    if(currentValue == nil ||  [currentValue isNotEqualTo:value]){
        
        if([self isUndoTag:tag]){
            [[[self.delegate undoManager] prepareWithInvocationTarget:self] setValue:currentValue forTag:tag forViewport:width];
        }
        
        if (cssDict == nil) {
            cssDict = [NSMutableDictionary dictionary];
            /* save as string : to change json object, key should be nsstring format */
            [_cssDictWithViewPort setObject:cssDict forKey:@(width)];
        }
        
        if (value == nil) {
            [cssDict removeObjectForKey:tag];
            if(width == _editViewPort){
                [_effectiveTagDictionaryForEditWidth removeObjectForKey:tag];
            }
        }
        else {
            cssDict[tag] = value;
            if(width == _editViewPort){
                [_effectiveTagDictionaryForEditWidth setObject:value forKey:tag];
            }
        }
        
    }
}

-(id)effectiveValueForTag:(IUCSSTag)tag forViewport:(NSInteger)width{
    if( _cssDictWithViewPort[@(width)]){
        id value = [_cssDictWithViewPort[@(width)] objectForKey:tag];
        if(value){
            return value;
        }
    }
    
    id value = [_cssDictWithViewPort[@(IUCSSDefaultViewPort)] objectForKey:tag];
    return value;
}


/**
 @brief
 media query를 조금더 부드럽게 하기위해서 새로운 size를 만들때 하나위의  css 를 카피함.
 없을 경우에는 frame dict만 만들어 놓음.
 */
- (void)copyCSSMaxViewPortDictTo:(NSInteger)width{
    [self copyCSSDictFrom:IUCSSDefaultViewPort to:width];
}
- (void)copyCSSDictFrom:(NSInteger)fromWidth to:(NSInteger)toWidth{
    if(_cssDictWithViewPort[@(toWidth)] == nil){
        if(_cssDictWithViewPort[@(fromWidth)]){
            NSMutableDictionary *cssDict = [_cssDictWithViewPort[@(fromWidth)] mutableCopy];
            [_cssDictWithViewPort setObject:cssDict forKey:@(toWidth)];
        }
    }
}

-(void)eradicateTag:(IUCSSTag)tag{
    for (id key in _cssDictWithViewPort) {
        NSMutableDictionary *cssDict = _cssDictWithViewPort[key];
        [cssDict removeObjectForKey:tag];
    }
    
    [self updateEffectiveTagDictionary];

    if ([tag isFrameTag] == NO) {
        [self.delegate updateCSS];
    }
}


-(NSDictionary*)tagDictionaryForViewport:(NSInteger)width{
    return _cssDictWithViewPort[@(width)];
}

-(void)updateEffectiveTagDictionary{
    
    //REVIEW: style sheet는 default만 적용됨
    if(_cssDictWithViewPort[@(IUCSSDefaultViewPort)]){
        [_effectiveTagDictionaryForEditWidth setDictionary:_cssDictWithViewPort[@(IUCSSDefaultViewPort)]];
    }
    else{
        [_effectiveTagDictionaryForEditWidth removeAllObjects];
    }
    
    if(_editViewPort != IUCSSDefaultViewPort && _cssDictWithViewPort[@(_editViewPort)]){
        [_effectiveTagDictionaryForEditWidth addEntriesFromDictionary:_cssDictWithViewPort[@(_editViewPort)]];
        
    }
}

-(void)setEditViewPort:(NSInteger)editViewPort{
    _editViewPort = editViewPort;
    [self updateEffectiveTagDictionary];
}

-(void)removeTagDictionaryForViewport:(NSInteger)width{
    if([_cssDictWithViewPort objectForKey:@(width)]){
        [_cssDictWithViewPort removeObjectForKey:@(width)];
    }
}

-(NSMutableDictionary*)effectiveTagDictionary{
    return _effectiveTagDictionaryForEditWidth;
}

-(void)setValue:(id)value forTag:(IUCSSTag)tag{
    [self setValue:value forTag:tag forViewport:_editViewPort];
}
-(void)setValueWithoutUpdateCSS:(id)value forTag:(NSString *)tag{
    [self setValueWithoutUpdateCSS:value forTag:tag forViewport:_editViewPort];

}

-(void)setValue:(id)value forKeyPath:(NSString *)keyPath{
    if ([keyPath containsString:@"effectiveTagDictionary."]) {
        NSString *tag = [keyPath substringFromIndex:23];
        [self setValue:value forTag:tag forViewport:_editViewPort];
        return;
    }
    else {
        [super setValue:value forKey:keyPath];
        return;
    }
}

- (BOOL)isAllBordersEqual{
    int borderTop = [[self.effectiveTagDictionary objectForKey:IUCSSTagBorderTopWidth] intValue];
    int borderBottom = [[self.effectiveTagDictionary objectForKey:IUCSSTagBorderBottomWidth] intValue];
    int borderLeft = [[self.effectiveTagDictionary objectForKey:IUCSSTagBorderLeftWidth] intValue];
    int borderRight = [[self.effectiveTagDictionary objectForKey:IUCSSTagBorderRightWidth] intValue];
    
    if(borderTop == borderBottom &&
       borderTop == borderLeft &&
       borderTop == borderRight){
        return YES;
    }
    return NO;
}
- (BOOL)isAllRadiusEqual{
    int borderTLRadius = [[self.effectiveTagDictionary objectForKey:IUCSSTagBorderRadiusTopLeft] intValue];
    int borderTRRadius = [[self.effectiveTagDictionary objectForKey:IUCSSTagBorderRadiusTopRight] intValue];
    int borderBLRadius = [[self.effectiveTagDictionary objectForKey:IUCSSTagBorderRadiusBottomLeft] intValue];
    int borderBRRadius = [[self.effectiveTagDictionary objectForKey:IUCSSTagBorderRadiusBottomRight] intValue];
    
    if(borderTLRadius == borderTRRadius &&
       borderTLRadius == borderBLRadius &&
       borderTLRadius == borderBRRadius){
        return YES;
    }
    return NO;
}

-(id)valueForKeyPath:(NSString *)keyPath{
    if ([keyPath containsString:@"effectiveTagDictionary."]) {
        NSString *tag = [keyPath substringFromIndex:23];
        if ([tag isEqualToTag:IUCSSTagBorderWidth]) {
            NSNumber* value = [self.effectiveTagDictionary objectForKey:IUCSSTagBorderWidth];
            if(value == nil){
                return @(0);
            }
            if([self isAllBordersEqual]){
                return value;
            }
            else{
                return NSMultipleValuesMarker;
            }
        }
        //radius multiple
        if ([tag isEqualToTag:IUCSSTagBorderRadius]) {
            NSNumber* value = [self.effectiveTagDictionary objectForKey:IUCSSTagBorderRadius];
            if(value == nil){
                return @(0);
            }
            if([self isAllRadiusEqual]){
                return value;
            }
            else{
                return NSMultipleValuesMarker;
            }
        }
        return [_effectiveTagDictionaryForEditWidth objectForKey:tag];
    }
    else {
        return [super valueForKey:keyPath];
    }
}


@end