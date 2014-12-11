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
}

-(id)init{
    self = [super init];
    confirmed = [NSMutableDictionary dictionary];
    return self;
}

#pragma mark - new Identifier

- (void)dealloc{
    [JDLogUtil log:IULogDealloc string:@"IUIdentifierManager"];
}


/*
 Storage Conversion
 */

 
- (NSString *)createAndRegisterIdentifierWithObject:(id)object{
    int i=0;
    NSString *prefix = [object className];
    if ([[prefix substringToIndex:2] isEqualTo:@"IU"]) {
        prefix = [prefix substringFromIndex:2];
    }
    while (1) {
        i++;
        NSString *newIdentifier = [NSString stringWithFormat:@"%@%d", prefix, i];
        if (confirmed[newIdentifier] == nil) {
            confirmed[newIdentifier] = object;
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
- (void)registerIdentifier:(NSString *)identifier withObject:(id)object{
    confirmed[identifier] = object;
}


- (NSString *)identifierForObject:(id)object{
    NSArray *keys = [confirmed allKeysForObject:object];
    NSAssert(keys.count > 0, @"key is not identical");
    if(keys.count == 1){
        return keys[0];
    }
    return nil;
}


- (id)objectForIdentifier:(NSString*)identifier{
    return confirmed[identifier];
}

- (void)removeIdentifier:(NSString *)identifier{
    [confirmed removeObjectForKey:identifier];
}

- (BOOL)replaceIdentifier:(NSString *)from withIdentifier:(NSString *)to{
    id object = confirmed[from];
    if(object){
        [self removeIdentifier:object];
        confirmed[to] = object;
        return YES;
    }
    return NO;
}

@end
