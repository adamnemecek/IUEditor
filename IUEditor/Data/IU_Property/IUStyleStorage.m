//
//  IUStyleStorage.m
//  IUEditor
//
//  Created by seungmi on 2014. 11. 19..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUStyleStorage.h"


@interface IUStyleStorage()

@property NSNumber* widthUnit;
@property NSNumber* heightUnit;

@end
@implementation IUStyleStorage {
}

+ (NSArray *)iuDataList{
    return [IUStyleStorage properties];
}

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [super encodeWithJDCoder:aCoder];
    
    [aCoder encodeObject:_hidden forKey:@"hidden"];
    [aCoder encodeObject:_editorHidden forKey:@"editorHidden"];
    [aCoder encodeObject:_opacity forKey:@"opacity"];
    
    [aCoder encodeObject:_overflowType forKey:@"overflowType"];
    
    [aCoder encodeObject:_widthUnit forKey:@"widthUnit"];
    [aCoder encodeObject:_heightUnit forKey:@"heightUnit"];
    
    [aCoder encodeObject:_width forKey:@"width"];
    [aCoder encodeObject:_height forKey:@"height"];
    [aCoder encodeObject:_minHeight forKey:@"minHeight"];
    [aCoder encodeObject:_minWidth forKey:@"minWidth"];
    
    [aCoder encodeObject:_imageName forKey:@"imageName"];
    [aCoder encodeObject:_imageRepeat forKey:@"imageRepeat"];
    
    [aCoder encodeObject:_imageHPosition forKey:@"imageHPosition"];
    [aCoder encodeObject:_imageVPosition forKey:@"imageVPosition"];
    [aCoder encodeObject:_imageX forKey:@"imageX"];
    [aCoder encodeObject:_imageY forKey:@"imageY"];
    
    [aCoder encodeObject:_imageSizeType forKey:@"imageSizeType"];
    [aCoder encodeObject:_imageAttachment forKey:@"imageAttachment"];
    
    [aCoder encodeObject:_bgColor forKey:@"bgColor"];
    [aCoder encodeObject:_bgGradientStartColor forKey:@"bgGradientStartColor"];
    [aCoder encodeObject:_bgGradientEndColor forKey:@"bgGradientEndColor"];
    [aCoder encodeObject:_bgColorDuration forKey:@"bgColorDuration"];
    
    [aCoder encodeObject:_topBorderColor forKey:@"topBorderColor"];
    [aCoder encodeObject:_leftBorderColor forKey:@"leftBorderColor"];
    [aCoder encodeObject:_rightBorderColor forKey:@"rightBorderColor"];
    [aCoder encodeObject:_bottomBorderColor forKey:@"bottomBorderColor"];
    
    [aCoder encodeObject:_topBorderWidth forKey:@"topBorderWidth"];
    [aCoder encodeObject:_leftBorderWidth forKey:@"leftBorderWidth"];
    [aCoder encodeObject:_rightBorderWidth forKey:@"rightBorderWidth"];
    [aCoder encodeObject:_bottomBorderWidth forKey:@"bottomBorderWidth"];
    
    [aCoder encodeObject:_fontName forKey:@"fontName"];
    [aCoder encodeObject:_fontSize forKey:@"fontSize"];
    [aCoder encodeObject:_fontColor forKey:@"fontColor"];
    [aCoder encodeObject:_fontWeight forKey:@"fontWeight"];
    [aCoder encodeObject:_fontItalic forKey:@"fontItalic"];
    [aCoder encodeObject:_fontUnderline forKey:@"fontUnderline"];
    
    [aCoder encodeObject:_fontAlign forKey:@"fontAlign"];
    [aCoder encodeObject:_fontLineHeight forKey:@"fontLineHeight"];
    [aCoder encodeObject:_fontLetterSpacing forKey:@"fontLetterSpacing"];
    [aCoder encodeObject:_fontEllipsis forKey:@"fontEllipsis"];

    [aCoder encodeObject:_shadowColor forKey:@"shadowColor"];
    [aCoder encodeObject:_shadowColorVertical forKey:@"shadowColorVertical"];
    [aCoder encodeObject:_shadowColorHorizontal forKey:@"shadowColorHorizontal"];
    [aCoder encodeObject:_shadowColorSpread forKey:@"shadowColorSpread"];
    [aCoder encodeObject:_shadowColorBlur forKey:@"shadowColorBlur"];
        
    return;
}

