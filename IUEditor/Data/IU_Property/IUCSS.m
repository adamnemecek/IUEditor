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
    /* for version control; used in 'convertToStorageManager' */
    IUCSSStorage *convertStorage;
    NSDictionary *convertTagDict;
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
    
    return self;
}

- (id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [super init];
    
    _cssDictWithViewPort = [aDecoder decodeObjectForKey:@"cssDictWithViewPort"];
    self.editViewPort = IUCSSDefaultViewPort;
    _effectiveTagDictionaryForEditWidth = [NSMutableDictionary dictionary];
    [self updateEffectiveTagDictionary];
    
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
        
        
        /* tag undoing */
        if([self isUndoTag:tag]){
            [[[self.delegate undoManager] prepareWithInvocationTarget:self] setValue:currentValue forTag:tag forViewport:width];
        }
        /* start of frame tag undo */
        BOOL isFrameUndo = NO;
        if([tag isFrameTag] && [self.delegate isEnabledFrameUndo] == NO){
            [self.delegate startFrameMoveWithUndoManager];
            isFrameUndo = YES;
        }
        
        /* set value for tag */
        
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
        
        /* end of frame tag undo*/
        if(isFrameUndo){
            [self.delegate endFrameMoveWithUndoManager];
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

/*
 //frame
 static NSString * IUCSSTagXUnitIsPercent   = @"xUnit";
 static NSString * IUCSSTagYUnitIsPercent   = @"yUnit";
 static NSString * IUCSSTagWidthUnitIsPercent   = @"wUnit";
 static NSString * IUCSSTagHeightUnitIsPercent   = @"hUnit";
 
 static NSString * IUCSSTagPixelX = @"left";
 static NSString * IUCSSTagPixelY = @"top";
 static NSString * IUCSSTagPixelWidth = @"width";
 static NSString * IUCSSTagPixelHeight = @"height";
 
 static NSString * IUCSSTagPercentX        = @"percentLeft";
 static NSString * IUCSSTagPercentY        = @"percentTop";
 static NSString * IUCSSTagPercentWidth    = @"percentWidth";
 static NSString * IUCSSTagPercentHeight   = @"percentHeight";
 
 static NSString * IUCSSTagMinPixelWidth = @"minPixelWidth";
 static NSString * IUCSSTagMinPixelHeight = @"minPixelHeight";
 
 //background-image css
 static NSString * IUCSSTagImage = @"background-image";
 static NSString * IUCSSTagBGSize = @"background-size";
 typedef enum{
 IUBGSizeTypeAuto,
 IUBGSizeTypeCover,
 IUBGSizeTypeContain,
 IUBGSizeTypeStretch,
 IUBGSizeTypeFull,
 }IUBGSizeType;
 
 static NSString * IUCSSTagBGColor = @"background-color";
 static NSString * IUCSSTagBGGradient = @"bg-gradient";
 static NSString * IUCSSTagBGGradientStartColor = @"bg-gradient-start";
 static NSString * IUCSSTagBGGradientEndColor = @"bg-gradient-end";
 static NSString * IUCSSTagBGRepeat    = @"bacground-repeat";
 static NSString * IUCSSTagBGVPosition = @"bgV-position";
 static NSString * IUCSSTagBGHPosition = @"bgH-position";
 
 typedef enum{
 IUCSSBGVPostionTop,
 IUCSSBGVPostionCenter,
 IUCSSBGVPostionBottom,
 }IUCSSBGVPostion;
 typedef enum{
 IUCSSBGHPostionLeft,
 IUCSSBGHPostionCenter,
 IUCSSBGHPostionRight,
 }IUCSSBGHPostion;
 
 static NSString * IUCSSTagEnableBGCustomPosition = @"enableDigitPosition";
 static NSString * IUCSSTagBGXPosition = @"bgX";
 static NSString * IUCSSTagBGYPosition = @"bgY";
 
 
 static NSString * IUCSSTagBorderWidth = @"borderWeight";
 static NSString * IUCSSTagBorderColor = @"borderColor";
 
 static NSString * IUCSSTagBorderTopWidth = @"borderTWeight";
 static NSString * IUCSSTagBorderTopColor = @"borderTColor";
 static NSString * IUCSSTagBorderRightWidth = @"borderRWeight";
 static NSString * IUCSSTagBorderRightColor = @"borderRColor";
 static NSString * IUCSSTagBorderLeftWidth = @"borderLWeight";
 static NSString * IUCSSTagBorderLeftColor = @"borderLColor";
 static NSString * IUCSSTagBorderBottomWidth = @"borderBWeight";
 static NSString * IUCSSTagBorderBottomColor = @"borderBColor";
 
 static NSString * IUCSSTagBorderRadius = @"borderRadius";
 static NSString * IUCSSTagBorderRadiusTopLeft = @"borderTLRadius";
 static NSString * IUCSSTagBorderRadiusTopRight = @"borderTRRadius";
 static NSString * IUCSSTagBorderRadiusBottomLeft = @"borderBLRadius";
 static NSString * IUCSSTagBorderRadiusBottomRight = @"borderBRRadius";
 
 static NSString * IUCSSTagFontName = @"fontName";
 static NSString * IUCSSTagFontSize = @"fontSize";
 static NSString * IUCSSTagFontColor = @"fontColor";
 
 static NSString * IUCSSTagFontWeight = @"fontWeight";
 static NSString * IUCSSTagFontItalic = @"fontItalic";
 static NSString * IUCSSTagFontDecoration = @"fontDeco";
 
 static NSString * IUCSSTagTextLink = @"textLink";
 static NSString * IUCSSTagTextAlign = @"textAlign";
 static NSString * IUCSSTagLineHeight = @"lineHeight";
 static NSString * IUCSSTagTextLetterSpacing = @"letterSpacing";
 static NSString * IUCSSTagEllipsis = @"ellipsis";
 
 
 static NSString * IUCSSTagShadowColor = @"shadowColor";
 static NSString * IUCSSTagShadowVertical = @"shadowVertical";
 static NSString * IUCSSTagShadowHorizontal = @"shadowHorizontal";
 static NSString * IUCSSTagShadowSpread = @"shadowSpread";
 static NSString * IUCSSTagShadowBlur = @"shadowBlur";
 
 static NSString * IUCSSTagDisplayIsHidden = @"displayHidden";
 static NSString * IUCSSTagOpacity = @"opacity";
 
 //it should be used IN Editor Mode!!!
 //Usage : Transition, carousel hidden
 static NSString * IUCSSTagEditorDisplay = @"editorDisplay";
 
 //hover CSS
 static NSString * IUCSSTagHoverBGImagePositionEnable = @"HoverBGImagePositionEnable";
 static NSString * IUCSSTagHoverBGImageX = @"hoverBGImageX";
 static NSString * IUCSSTagHoverBGImageY = @"hoverBGImageY";
 static NSString * IUCSSTagHoverBGColorEnable  = @"hoverBGColorEnable";
 static NSString * IUCSSTagHoverBGColor  = @"hoverBGColor";
 static NSString * IUCSSTagHoverBGColorDuration  = @"hoverBGColorDuration";
 static NSString * IUCSSTagHoverTextColorEnable  = @"hoverTextColorEnable";
 static NSString * IUCSSTagHoverTextColor  = @"hoverTextColor";
 
*/

- (void)convertToStorageManager_setTag:(NSString*)tag  toStorageWithkey:(NSString*)key{
    if (convertTagDict[tag]) {
        [convertStorage setCSSValue:convertTagDict[tag] fromCSSforCSSKey:key];
//        [convertStorage setValue:convertTagDict[tag] forKey:key];
    }
}

- (IUCSSStorageManager *)convertToStorageManager {
    IUCSSStorageManager *cssStorageManager = [[IUCSSStorageManager alloc] init];
    
    for (NSNumber *number in self.allViewports) {
        cssStorageManager.currentViewPort = [number integerValue];
        
        convertStorage = cssStorageManager.currentStorage;
        convertTagDict = [self tagDictionaryForViewport:[number integerValue]];

        /* convert frame */
        [self convertToStorageManager_setTag:IUCSSTagXUnitIsPercent toStorageWithkey:@"xUnit"];
        if ([convertTagDict[IUCSSTagXUnitIsPercent] boolValue]) {
            [self convertToStorageManager_setTag:IUCSSTagPercentX toStorageWithkey:@"x"];
        }
        else {
            [self convertToStorageManager_setTag:IUCSSTagPixelX toStorageWithkey:@"x"];
        }
        
        [self convertToStorageManager_setTag:IUCSSTagYUnitIsPercent toStorageWithkey:@"yUnit"];
        if ([convertTagDict[IUCSSTagYUnitIsPercent] boolValue]) {
            [self convertToStorageManager_setTag:IUCSSTagPercentY toStorageWithkey:@"y"];
        }
        else {
            [self convertToStorageManager_setTag:IUCSSTagPixelY toStorageWithkey:@"y"];
        }
        
        [self convertToStorageManager_setTag:IUCSSTagWidthUnitIsPercent toStorageWithkey:@"widthUnit"];
        if ([convertTagDict[IUCSSTagWidthUnitIsPercent] boolValue]) {
            [self convertToStorageManager_setTag:IUCSSTagPercentWidth toStorageWithkey:@"width"];
        }
        else {
            [self convertToStorageManager_setTag:IUCSSTagPixelWidth toStorageWithkey:@"width"];
        }

        [self convertToStorageManager_setTag:IUCSSTagHeightUnitIsPercent toStorageWithkey:@"heightUnit"];
        if ([convertTagDict[IUCSSTagHeightUnitIsPercent] boolValue]) {
            [self convertToStorageManager_setTag:IUCSSTagPercentHeight toStorageWithkey:@"height"];
        }
        else {
            [self convertToStorageManager_setTag:IUCSSTagPixelHeight toStorageWithkey:@"height"];
        }
        [self convertToStorageManager_setTag:IUCSSTagMinPixelWidth toStorageWithkey:@"minWidth"];
        [self convertToStorageManager_setTag:IUCSSTagMinPixelHeight toStorageWithkey:@"minHeight"];

        
        /* convert image */
        [self convertToStorageManager_setTag:IUCSSTagImage toStorageWithkey:@"imageName"];
        [self convertToStorageManager_setTag:IUCSSTagBGRepeat toStorageWithkey:@"imageRepeat"];
        
        if (convertTagDict[IUCSSTagBGSize]) {
            [self convertToStorageManager_setTag:IUCSSTagBGSize toStorageWithkey:@"imageSizeType"];
        }
        if ([convertTagDict[IUCSSTagEnableBGCustomPosition] boolValue]) {
            [self convertToStorageManager_setTag:IUCSSTagBGXPosition toStorageWithkey:@"imageX"];
            [self convertToStorageManager_setTag:IUCSSTagBGYPosition toStorageWithkey:@"imageY"];
        }
        else {
            [self convertToStorageManager_setTag:IUCSSTagBGVPosition toStorageWithkey:@"imageVPosition"];
            [self convertToStorageManager_setTag:IUCSSTagBGHPosition toStorageWithkey:@"imageHPosition"];
        }
        
        /* convert bg color */
        if (convertTagDict[IUCSSTagBGGradient]) {
            [self convertToStorageManager_setTag:IUCSSTagBGGradientStartColor toStorageWithkey:@"bgColor"];
            [self convertToStorageManager_setTag:IUCSSTagBGGradientEndColor toStorageWithkey:@"bgGradientColor"];
        }
        else {
            [self convertToStorageManager_setTag:IUCSSTagBGColor toStorageWithkey:@"bgColor"];
        }
        
        /* border and radius  */
        [self convertToStorageManager_setTag:IUCSSTagBorderColor toStorageWithkey:@"borderColor"];
        [self convertToStorageManager_setTag:IUCSSTagBorderWidth toStorageWithkey:@"borderWidth"];
        [self convertToStorageManager_setTag:IUCSSTagBorderRadius toStorageWithkey:@"borderRadius"];
        

        [self convertToStorageManager_setTag:IUCSSTagBorderTopWidth toStorageWithkey:@"topBorderWidth"];
        [self convertToStorageManager_setTag:IUCSSTagBorderTopColor toStorageWithkey:@"topBorderColor"];
        [self convertToStorageManager_setTag:IUCSSTagBorderRightWidth toStorageWithkey:@"rightBorderWidth"];
        [self convertToStorageManager_setTag:IUCSSTagBorderRightColor toStorageWithkey:@"rightBorderColor"];
        [self convertToStorageManager_setTag:IUCSSTagBorderLeftWidth toStorageWithkey:@"leftBorderWidth"];
        [self convertToStorageManager_setTag:IUCSSTagBorderLeftColor toStorageWithkey:@"leftBorderColor"];
        [self convertToStorageManager_setTag:IUCSSTagBorderBottomWidth toStorageWithkey:@"bottomBorderWidth"];
        [self convertToStorageManager_setTag:IUCSSTagBorderBottomColor toStorageWithkey:@"bottomBorderColor"];

        [self convertToStorageManager_setTag:IUCSSTagBorderRadiusTopLeft toStorageWithkey:@"topLeftBorderRadius"];
        [self convertToStorageManager_setTag:IUCSSTagBorderRadiusTopRight toStorageWithkey:@"topRightBorderRadius"];
        [self convertToStorageManager_setTag:IUCSSTagBorderRadiusBottomLeft toStorageWithkey:@"bottomLeftborderRadius"];
        [self convertToStorageManager_setTag:IUCSSTagBorderRadiusBottomRight toStorageWithkey:@"bottomRightBorderRadius"];

        /* font tag */
        [self convertToStorageManager_setTag:IUCSSTagFontName toStorageWithkey:@"fontName"];
        [self convertToStorageManager_setTag:IUCSSTagFontSize toStorageWithkey:@"fontSize"];
        [self convertToStorageManager_setTag:IUCSSTagFontColor toStorageWithkey:@"fontColor"];
        [self convertToStorageManager_setTag:IUCSSTagFontWeight toStorageWithkey:@"fontWeight"];
        [self convertToStorageManager_setTag:IUCSSTagFontItalic toStorageWithkey:@"fontItalic"];
        [self convertToStorageManager_setTag:IUCSSTagFontDecoration toStorageWithkey:@"fontDeco"];
        [self convertToStorageManager_setTag:IUCSSTagTextLetterSpacing toStorageWithkey:@"fontLetterSpacing"];
        [self convertToStorageManager_setTag:IUCSSTagEllipsis toStorageWithkey:@"fontEllipsis"];


        /* shadow tag */
        [self convertToStorageManager_setTag:IUCSSTagShadowColor toStorageWithkey:@"shadowColor"];
        [self convertToStorageManager_setTag:IUCSSTagShadowVertical toStorageWithkey:@"shadowColorVertical"];
        [self convertToStorageManager_setTag:IUCSSTagShadowHorizontal toStorageWithkey:@"shadowColorHorizontal"];
        [self convertToStorageManager_setTag:IUCSSTagShadowSpread toStorageWithkey:@"shadowColorSpread"];
        [self convertToStorageManager_setTag:IUCSSTagShadowBlur toStorageWithkey:@"shadowColorBlur"];


        /* display hidden */
        [self convertToStorageManager_setTag:IUCSSTagDisplayIsHidden toStorageWithkey:@"hidden"];
        [self convertToStorageManager_setTag:IUCSSTagOpacity toStorageWithkey:@"opacity"];
        [self convertToStorageManager_setTag:IUCSSTagEditorDisplay toStorageWithkey:@"editorHidden"];
        
        /* hover */
        //TODO: Hover converting
    }
    
    return cssStorageManager;
}

@end