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


/**
 Support transaction
 BeginTransaction의 반대는 CommitTransaction으로 한다.
 Commit Trasaction이 불리면 이제껏 변화를 delegate에 update 한다.
 */
- (void)beginTransaction:(id)sender;
- (void)commitTransaction:(id)sender;

/**
 disableUpdate가 시작된 후에 바뀐 부분에서는 commit 하지 않는다.
 */
- (void)disableUpdate:(id)sender;
- (void)enableUpdate:(id)sender;

#if DEBUG
- (NSArray *)currentPropertyStackForTest;
#endif


@end

@protocol IUDataStorageManagerDelegate
@optional

@required
- (void)setNeedsToUpdateStorage:(IUDataStorage*)storage;
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

- (NSArray *)owners;
- (void)addOwner:(id <IUDataStorageManagerDelegate, JDCoding>)box;
- (void)removeOwner:(id <IUDataStorageManagerDelegate, JDCoding>)box;


//@property (weak) id  <IUDataStorageManagerDelegate, JDCoding> box;
@property NSUndoManager *undoManager;

@property NSInteger currentViewPort;

- (NSArray*)allViewPorts;
- (IUDataStorage*)storageForViewPort:(NSInteger)viewPort;
- (NSInteger)viewPortOfStorage:(IUDataStorage*)storage;
- (IUDataStorage *)storageOfSmallerViewPortOfStorage:(IUDataStorage*)storage;
- (IUDataStorage *)storageOfBiggerViewPortOfStorage:(IUDataStorage*)storage;

@property (readonly) IUDataStorage *currentStorage;
@property (readonly) IUDataStorage *defaultStorage;
@property (readonly) IUDataStorage *liveStorage;

- (void)removeStorageForViewPort:(NSInteger)viewPort;

@end


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

@interface IUCSSStorage : IUDataStorage

/* display tags */
@property (nonatomic) NSNumber* hidden;
@property (nonatomic) NSNumber* editorHidden;
@property (nonatomic) NSNumber* opacity;


/* frame tags */
typedef enum IUFrameUnit{
    IUFrameUnitPixel,
    IUFrameUnitPercent,
}IUFrameUnit;

/* unit tags uses as value*/

@property (nonatomic) NSNumber* xUnit;
@property (nonatomic) NSNumber* yUnit;
@property (nonatomic) NSNumber* widthUnit;
@property (nonatomic) NSNumber* heightUnit;

/* frame tags use nsnumber, not enum */
@property (nonatomic) NSNumber* x;
@property (nonatomic) NSNumber* y;
@property (nonatomic) NSNumber* width;
@property (nonatomic) NSNumber* height;
@property (nonatomic) NSNumber* minHeight;
@property (nonatomic) NSNumber* minWidth;

/* image tag */
@property (nonatomic) NSString* imageName;
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
@property (nonatomic) NSColor* bgGradientColor;

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
@property (nonatomic) NSString* fontName;
@property (nonatomic) NSNumber* fontSize;
@property (nonatomic) NSColor*  fontColor;
@property (nonatomic) NSNumber* fontWeight;
@property (nonatomic) NSNumber* fontItalic;
@property (nonatomic) NSNumber* fontDeco;
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




//conversion from old IU
- (void)setCSSValue:(id)value fromCSSforCSSKey:(NSString *)key;


@end


typedef enum _IUCSSSelector{
    IUCSSSelectorDefault,
    IUCSSSelectorActive,
    IUCSSSelectorHover,
} IUCSSSelector;

@interface IUCSSStorageManager : IUDataStorageManager

- (IUCSSStorage*)storageForViewPort:(NSInteger)viewPort selector:(IUCSSSelector)selector;

@property (nonatomic) IUCSSSelector selector;

@property (readonly) IUCSSStorage *currentStorage;
@property (readonly) IUCSSStorage *defaultStorage;
@property (readonly) IUCSSStorage *liveStorage;


@end


