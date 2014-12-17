//
//  IUIdentifierManager.h
//  IUEditor
//
//  Created by jd on 4/11/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//



#import <Foundation/Foundation.h>

@interface IUIdentifierManager : NSObject


/**
 @description return identifier manager for current main window
 @note even if there is no main window, this function returns shared manager for
        all non-window process
 */
+ (IUIdentifierManager *)managerForMainWindow;
/**
 @brief remove window's manager when window close
 */
+ (void)closeWindow:(NSWindow *)window;

- (void)reset;

- (void)registerObjectRecusively:(id)object withIdentifierKey:(NSString *)identifierKey childrenKey:(NSString *)childrenKey;

/**
 @description create identifier key for object by prefix as object class name. New identifier key is registered to identifier manager
 @note prefix 'IU' will be automatically deleted
 @return (NSString *)identifier : new identifier for object
 */
- (NSString *)createAndRegisterIdentifierWithObject:(id)object;
- (void)registerIdentifier:(NSString *)identifier withObject:(id)object;
- (NSString *)identifierForObject:(id)object;
- (id)objectForIdentifier:(NSString*)identifier;
- (void)removeIdentifier:(NSString *)identifier;

/*
- (BOOL)replaceIdentifier:(NSString *)from withIdentifier:(NSString *)to;
 */

@end