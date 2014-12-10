//
//  BBDefaultPropertyVC.h
//  IUEditor
//
//  Created by seungmi on 2014. 12. 8..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IUController.h"
#import "IUResource.h"

@interface BBDefaultPropertyVC : NSViewController

@property (nonatomic, weak) IUController      *iuController;
//resource root
@property (nonatomic, weak) IUResourceRootItem *resourceRootItem;


//binding to liveStorageProperty or default property of selected iubox
- (void)outlet:(id)outlet bind:(NSString *)binding liveStyleStorageProperty:(NSString *)property;
- (void)outlet:(id)outlet bind:(NSString *)binding livePositionStorageProperty:(NSString *)property;
- (void)outlet:(id)outlet bind:(NSString *)binding livePropertyStorageProperty:(NSString *)property;
- (void)outlet:(id)outlet bind:(NSString *)binding property:(NSString *)property;


- (void)outlet:(id)outlet bind:(NSString *)binding liveStyleStorageProperty:(NSString *)property options:(NSDictionary *)options;
- (void)outlet:(id)outlet bind:(NSString *)binding livePositionStorageProperty:(NSString *)property options:(NSDictionary *)options;
- (void)outlet:(id)outlet bind:(NSString *)binding livePropertyStorageProperty:(NSString *)property options:(NSDictionary *)options;
- (void)outlet:(id)outlet bind:(NSString *)binding property:(NSString *)property options:(NSDictionary *)options;

//get liveStorage
- (IUStyleStorage *)liveStyleStorage;
- (IUPositionStorage *)livePositionStorage;
- (IUPropertyStorage *)livePropertyStorage;

@end
