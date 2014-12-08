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

@property NSString *identifierKeyPath; // keyPath to identifier
@property NSString *childrenKeyPath; //keyPath to children


- (NSString *)createIdentifierWithPrefix:(NSString *)prefix;
- (void)addObject:(id)obj;
- (void)addObjects:(id)objs;
- (id)objectForIdentifier:(NSString*)identifier;
- (void)removeIdentifier:(NSString *)identifier;
- (void)commit;
- (void)rollback;


@end


