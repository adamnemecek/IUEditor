//
//  IUIdentifierManager.h
//  IUEditor
//
//  Created by jd on 4/11/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//



#import <Foundation/Foundation.h>

@interface IUIdentifierManager : NSObject

@property NSString *identifierKey; // keyPath to identifier
@property NSString *childrenKey; //keyPath to children

/**
 @description create identifier key for object
 @note prefix 'IU' will be automatically deleted at prefix
 */
- (NSString *)createIdentifierWithPrefix:(NSString *)prefix;

- (void)addObject:(id)obj;
- (void)addObjects:(id)objs;
- (id)objectForIdentifier:(NSString*)identifier;
- (void)removeIdentifier:(NSString *)identifier;
- (void)commit;
- (void)rollback;


@end