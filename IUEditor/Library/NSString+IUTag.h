//
//  NSString+IUTag.h
//  IUEditor
//
//  Created by jd on 3/30/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>

////////EventTag
#define IUEventTag NSString*

static NSString * IUEventTagIUID      = @"iuID";
static NSString * IUEventTagVariable  = @"variable";
static NSString * IUEventTagMaxValue  = @"maxValue";
static NSString * IUEventTagInitialValue = @"initialValue";
static NSString * IUEventTagActionType   = @"actionType";

//equation Dict
static NSString * IUEventTagReceiverArray = @"eventReceiverArray";
static NSString * IUEventTagReceiverType = @"receiverType";

static NSString * IUEventTagEnableVisible = @"enableVisible";
static NSString * IUEventTagVisibleIU     = @"visibleIU";
static NSString * IUEventTagVisibleID     = @"visibleID";
static NSString * IUEventTagVisibleEqVariable = @"eqVisibleVariable";
static NSString * IUEventTagVisibleEquation = @"eqVisible";
static NSString * IUEventTagVisibleDuration = @"eqVisibleDuration";
static NSString * IUEventTagVisibleType = @"directionType";

static NSString * IUEventTagEnableFrame   = @"enableFrame";
static NSString * IUEventTagFrameIU       = @"frameIU";
static NSString * IUEventTagFrameID       = @"frameID";
static NSString * IUEventTagFrameEqVariable = @"eqFrameVariable";
static NSString * IUEventTagFrameEquation    = @"eqFrame";
static NSString * IUEventTagFrameDuration = @"eqFrameDuration";
static NSString * IUEventTagFrameWidth    = @"eqFrameWidth";
static NSString * IUEventTagFrameHeight   = @"eqFrameHeight";

//property
#define IUPropertyTag NSString*

///////CSSTag
#define IUCSSTag NSString*

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


//iubox unique tag
static NSString *IUCSSTagCarouselArrowDisable = @"carouselDisable";




///////MQData Tag
#define IUMQDataTag NSString*
static NSString * IUMQDataTagInnerHTML = @"innerHTML";
static NSString * IUMQDataTagCollectionCount = @"collectionCount";


#define isEqualToTag isEqualToString

@interface NSString (IUTag)
- (NSString*)pixelString;
- (NSString*)percentString;
- (BOOL)isFrameTag;
- (BOOL)isHoverTag;

- (BOOL)isBorderWidthComponentTag;
- (BOOL)isBorderColorComponentTag;
- (BOOL)isBorderRadiusComponentTag;

@end
