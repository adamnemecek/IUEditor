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
    IUFirstPositionTypeAbsolute,
    IUFirstPositionTypeRelative,
    IUFirstPositionTypeFixed,
}IUFirstPositionType;

typedef enum {
    IUSecondPositionTypeFloatLeft,
    IUSecondPositionTypeFloatRight,
    IUSecondPositionTypeBottom,
}IUSecondPositionType;

/**
 @brief position is css tag 'position', use IUFirstPositionType
 */
@property (nonatomic) NSNumber *firstPosition;
/**
 @brief second position use IUSecondPositionType.
 IUSecondPositionTypeFloatLeft, IUSecondPositionTypeFloatRight should be used when position is IUFirstPositionTypeRelative.
 Also IUSecondPositionTypeFloatXXX is css tag 'float'.
 IUSecondPositionTypeBottom shoulde be used when position is IUFirstPositionTypeAbsolute, IUFirstPositionTypeFixed
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
