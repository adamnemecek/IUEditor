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

@protocol IUSourceDelegate <NSObject>
@required

//enable, disable update
- (void)enableUpdateAll:(id)sender;
- (void)disableUpdateAll:(id)sender;
- (void)enableUpdateCSS:(id)sender;
- (void)disableUpdateCSS:(id)sender;
- (BOOL)isUpdateCSSEnabled;
- (void)enableUpdateJS:(id)sender;
- (void)disableUpdateJS:(id)sender;
- (BOOL)isUpdateJSEnabled;
- (void)enableUpdateHTML:(id)sender;
- (void)disableUpdateHTML:(id)sender;
- (BOOL)isUpdateHTMLEnabled;

//css update
-(void)IUClassIdentifier:(NSString *)identifier CSSUpdated:(NSString*)css;
//style-sheet css
-(void)removeCSSTextInDefaultSheetWithIdentifier:(NSString *)identifier;

//js update (frame)
- (void)updateJS;

//html update
-(void)IUHTMLIdentifier:(NSString *)identifier HTML:(NSString *)html withParentID:(NSString *)parentID;

-(void)IUClassIdentifier:(NSString *)classIdentifier addClass:(NSString *)className;
-(void)IUClassIdentifier:(NSString *)classIdentifier removeClass:(NSString *)className;

-(void)IURemoved:(NSString*)identifier withParentID:(NSString *)parentID;

- (NSPoint)distanceFromIU:(NSString *)iuName to:(NSString *)parentName;
- (NSSize)frameSize:(NSString *)identifier;
- (NSInteger)countOfLineWithIdentifier:(NSString *)identifier;
/**
 @brief call javascript function
 @param args javascirpt function argument, argument에 들어가는 것중에 dict, array는 string으로 보내서javascript내부에서 새로 var를 만들어서 사용
*/
- (id)callWebScriptMethod:(NSString *)function withArguments:(NSArray *)args;
- (id)evaluateWebScript:(NSString *)script;


@end

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

@class IUBox;
@class IUSheet;
@class IUProject;

@interface IUBox : NSObject <NSCoding, NSCopying, JDCoding, IUCSSDelegate, IUMQDataDelegate>{
    NSMutableArray *_m_children;
    
}

/* default box */
+(IUBox *)copyrightBoxWithProject:(IUProject*)project;

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
-(id)initWithProject:(IUProject*)project options:(NSDictionary*)options;
- (void)connectWithEditor;
- (void)disconnectWithEditor;

- (BOOL)isConnectedWithEditor;
- (void)setIsConnectedWithEditor;

-(IUSheet *)sheet;


/**
 @brief return project of box
 @note if iu is not confirmed, return project argument at initialize process
 */
-(IUProject *)project;

#pragma mark - IU Setting

@property (copy, nonatomic) NSString *name;
@property (copy) NSString *htmlID;
- (void)confirmIdentifier;

@property (nonatomic, weak) id<IUSourceDelegate> delegate;
@property (weak) IUBox    *parent;

#if CURRENT_TEXT_VERSION < TEXT_SELECTION_VERSION
@property (nonatomic) NSString *text;

#endif
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
-(BOOL)shouldCompileChildrenForOutput;

-(BOOL)insertIU:(IUBox *)iu atIndex:(NSInteger)index  error:(NSError**)error;
-(BOOL)addIU:(IUBox *)iu error:(NSError**)error;

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
@property (readonly) BOOL canChangeXByUserInput;
@property (readonly) BOOL canChangeYByUserInput;
@property (readonly) BOOL canChangeWidthByUserInput;
@property (readonly) BOOL canChangeWidthUnitByUserInput;
@property (readonly) BOOL canChangeHeightByUserInput;

- (BOOL)shouldCompileX;
- (BOOL)shouldCompileY;
- (BOOL)shouldCompileWidth;
- (BOOL)shouldCompileHeight;
- (BOOL)shouldCompileFontInfo;
- (BOOL)shouldCompileImagePositionInfo;

- (void)setX:(float)x;
- (void)setY:(float)y;

- (void)startFrameMoveWithUndoManager;
- (void)endFrameMoveWithUndoManager;
- (void)movePosition:(NSPoint)point withParentSize:(NSSize)parentSize;
- (void)increaseSize:(NSSize)size withParentSize:(NSSize)parentSize;
- (NSSize)currentApproximatePixelSize;


//Position
@property (nonatomic) IUPositionType positionType;
@property (nonatomic) BOOL enableHCenter, enableVCenter;
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

//can move to other parent?
- (BOOL)canMoveToOtherParent;


@property IUCSSStorageManager *cssManager;

@end