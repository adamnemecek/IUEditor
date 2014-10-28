//
//  IUDataStorage.h
//  IUEditor
//
//  Created by jd on 10/20/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//
//
//  Declare IUDataStorageManager, IUDataStorage, IUDataStorageManagerDelegate
//  Support Unit test
//

#import <Foundation/Foundation.h>
#import "JDCoder.h"
#import "NSString+IUTag.h"
@interface IUDataStorage : NSObject <JDCoding, NSCopying>

/**
 @note value and key should support JSON rule.
 */
- (void)setValue:(id)value forUndefinedKey:(NSString *)key;
- (id)valueForUndefinedKey:(NSString *)key;
- (NSDictionary*)dictionary;
@end

@protocol IUDataStorageManagerDelegate
@required
- (void)setNeedsToUpdateData:(IUDataStorage*)storage;
@end


/**
 Manage Data(CSS or anything) of IUBox
 
 Change value in liveTagDict or currentTagDict will make KVO-notification to each other.
 
 KVO-Noti :
 viewPort, allViewPorts, liveTagDict, currentTagDict
 
 If updating should be disabled, DO IT AT IUBOX!!!!
 */

#define IUDefaultViewPort 9999

@interface IUDataStorageManager : NSObject <JDCoding>

@property id <IUDataStorageManagerDelegate> box;
@property NSUndoManager *undoManager;

@property NSInteger currentViewPort;

@property (readonly) NSArray* allViewPorts;

- (IUDataStorage*)storageForViewPort:(NSInteger)viewPort;

@property (readonly) IUDataStorage *currentStorage;
@property (readonly) IUDataStorage *defaultStorage;
@property (readonly) IUDataStorage *liveStorage;

- (void)removeStorageForViewPort:(NSInteger)viewPort;

@end


/* IUCSSStorage controls marker or proxy key.
 For example, it will manage 'IUCSSTagBorderWidth' as proxy of 'IUCSSTagBorderLeftWidth', 'IUCSSTagBorderRightWidth', 'IUCSSTagBorderTopWidth', 'IUCSSTagBorderBottomWidth'.
 */
@interface IUCSSStorage : IUDataStorage

/* following tags can have marker */
@property (nonatomic) id borderWidth;
@property (nonatomic) id borderColor;
@property (nonatomic) id borderRadius;

@property id minHeight;
@property id minWidth;

@property (nonatomic) id isXPercent;
@property (nonatomic) id x;
@property (nonatomic) id isYPercent;
@property (nonatomic) id y;


@end

typedef enum _IUCSSSelector{
    IUCSSSelectorDefault,
    IUCSSSelectorActive,
    IUCSSSelectorHover,
} IUCSSSelector;

@interface IUCSSStorageManager : IUDataStorageManager

- (IUCSSStorage*)storageForViewPort:(NSInteger)viewPort;

@property (nonatomic) IUCSSSelector selector;

@property (readonly) IUCSSStorage *currentStorage;
@property (readonly) IUCSSStorage *defaultStorage;
@property (readonly) IUCSSStorage *liveStorage;


@end


/*
 
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
 typedef enum{
 IUAlignLeft,
 IUAlignCenter,
 IUAlignRight,
 IUAlignJustify,
 }IUAlign;
 
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
 
 
 //iubox unique tag
 static NSString *IUCSSTagCarouselArrowDisable = @"carouselDisable";
*/