- (id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [super initWithJDCoder:aDecoder];
    if(self){
        _hidden = [aDecoder decodeObjectForKey:@"hidden"];
        _editorHidden = [aDecoder decodeObjectForKey:@"editorHidden"];
        _opacity = [aDecoder decodeObjectForKey:@"opacity"];
        
        _overflowType = [aDecoder decodeObjectForKey:@"overflowType"];
        
    
        _widthUnit = [aDecoder decodeObjectForKey:@"widthUnit"];
        _heightUnit = [aDecoder decodeObjectForKey:@"heightUnit"];
        
        _width = [aDecoder decodeObjectForKey:@"width"];
        _height = [aDecoder decodeObjectForKey:@"height"];
        _minHeight = [aDecoder decodeObjectForKey:@"minHeight"];
        _minWidth = [aDecoder decodeObjectForKey:@"minWidth"];
        
        _imageName = [aDecoder decodeObjectForKey:@"imageName"];
        _imageRepeat = [aDecoder decodeObjectForKey:@"imageRepeat"];
        
        _imageHPosition = [aDecoder decodeObjectForKey:@"imageHPosition"];
        _imageVPosition = [aDecoder decodeObjectForKey:@"imageVPosition"];
        _imageX = [aDecoder decodeObjectForKey:@"imageX"];
        _imageY = [aDecoder decodeObjectForKey:@"imageY"];
        
        _imageSizeType = [aDecoder decodeObjectForKey:@"imageSizeType"];
        _imageAttachment = [aDecoder decodeObjectForKey:@"imageAttachment"];
        
        
        _bgColor = [aDecoder decodeObjectForKey:@"bgColor"];
        _bgGradientStartColor = [aDecoder decodeObjectForKey:@"bgGradientStartColor"];
        _bgGradientEndColor = [aDecoder decodeObjectForKey:@"bgGradientEndColor"];
        _bgColorDuration = [aDecoder decodeObjectForKey:@"bgColorDuration"];
        
        
        _topBorderColor = [aDecoder decodeObjectForKey:@"topBorderColor"];
        _leftBorderColor = [aDecoder decodeObjectForKey:@"leftBorderColor"];
        _rightBorderColor = [aDecoder decodeObjectForKey:@"rightBorderColor"];
        _bottomBorderColor = [aDecoder decodeObjectForKey:@"bottomBorderColor"];
        
        _topBorderWidth = [aDecoder decodeObjectForKey:@"topBorderWidth"];
        _leftBorderWidth = [aDecoder decodeObjectForKey:@"leftBorderWidth"];
        _rightBorderWidth = [aDecoder decodeObjectForKey:@"rightBorderWidth"];
        _bottomBorderWidth = [aDecoder decodeObjectForKey:@"bottomBorderWidth"];
        
        
        _fontName = [aDecoder decodeObjectForKey:@"fontName"];
        _fontSize = [aDecoder decodeObjectForKey:@"fontSize"];
        _fontColor = [aDecoder decodeObjectForKey:@"fontColor"];
        _fontWeight = [aDecoder decodeObjectForKey:@"fontWeight"];
        _fontItalic = [aDecoder decodeObjectForKey:@"fontItalic"];
        _fontUnderline = [aDecoder decodeObjectForKey:@"fontUnderline"];
        
        _fontAlign = [aDecoder decodeObjectForKey:@"fontAlign"];
        _fontLineHeight = [aDecoder decodeObjectForKey:@"fontLineHeight"];
        _fontLetterSpacing = [aDecoder decodeObjectForKey:@"fontLetterSpacing"];
        _fontEllipsis = [aDecoder decodeObjectForKey:@"fontEllipsis"];
        
        _shadowColor = [aDecoder decodeObjectForKey:@"shadowColor"];
        _shadowColorVertical = [aDecoder decodeObjectForKey:@"shadowColorVertical"];
        _shadowColorHorizontal = [aDecoder decodeObjectForKey:@"shadowColorHorizontal"];
        _shadowColorSpread = [aDecoder decodeObjectForKey:@"shadowColorSpread"];
        _shadowColorBlur = [aDecoder decodeObjectForKey:@"shadowColorBlur"];
        
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone{
    IUStyleStorage *copyStorage = [super copyWithZone:zone];
    [copyStorage disableUpdate:JD_CURRENT_FUNCTION];
    
    if(copyStorage){
        copyStorage.hidden = _hidden;
        copyStorage.editorHidden = _editorHidden;
        copyStorage.opacity = _opacity;
        
        copyStorage.width = _width;
        copyStorage.height = _height;
        
        copyStorage.widthUnit = _widthUnit;
        copyStorage.heightUnit = _heightUnit;
        
        copyStorage.minHeight = _minHeight;
        copyStorage.minWidth = _minWidth;
        
        copyStorage.imageName = _imageName;
        copyStorage.imageRepeat = _imageRepeat;
        copyStorage.imageHPosition = _imageHPosition;
        copyStorage.imageVPosition = _imageVPosition;
        copyStorage.imageX = _imageX;
        copyStorage.imageY = _imageY;
        copyStorage.imageSizeType = _imageSizeType;
        
        copyStorage.bgColor = _bgColor;
        copyStorage.bgGradientStartColor = _bgGradientStartColor;
        copyStorage.bgGradientEndColor = _bgGradientEndColor;
        copyStorage.bgColorDuration = _bgColorDuration;
        
        copyStorage.topBorderWidth = _topBorderWidth;
        copyStorage.bottomBorderWidth = _bottomBorderWidth;
        copyStorage.leftBorderWidth = _leftBorderWidth;
        copyStorage.rightBorderWidth = _rightBorderWidth;
        
        copyStorage.topBorderColor = _topBorderColor;
        copyStorage.bottomBorderColor = _bottomBorderColor;
        copyStorage.leftBorderColor = _leftBorderColor;
        copyStorage.rightBorderColor = _rightBorderColor;
        
        copyStorage.topLeftBorderRadius = _topLeftBorderRadius;
        copyStorage.topRightBorderRadius = _topRightBorderRadius;
        copyStorage.bottomLeftborderRadius = _bottomLeftborderRadius;
        copyStorage.bottomRightBorderRadius = _bottomRightBorderRadius;
        
        copyStorage.fontName = _fontName;
        copyStorage.fontSize = _fontSize;
        copyStorage.fontColor = _fontColor;
        copyStorage.fontWeight = _fontWeight;
        copyStorage.fontItalic = _fontItalic;
        copyStorage.fontUnderline = _fontUnderline;
        copyStorage.fontAlign = _fontAlign;
        copyStorage.fontLineHeight = _fontLineHeight;
        copyStorage.fontLetterSpacing = _fontLetterSpacing;
        copyStorage.fontEllipsis = _fontEllipsis;
        
        copyStorage.shadowColor = _shadowColor;
        copyStorage.shadowColorVertical = _shadowColorVertical;
        copyStorage.shadowColorHorizontal = _shadowColorHorizontal;
        copyStorage.shadowColorSpread = _shadowColorSpread;
        copyStorage.shadowColorBlur = _shadowColorBlur;
        
    }
    [copyStorage enableUpdate:JD_CURRENT_FUNCTION];
    return copyStorage;
}

#pragma mark - property


- (void)setHeight:(NSNumber *)h unit:(NSNumber *)unit{
    [self beginTransaction:JD_CURRENT_FUNCTION];
    [self setHeight:h];
    [self setHeightUnit:unit];
    [self commitTransaction:JD_CURRENT_FUNCTION];
}

- (void)setWidth:(NSNumber *)w unit:(NSNumber *)unit{
    [self beginTransaction:JD_CURRENT_FUNCTION];
    [self setWidth:w];
    [self setWidthUnit:unit];
    [self commitTransaction:JD_CURRENT_FUNCTION];
}


- (void)setBorderColor:(id)borderColor{
    [self beginTransaction:JD_CURRENT_FUNCTION];
    
    [self setTopBorderColor:borderColor];
    [self setLeftBorderColor:borderColor];
    [self setRightBorderColor:borderColor];
    [self setBottomBorderColor:borderColor];
    
    [self commitTransaction:JD_CURRENT_FUNCTION];
    
}
- (BOOL)isAllBorderColorNil{
    if(_topBorderColor || _bottomBorderColor || _leftBorderColor || _rightBorderColor){
        return NO;
    }
    return YES;
}

- (BOOL)isAllBorderColorsEqual{
    if(_topBorderColor && _bottomBorderColor && _leftBorderColor && _rightBorderColor){
        if( [_topBorderColor isEqualTo:_bottomBorderColor]
           && [_topBorderColor isEqualTo:_leftBorderColor]
           && [_topBorderColor isEqualTo:_rightBorderColor]){
            return YES;
        }
    }
    return NO;
}
- (NSColor *)borderColor{
    if([self isAllBorderColorNil]){
        return nil;
    }
    else if ([self isAllBorderColorsEqual]) {
        return _topBorderColor;
    }
    return NSMultipleValuesMarker;
}

- (void)setBorderWidth:(NSNumber *)borderWidth{
    
    [self beginTransaction:JD_CURRENT_FUNCTION];
    
    [self setTopBorderWidth:borderWidth];
    [self setBottomBorderWidth:borderWidth];
    [self setLeftBorderWidth:borderWidth];
    [self setRightBorderWidth:borderWidth];
    
    [self commitTransaction:JD_CURRENT_FUNCTION];
    
}

- (BOOL)isAllBorderWidthNil{
    if(_topBorderWidth || _leftBorderWidth || _rightBorderWidth || _bottomBorderWidth){
        return NO;
    }
    return YES;
}

- (BOOL)isAllBorderWidthEqual{
    if(_topBorderWidth && _leftBorderWidth && _rightBorderWidth && _bottomBorderWidth){
        if([_topBorderWidth isEqualToNumber:_bottomBorderWidth]
           && [_topBorderWidth isEqualToNumber:_leftBorderWidth]
           && [_topBorderWidth isEqualToNumber:_rightBorderWidth]){
            return YES;
        }
    }
    return NO;
}

- (NSNumber *)borderWidth{
    if([self isAllBorderWidthNil]){
        return nil;
    }
    else if([self isAllBorderWidthEqual]){
        return _topBorderWidth;
    }
    return NSMultipleValuesMarker;
}

- (void)setBorderRadius:(NSNumber *)borderRadius{
    
    [self beginTransaction:JD_CURRENT_FUNCTION];
    
    [self setTopLeftBorderRadius:borderRadius];
    [self setTopRightBorderRadius:borderRadius];
    [self setBottomLeftborderRadius:borderRadius];
    [self setBottomRightBorderRadius:borderRadius];
    
    [self commitTransaction:JD_CURRENT_FUNCTION];
    
}
- (BOOL)isAllBorderRadiusNil{
    if(_topLeftBorderRadius || _topRightBorderRadius || _bottomLeftborderRadius || _bottomRightBorderRadius){
        return NO;
    }
    return YES;
}
- (BOOL)isAllBorderRadiusEqual{
    if(_topLeftBorderRadius && _topRightBorderRadius && _bottomLeftborderRadius && _bottomRightBorderRadius){
        
        if([_topLeftBorderRadius isEqualToNumber:_topRightBorderRadius]
           && [_topLeftBorderRadius isEqualToNumber:_bottomLeftborderRadius]
           && [_topLeftBorderRadius isEqualToNumber:_bottomRightBorderRadius]
           ){
            return YES;
        }
    }
    return NO;
}

- (NSNumber *)borderRadius{
    if([self isAllBorderRadiusNil]){
        return nil;
    }
    else if([self isAllBorderRadiusEqual]){
        return _topLeftBorderRadius;
    }
    
    return NSMultipleValuesMarker;
}


/* it's for conversion */
- (void)setCSSValue:(id)value fromCSSforCSSKey:(NSString *)key{
    if([value isEqualTo:NSMultipleValuesMarker]){
        //border, radius, color - 서로 다른 값을 가질때.
        return;
    }
    [self setValue:value forKey:key];
    
}



@end
