//
//  IUBox.h
//  IUEditor
//
//  Created by JD on 3/18/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JDCoder.h"

#import "IUIdentifierManager.h"
#import "IUProjectProtocol.h"

#import "IUEvent.h"

#import "IUDataStorage.h"
#import "IUStyleStorage.h"
#import "IUPositionStorage.h"
#import "IUPropertyStorage.h"


#import "IUSourceDelegate.h"
#import "IUSourceManagerProtocol.h"

#import "IUEvent2.h"

typedef enum{
    IUWidgetTypePrimary,
    IUWidgetTypeSecondary,
    IUWidgetTypePG,
    IUWidgetTypeWP,
}IUWidgetType;

/* widget type */
static NSString *kIUWidgetTypePrimary = @"Primary";
static NSString *kIUWidgetTypeSecondary = @"Secondary";
static NSString *kIUWidgetTypeProgramming = @"Programming";
static NSString *kIUWidgetTypeWordpress = @"Wordpress";


typedef enum{
    IUTextInputTypeNone,
    IUTextInputTypeEditable,
    IUTextInputTypeAddible,
    IUTextInputTypeTextField,
}IUTextInputType;



/* default data manager name */
static NSString *kIUStyleManager = @"styleManager";
static NSString *kIUStyleHoverManager = @"styleManagerHover";
static NSString *kIUStyleActiveManager = @"styleManagerActive";
static NSString *kIUPositionManager = @"positionManager";
static NSString *kIUPropertyManager = @"propertyManager";

@class IUBox;
@class IUSheet;
@class IUProject;


@interface IUBox : NSObject <NSCopying, JDCoding, IUDataStorageManagerDelegate>{
    /* children */
    NSMutableArray *_m_children;
    
    /* data storage */
    NSMutableDictionary *_m_storageManagerDict;
    IUStyleStorage *_liveStyleStorage;
    IUStyleStorage *_currentStyleStorage;
}

+ (NSImage *)classImage;
+ (NSImage *)navigationImage;
+ (NSString *)shortDescription;
+ (NSString *)widgetType;

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

- (BOOL)canChangeWidthByDraggable;
- (BOOL)canChangeHeightByDraggable;


@property BOOL removed; // iu is removed;

@property (readonly) IUStyleStorage *defaultStyleStorage;
@property (readonly) IUStyleStorage *liveStyleStorage;
@property (readonly) IUStyleStorage *currentStyleStorage;

@property (readonly) IUPositionStorage *defaultPositionStorage;
@property (readonly) IUPositionStorage *livePositionStorage;
@property (readonly) IUPositionStorage *currentPositionStorage;

@property (readonly) IUPropertyStorage *defaultPropertyStorage;
@property (readonly) IUPropertyStorage *livePropertyStorage;
@property (readonly) IUPropertyStorage *currentPropertyStorage;


- (NSArray *)allCSSSelectors;
- (NSInteger)maxViewPort;
@property NSInteger currentViewPort;

- (void)setStorageManager:(IUDataStorageManager *)cssManager forSelector:(NSString *)selector;
- (IUDataStorageManager *)dataManagerForSelector:(NSString *)selector;
- (IUDataStorageManager *)defaultStyleManager;
- (IUDataStorageManager *)hoverStyleManager;
- (IUDataStorageManager *)positionManager;
- (IUDataStorageManager *)propertyManager;

- (NSArray *)events;
- (NSArray *)eventsCalledByOtherIU:(IUEvent2 *)event;

- (void)addEvent:(IUEvent2 *)event;
- (void)addEventCalledByOtherIU:(IUEvent2 *)event;
- (void)removeEvent:(IUEvent2 *)event;

#if DEBUG
//test 를 위해서 setting 가능하게 해놓음.
@property (nonatomic) id <IUSourceManagerProtocol> sourceManager;
#else
- (id <IUSourceManagerProtocol>) sourceManager;
- (IUIdentifierManager *) identifierManager;
#endif


/* call by grid view */
- (void)startFrameMoveWithTransactionForStartFrame:(NSRect)frame;
- (void)endFrameMoveWithTransaction;
- (NSRect)originalFrame;


//undoManager
- (NSUndoManager *)undoManager;


//Position
@property (nonatomic) BOOL enableHCenter, enableVCenter;


//CSS
- (NSArray *)cssIdentifierArray;
- (void)updateCSS;
- (void)updateCSSWithIdentifiers:(NSArray *)identifiers;

//HTML
- (void)updateHTML;










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

- (void)connectWithEditor;
- (void)disconnectWithEditor;

- (BOOL)isConnectedWithEditor;
- (void)setIsConnectedWithEditor;


#pragma mark - IU Setting
- (IUTextInputType)textInputType;



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


//children
- (NSArray*)children;

- (NSMutableArray*)allChildren;


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

//- (BOOL)canChangeWidthByDraggable;
//- (BOOL)canChangeHeightByDraggable;




//Property
- (BOOL)canCopy;
- (BOOL)canChangeOverflow;
- (BOOL)canSelectedWhenOpenProject;
@property (nonatomic) IUOverflowType overflowType __deprecated;
@property (nonatomic) BOOL lineHeightAuto;
@property (nonatomic) id link;
@property (nonatomic, weak) id divLink;
@property BOOL linkTarget;

/**
 linkCaller use to active state for link caller
 it is allocated before build code
 - (void)checkBeforeBuildCode:(IUBox *)iu target:(IUTarget)target{
 */
@property id linkCaller;

- (NSString*)cssIdentifier;
- (NSString*)cssHoverClass;
- (NSString*)cssActiveClass;
- (NSString*)cssClassStringForHTML;
- (BOOL)containClass:(Class)class;
@end