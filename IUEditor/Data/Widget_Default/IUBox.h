//
//  IUBox.h
//  IUEditor
//
//  Created by JD on 3/18/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JDCoder.h"
#import "IUCSS.h"
#import "IUEvent.h"
#import "IUMQData.h"
#import "IUIdentifierManager.h"
#import "IUDataStorage.h"
#import "IUStyleStorage.h"
#import "IUPositionStorage.h"
#import "IUSourceDelegate.h"
#import "IUProjectProtocol.h"
#import "IUSourceManagerProtocol.h"

typedef enum{
    IUWidgetTypePrimary,
    IUWidgetTypeSecondary,
    IUWidgetTypePG,
    IUWidgetTypeWP,
}IUWidgetType;


typedef enum _IUPositionType{
    IUPositionTypeAbsolute,
    IUPositionTypeAbsoluteBottom,
    IUPositionTypeRelative,
    IUPositionTypeFloatLeft,
    IUPositionTypeFloatRight,
    IUPositionTypeFixed,
    IUPositionTypeFixedBottom,
}IUPositionType;


typedef enum{
    IUTextTypeDefault,
    IUTextTypeH1,
    IUTextTypeH2,
}IUTextType;

typedef enum _IUOverflowType{
    IUOverflowTypeHidden,
    IUOverflowTypeVisible,
    IUOverflowTypeScroll,
}IUOverflowType;

typedef enum{
    IUTextInputTypeNone,
    IUTextInputTypeEditable,
    IUTextInputTypeAddible,
    IUTextInputTypeTextField,
}IUTextInputType;


/* default data manager name */
static NSString *kIUStyleManagerDefault = @"styleManagerDefault";
static NSString *kIUStyleManagerHover = @"styleManagerHover";
static NSString *kIUStyleManagerActive = @"styleManagerActive";
static NSString *kIUPositionManagerDefault = @"positionManagerDefault";

@class IUBox;
@class IUSheet;
@class IUProject;

@interface IUBox : NSObject <NSCoding, NSCopying, JDCoding, IUCSSDelegate, IUMQDataDelegate, IUDataStorageManagerDelegate>{
    NSMutableArray *_m_children;
    __weak id <IUSourceDelegate> _canvasVC __storage_deprecated;
    
    IUStyleStorage *_liveStyleStorage;
    IUStyleStorage *_currentStyleStorage;
}

+ (NSImage *)classImage;
+ (NSImage *)navigationImage;
+ (NSString *)shortDescription;
+ (IUWidgetType)widgetType;

-(id)initWithPreset;


-(IUSheet *)sheet;
-(id <IUProjectProtocol>)project;

@property (copy, nonatomic) NSString *name;
@property (copy) NSString *htmlID;
@property (weak) IUBox    *parent;


@property (readonly) BOOL canAddIUByUserInput;
@property (readonly) BOOL canChangeXByUserInput;
@property (readonly) BOOL canChangeYByUserInput;
@property (readonly) BOOL canChangeWidthByUserInput;
@property (readonly) BOOL canChangeWidthUnitByUserInput;
@property (readonly) BOOL canChangeHeightByUserInput;

-(BOOL)shouldCompileChildrenForOutput;


-(BOOL)insertIU:(IUBox *)iu atIndex:(NSInteger)index error:(NSError**)error;
-(BOOL)addIU:(IUBox *)iu error:(NSError**)error;

- (BOOL)shouldCompileX;
- (BOOL)shouldCompileY;
- (BOOL)shouldCompileWidth;
- (BOOL)shouldCompileHeight;
- (BOOL)shouldCompileFontInfo;
- (BOOL)shouldCompileImagePositionInfo;

- (BOOL)canChangePositionType;
- (BOOL)canChangePositionAbsolute;
- (BOOL)canChangePositionRelative;
- (BOOL)canChangePositionFloatLeft;
- (BOOL)canChangePositionFloatRight;
- (BOOL)canChangePositionAbsoluteBottom;
- (BOOL)canChangePositionFixed;
- (BOOL)canChangePositionFixedBottom;
- (BOOL)canChangeHCenter;
- (BOOL)canChangeVCenter;
- (BOOL)canMoveToOtherParent;


@property BOOL removed; // iu is removed;

@property (readonly) IUStyleStorage *defaultStyleStorage;
@property (readonly) IUStyleStorage *liveStyleStorage;
@property (readonly) IUStyleStorage *currentStyleStorage;
@property (readonly) IUPositionStorage *defaultPositionStorage;
@property (readonly) IUPositionStorage *livePositionStorage;
@property (readonly) IUPositionStorage *currentPositionStorage;

- (NSArray *)allCSSSelectors;

