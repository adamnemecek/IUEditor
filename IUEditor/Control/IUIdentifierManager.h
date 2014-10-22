//
//  IUIdentifierManager.h
//  IUEditor
//
//  Created by jd on 4/11/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>


@class IUBox;
@interface IUIdentifierManager : NSObject


-(void)registerIUs:(NSArray*)IUs;

/**
 @brief Unregister all IU and children of them
 */
-(void)unregisterIUs:(NSArray*)IUs;

/**
 @brief Assign object html id
 @note This function does not assign html id of children. Call this function for each child.
 */
-(void)setNewIdentifierAndRegisterToTemp:(IUBox*)obj withKey:(NSString*)keyString;
-(void)setIdentifierAndRegisterToTemp:(IUBox*)obj identifier:(NSString*)identifier;
-(void)resetUnconfirmedIUs;
-(void)confirm;


/**
 @breif Get IU with identifier
 @note This function is used in FileNaviVC
 @return IU which has identifier
 */
-(IUBox*)IUWithIdentifier:(NSString*)identifier;

@end
