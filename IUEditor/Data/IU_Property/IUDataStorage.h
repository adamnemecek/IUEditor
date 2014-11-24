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


/* frame tags */
typedef enum IUFrameUnit{
    IUFrameUnitPixel,
    IUFrameUnitPercent,
}IUFrameUnit;


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

- (void)overwritingDataStorageForNilValue:(IUDataStorage*)aStorage;

#if DEBUG
- (NSArray *)currentPropertyStackForTest;
#endif


@end

@protocol IUDataStorageManagerDelegate
@optional

@required
- (void)setNeedsToUpdateStorage:(IUDataStorage*)storage;
//js
- (NSRect)currentPercentFrame;
- (NSRect)currentPixelFrame;

@end

/**
 Manage Data(CSS or anything) of IUBox
 
 Change value in liveTagDict or currentTagDict will make KVO-notification to each other.
 
 KVO-Noti :
 viewPort, allViewPorts, liveTagDict, currentTagDict
 
 If updating should be disabled, DO IT AT IUBOX!!!!
 */


@interface IUDataStorageManager : NSObject <JDCoding>

- (id)initWithStorageClassName:(NSString *)className;
- (NSString *)storageClassName;

- (NSArray *)owners;
- (void)addOwner:(id <IUDataStorageManagerDelegate, JDCoding>)box;
- (void)removeOwner:(id <IUDataStorageManagerDelegate, JDCoding>)box;


//@property (weak) id  <IUDataStorageManagerDelegate, JDCoding> box;

@property NSUndoManager *undoManager;
@property (nonatomic) NSInteger currentViewPort;

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





