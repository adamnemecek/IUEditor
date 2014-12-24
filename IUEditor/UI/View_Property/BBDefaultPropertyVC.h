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
#import "JDMemoryCheck.h"

@interface BBDefaultPropertyVC : JDMemoryCheckVC

@property (nonatomic, weak) IUController      *iuController;
//resource root
@property (nonatomic, weak) IUResourceRootItem *resourceRootItem;


//binding to cascadingStorageProperty or default property of selected iubox
- (void)outlet:(id)outlet bind:(NSString *)binding cascadingStyleStorageProperty:(NSString *)property;
- (void)outlet:(id)outlet bind:(NSString *)binding cascadingPositionStorageProperty:(NSString *)property;
- (void)outlet:(id)outlet bind:(NSString *)binding cascadingActionStorageProperty:(NSString *)property;
- (void)outlet:(id)outlet bind:(NSString *)binding cascadingPropertyStorageProperty:(NSString *)property;
- (void)outlet:(id)outlet bind:(NSString *)binding property:(NSString *)property;



- (void)outlet:(id)outlet bind:(NSString *)binding cascadingStyleStorageProperty:(NSString *)property options:(NSDictionary *)options;
- (void)outlet:(id)outlet bind:(NSString *)binding cascadingPositionStorageProperty:(NSString *)property options:(NSDictionary *)options;
- (void)outlet:(id)outlet bind:(NSString *)binding cascadingActionStorageProperty:(NSString *)property options:(NSDictionary *)options;
- (void)outlet:(id)outlet bind:(NSString *)binding cascadingPropertyStorageProperty:(NSString *)property options:(NSDictionary *)options;
- (void)outlet:(id)outlet bind:(NSString *)binding property:(NSString *)property options:(NSDictionary *)options;

//get cascadingStorage
- (IUStyleStorage *)cascadingStyleStorage;
- (IUPositionStorage *)cascadingPositionStorage;
- (IUPropertyStorage *)cascadingPropertyStorage;
- (IUActionStorage *)cascadingActionStorage;

//get property value
- (id)valueForProperty:(NSString *)property;

@end
