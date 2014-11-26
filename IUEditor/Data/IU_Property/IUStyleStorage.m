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

+ (NSArray *)observingList{
    return [IUStyleStorage properties];
}

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [super encodeWithJDCoder:aCoder];
    [aCoder encodeObject:_width forKey:@"width"];
    [aCoder encodeObject:_height forKey:@"height"];
    return;
}

- (id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [super initWithJDCoder:aDecoder];
    _width = [aDecoder decodeObjectForKey:@"width"];
    _height = [aDecoder decodeObjectForKey:@"height"];
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
