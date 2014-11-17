//
//  IUIdentifierManager.h
//  IUEditor
//
//  Created by jd on 4/11/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>


@class IUBox __storage_deprecated;


@interface IUIdentifierManager : NSObject

- (NSString *)createIdentifierWithKey:(NSString *)key;
- (void)addObject:(id)obj withIdentifier:(NSString *)identifier;
- (id)objectForIdentifier:(NSString*)identifier;
- (void)removeIdentifier:(NSString *)identifier;
- (void)commit;
- (void)rollback;


/**************
 
 Following code will be deleted
 
 *************/


-(void)registerIUs:(NSArray*)IUs __storage_deprecated;

/**
 @brief Unregister all IU and children of them
 */
-(void)unregisterIUs:(NSArray*)IUs __storage_deprecated;

/**
 @brief Assign object html id
 @note This function does not assign html id of children. Call this function for each child.
 */
-(void)setNewIdentifierAndRegisterToTemp:(IUBox*)obj withKey:(NSString*)keyString __storage_deprecated;
-(void)setIdentifierAndRegisterToTemp:(IUBox*)obj identifier:(NSString*)identifier __storage_deprecated;
-(void)resetUnconfirmedIUs __storage_deprecated;
-(void)confirm __storage_deprecated;


/**
 @breif Get IU with identifier
 @note This function is used in FileNaviVC
 @return IU which has identifier
 */
-(IUBox*)IUWithIdentifier:(NSString*)identifier __storage_deprecated;


@end
