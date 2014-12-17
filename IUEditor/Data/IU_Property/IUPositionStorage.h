//
//  IUPositionStorage.h
//  IUEditor
//
//  Created by seungmi on 2014. 11. 19..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUDataStorage.h"

@interface IUPositionStorage : IUDataStorage

typedef enum _IUPositionType{
    IUPositionTypeAbsolute,
    IUPositionTypeRelative,
    IUPositionTypeFixed,
}IUPositionType;

typedef enum {
    IUSecondPositionTypeFloatLeft,
    IUSecondPositionTypeFloatRight,
    IUSecondPositionTypeBottom,
}IUSecondPositionType;

/**
 @brief position is css tag 'position', use IUPositionType
 */
@property (nonatomic) NSNumber *position;
/**
 @brief second position use IUSecondPositionType.
 IUSecondPositionTypeFloatLeft, IUSecondPositionTypeFloatRight should be used when position is IUPositionTypeRelative.
 Also IUSecondPositionTypeFloatXXX is css tag 'float'.
 IUSecondPositionTypeBottom shoulde be used when position is IUPositionTypeAbsolute, IUPositionTypeFixed
 IUSecondPositionTypeBottom is run by script.
 */
@property (nonatomic) NSNumber *secondPosition; //Use IUSecondPositionType

@property (nonatomic, readonly) NSNumber* xUnit;
@property (nonatomic, readonly) NSNumber* yUnit;
@property (nonatomic) NSNumber* x;
@property (nonatomic) NSNumber* y;

- (void)setX:(NSNumber *)x unit:(NSNumber *)unit;
- (void)setY:(NSNumber *)y unit:(NSNumber *)unit;

- (void)setCSSValue:(id)value fromCSSforCSSKey:(NSString *)key;

@end