- (void)setStorageManager:(IUDataStorageManager *)cssManager forSelector:(NSString *)selector;
- (IUDataStorageManager *)dataManagerForSelector:(NSString *)selector;
- (IUDataStorageManager *)defaultStyleManager;
- (IUDataStorageManager *)hoverStyleManager;
- (IUDataStorageManager *)positionManager;













/* default box */
+(IUBox *)copyrightBoxWithProject:(id <IUProjectProtocol>)project;

/*
 Following are options
 */

#define IUFileName @"FileName"
/**
 initialize IU with project
 @param project project that will initizlie IU. Should not nil.
 @param options NSDictionary of options. \n
 IUFileName : define filename
 */

-(id)initWithProject:(id <IUProjectProtocol>)project options:(NSDictionary *)options __storage_deprecated;
- (void)connectWithEditor;
- (void)disconnectWithEditor;

- (BOOL)isConnectedWithEditor;
- (void)setIsConnectedWithEditor;


#pragma mark - IU Setting

- (void)confirmIdentifier;

- (void)setCanvasVC:(id <IUSourceDelegate>) canvasVC;

@property (nonatomic) NSString *text;

- (IUTextInputType)textInputType;

//undoManager
- (NSUndoManager *)undoManager;


//mediaquery
@property (readonly) IUMQData *mqData;

- (void)addMQSize:(NSNotification *)notification;
- (void)removeMQSize:(NSNotification *)notification;
- (void)changeMQSelect:(NSNotification *)notification;

//Event
@property (readonly) IUEvent *event;

//scroll event
@property (nonatomic) float opacityMove;
@property (nonatomic) float xPosMove;

//Programming
@property (nonatomic) NSString *pgVisibleConditionVariable;
@property (nonatomic) NSString *pgContentVariable;


//CSS
@property (readonly) IUCSS *css; //used by subclass
- (NSArray *)cssIdentifierArray;
- (void)updateCSS;
- (void)updateCSSWithIdentifiers:(NSArray *)identifiers;
//copy only css;
- (void)copyCSSFromIU:(IUBox *)box;

//HTML
//-(NSString*)html; //DEPRECATED;
- (void)updateHTML;

//children
- (NSArray*)children;
- (NSMutableArray*)allChildren;
- (NSMutableArray *)allIdentifierChildren;


-(BOOL)canAddIUByUserInput;

/**
 removeIUAtIndex:
 @note removeIUAtIndex: uses removeIU: as implementation.
        unregister identifier automatically.
 */
-(BOOL)removeIUAtIndex:(NSUInteger)index;

/**
 removeIU:
 @note unregister identifier automatically.
 */
-(BOOL)removeIU:(IUBox *)iu;
-(BOOL)removeAllIU;

-(BOOL)canRemoveIUByUserInput;
-(BOOL)changeIUIndex:(IUBox*)iu to:(NSUInteger)index error:(NSError**)error;
-(BOOL)addIUReference:(IUBox *)iu error:(NSError**)error;


//Frame
//user interface status


- (NSPoint)originalPoint;
- (NSSize)originalSize;
- (NSSize)currentSize;
- (NSSize)currentPercentSize;

- (BOOL)canChangeWidthByDraggable;
- (BOOL)canChangeHeightByDraggable;

- (void)setPixelX:(CGFloat)pixelX percentX:(CGFloat)percentX;
- (void)setPixelY:(CGFloat)pixelY percentY:(CGFloat)percentY;
- (void)setPixelWidth:(CGFloat)pixelWidth percentWidth:(CGFloat)percentWidth;
- (void)setPixelHeight:(CGFloat)pixelHeight percentHeight:(CGFloat)percentHeight;

- (void)startFrameMoveWithUndoManager;
- (void)endFrameMoveWithUndoManager;

//Position
@property (nonatomic) IUPositionType positionType;
@property (nonatomic) BOOL enableHCenter, enableVCenter;


//Property
- (BOOL)canCopy;
- (BOOL)canChangeOverflow;
- (BOOL)canSelectedWhenOpenProject;
@property (nonatomic) IUOverflowType overflowType;
@property (nonatomic) BOOL lineHeightAuto;

- (void)setImageName:(NSString *)imageName;
- (NSString *)imageName;

@property (nonatomic) id link, divLink;
@property BOOL linkTarget;

/**
 linkCaller use to active state for link caller
 it is allocated before build code
 - (void)checkBeforeBuildCode:(IUBox *)iu target:(IUTarget)target{
 */
@property id linkCaller;


//0 for default, 1 for H1, 2 for H2
@property IUTextType textType;

- (NSString*)cssIdentifier;
- (NSString*)cssHoverClass;
- (NSString*)cssActiveClass;
- (NSString*)cssClassStringForHTML;


#if DEBUG
//test 를 위해서 setting 가능하게 해놓음.
@property (nonatomic) id <IUSourceManagerProtocol> sourceManager;
#else
- (IUSourceManager *)sourceManager;
#endif

@end