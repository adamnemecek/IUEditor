//
//  IUPositionStorage.h
//  IUEditor
//
//  Created by seungmi on 2014. 11. 19..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUDataStorage.h"

@interface IUPositionStorage : IUDataStorage


@property (nonatomic) NSNumber *position; //Use IUPositionType

@property (nonatomic, readonly) NSNumber* xUnit;
@property (nonatomic, readonly) NSNumber* yUnit;
@property (nonatomic) NSNumber* x;
@property (nonatomic) NSNumber* y;

- (void)setX:(NSNumber *)x unit:(NSNumber *)unit;
- (void)setY:(NSNumber *)y unit:(NSNumber *)unit;

- (void)setCSSValue:(id)value fromCSSforCSSKey:(NSString *)key;

@end
