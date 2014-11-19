//
//  IUCSS.h
//  IUEditor
//
//  Created by JD on 3/17/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JDCoder.h"
#import "IUStyleStorage.h"
#import "IUPositionStorage.h"
#import "IUDataStorage.h"

@class IUProject;

@protocol IUCSSDelegate
@required
- (void)updateCSS;
- (NSUndoManager *)undoManager;
- (IUProject *)project;
- (BOOL)isEnabledFrameUndo;
- (void)startFrameMoveWithUndoManager;
- (void)endFrameMoveWithUndoManager;

@end



@interface IUCSS : NSObject <NSCoding, JDCoding, NSCopying>

@property (nonatomic)  NSInteger editViewPort;
@property (nonatomic)  NSInteger maxViewPort;
@property (weak) id  <IUCSSDelegate> delegate;

//set tag, or delete tag
-(void)setValue:(id)value forTag:(IUCSSTag)tag;
-(void)setValue:(id)value forTag:(IUCSSTag)tag forViewport:(NSInteger)width;

-(void)setValueWithoutUpdateCSS:(id)value forTag:(IUCSSTag)tag;
-(void)setValueWithoutUpdateCSS:(id)value forTag:(IUCSSTag)tag forViewport:(NSInteger)width;

/**
 @brief find viewport tag, if there not, return default value for tag
 */
-(id)effectiveValueForTag:(IUCSSTag)tag forViewport:(NSInteger)width;


//remove tag of all tag dictionay in width
-(void)eradicateTag:(IUCSSTag)type;

//get css tag dictionary for specific width
-(void)removeTagDictionaryForViewport:(NSInteger)width;
-(NSDictionary*)tagDictionaryForViewport:(NSInteger)width;
-(NSArray*)allViewports;

/**
 @brief copy max-size cssDictionary to specific width dictionary;
 */
- (void)copyCSSMaxViewPortDictTo:(NSInteger)width;
- (void)copyCSSDictFrom:(NSInteger)fromWidth to:(NSInteger)toWidth;

//observable.
@property (readonly) NSDictionary *effectiveTagDictionary;

- (IUDataStorageManager *)convertToStyleStorageDefaultManager;
- (IUDataStorageManager *)convertToStyleStorageHoverManager;

- (IUDataStorageManager *)convertToPositionStorageDefaultManager;
@end