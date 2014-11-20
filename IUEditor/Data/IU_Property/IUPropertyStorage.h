//
//  IUPropertyStorage.h
//  IUEditor
//
//  Created by seungmi on 2014. 11. 19..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUDataStorage.h"

/**
@brief 
 IUPropertyStorage supports properties changed by media query, but not css properties.
 */
@interface IUPropertyStorage : IUDataStorage

@property (nonatomic, copy) NSString* innerHTML;
@property (nonatomic) NSNumber* collectionCount;

- (void)setPropertyValue:(id)value fromMQDataforKey:(NSString *)key;

@end
