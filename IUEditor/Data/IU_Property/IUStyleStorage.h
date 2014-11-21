//
//  IUStyleStorage.h
//  IUEditor
//
//  Created by seungmi on 2014. 11. 19..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUDataStorage.h"

typedef enum{
    IUImageTypeAuto,
    IUImageTypeCover,
    IUImageTypeContain,
    IUImageTypeStretch,
    IUImageTypeFull,
} IUImageSizeType;



/*
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
 */

/* IUCSSStorage controls marker or proxy key.
 For example, it will manage 'IUCSSTagBorderWidth' as proxy of 'IUCSSTagBorderLeftWidth', 'IUCSSTagBorderRightWidth', 'IUCSSTagBorderTopWidth', 'IUCSSTagBorderBottomWidth'.
 */

@interface IUStyleStorage : IUDataStorage

/* display tags */
@property (nonatomic) NSNumber* hidden;
@property (nonatomic) NSNumber* editorHidden;
@property (nonatomic) NSNumber* opacity;


/* unit tags uses as value*/
@property (nonatomic, readonly) NSNumber* widthUnit;
@property (nonatomic, readonly) NSNumber* heightUnit;

/* frame tags use nsnumber, not enum */
@property (nonatomic) NSNumber* width;
@property (nonatomic) NSNumber* height;
@property (nonatomic) NSNumber* minHeight;
@property (nonatomic) NSNumber* minWidth;

/* image tag */
@property (nonatomic, copy) NSString* imageName;
@property (nonatomic) NSNumber* imageRepeat;
/*
 IUCSSBGVPostionTop, = 1
 IUCSSBGVPostionCenter, = 2
 IUCSSBGVPostionBottom, = 3
 
 IUCSSBGHPostionLeft, = 1
 IUCSSBGHPostionCenter, = 2
 IUCSSBGHPostionRight, = 3
 */
@property (nonatomic) NSNumber* imageHPosition; // if imageHPosition is not nil, imageX should be nil
@property (nonatomic) NSNumber* imageVPosition; // if imageVPosition is not nil, imageY should be nil
@property (nonatomic) NSNumber* imageX; //if imageX is not nil, imageHPosition should be nil;
@property (nonatomic) NSNumber* imageY; //if imageY is not nil, imageVPosition should be nil

/* imageSizeTypes:
 IUBGSizeTypeAuto = 1,
 IUBGSizeTypeCover = 2,
 IUBGSizeTypeContain = 3,
 IUBGSizeTypeStretch = 4,
 IUBGSizeTypeFull ,
 */
@property (nonatomic) NSNumber* imageSizeType;

/* background tag */
@property (nonatomic) NSColor* bgColor;
@property (nonatomic) NSColor* bgGradientStartColor;
@property (nonatomic) NSColor* bgGradientEndColor;
@property (nonatomic) NSNumber* bgColorDuration;

/* border tag */
/* following three tag can have NSMultipleValueMarker */
@property (nonatomic) NSNumber  *borderWidth;
@property (nonatomic) NSColor   *borderColor;
@property (nonatomic) NSNumber  *borderRadius;

/* followings are border/radius tags */
@property (nonatomic) NSNumber* topBorderWidth;
@property (nonatomic) NSColor* topBorderColor;
@property (nonatomic) NSNumber* leftBorderWidth;
@property (nonatomic) NSColor* leftBorderColor;
@property (nonatomic) NSNumber* rightBorderWidth;
@property (nonatomic) NSColor* rightBorderColor;
@property (nonatomic) NSNumber* bottomBorderWidth;
@property (nonatomic) NSColor* bottomBorderColor;

@property (nonatomic) NSNumber* topLeftBorderRadius;
@property (nonatomic) NSNumber* topRightBorderRadius;
@property (nonatomic) NSNumber* bottomRightBorderRadius;
@property (nonatomic) NSNumber* bottomLeftborderRadius;

/* font tag */
@property (nonatomic, copy) NSString* fontName;
@property (nonatomic) NSNumber* fontSize;
@property (nonatomic) NSColor*  fontColor;
@property (nonatomic) NSString* fontWeight;
@property (nonatomic) NSNumber* fontItalic;
@property (nonatomic) NSNumber* fontUnderline;

typedef enum{
    IUAlignLeft,
    IUAlignCenter,
    IUAlignRight,
    IUAlignJustify,
}IUAlign;

@property (nonatomic) NSNumber* fontAlign;
@property (nonatomic) NSNumber* fontLineHeight;
@property (nonatomic) NSNumber* fontLetterSpacing;
@property (nonatomic) NSNumber* fontEllipsis;

/* shadow tag */
@property (nonatomic) NSColor* shadowColor;
@property (nonatomic) NSNumber* shadowColorVertical;
@property (nonatomic) NSNumber* shadowColorHorizontal;
@property (nonatomic) NSNumber* shadowColorSpread;
@property (nonatomic) NSNumber* shadowColorBlur;


/*
 Move it to IUCarousel.
 static NSString *IUCSSTagCarouselArrowDisable = @"carouselDisable";
 */


- (void)initPropertiesForDefaultViewPort;

//set frame unit
- (void)setWidth:(NSNumber *)w unit:(NSNumber *)unit;
- (void)setHeight:(NSNumber *)h unit:(NSNumber *)unit;

//conversion from old IU
- (void)setCSSValue:(id)value fromCSSforCSSKey:(NSString *)key;



@end

