//
//  IUIdentifierManager.m
//  IUEditor
//
//  Created by jd on 4/11/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUIdentifierManager.h"


@implementation IUIdentifierManager{
    NSMutableDictionary *confirmed;
    NSMutableDictionary *unconfirmed;
}

-(id)init{
    self = [super init];
    confirmed = [NSMutableDictionary dictionary];
    unconfirmed = [NSMutableDictionary dictionary];
    return self;
}

#pragma mark - new Identifier

- (void)dealloc{
    [JDLogUtil log:IULogDealloc string:@"IUIdentifierManager"];
}


/*
 Storage Conversion
 */

 
- (NSString *)createIdentifierWithPrefix:(NSString *)prefix{
    int i=0;
    NSString *modifiedPrefix = prefix;
    if ([[prefix substringToIndex:2] isEqualTo:@"IU"]) {
        modifiedPrefix = [prefix substringFromIndex:2];
    }
    while (1) {
        i++;
        NSString *newIdentifier = [NSString stringWithFormat:@"%@%d", modifiedPrefix, i];
        if (confirmed[newIdentifier] == nil && unconfirmed[newIdentifier] == nil ) {
            return newIdentifier;
        }
        
        if (i > 10000){
            //while loop break;
            //the maximum number of iu : 10000
            break;
        }
    }
    return nil;
}


- (void)addObject:(id)obj{
    NSString *identifier = [obj valueForKey:_identifierKey];
    unconfirmed[identifier] = obj;
    
    for(id child in [obj valueForKey:_childrenKey]){
        [self addObject:child];
    }
}


- (void)addObjects:(id)objs{
    for(id obj in objs){
        [self addObject:obj];
    }
}

- (id)objectForIdentifier:(NSString*)identifier{
    if (unconfirmed[identifier]){
        return unconfirmed[identifier];
    }
    return confirmed[identifier];
}

- (void)removeIdentifier:(NSString *)identifier{
    [unconfirmed removeObjectForKey:identifier];
    [confirmed removeObjectForKey:identifier];
}

- (void)commit {
    [unconfirmed enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        confirmed[key] = obj;
    }];
    [unconfirmed removeAllObjects];
}
- (void)rollback{
    [unconfirmed removeAllObjects];
}

@end
