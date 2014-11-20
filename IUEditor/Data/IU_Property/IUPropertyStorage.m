//
//  IUPropertyStorage.m
//  IUEditor
//
//  Created by seungmi on 2014. 11. 19..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUPropertyStorage.h"

@implementation IUPropertyStorage


+ (NSArray *)observingList{
    return [IUPropertyStorage properties];
}

- (id)copyWithZone:(NSZone *)zone{
    IUPropertyStorage *copyStorage = [super copyWithZone:zone];
    [copyStorage disableUpdate:JD_CURRENT_FUNCTION];
    
    if(copyStorage){
        copyStorage.innerHTML = _innerHTML;
        copyStorage.collectionCount = _collectionCount;
    }
    [copyStorage enableUpdate:JD_CURRENT_FUNCTION];
    return copyStorage;
}

#pragma mark - property

/* it's for conversion */
- (void)setPropertyValue:(id)value fromMQDataforKey:(NSString *)key{
    [self setValue:value forKey:key];
}


@end
