//
//  IUPositionStorage.m
//  IUEditor
//
//  Created by seungmi on 2014. 11. 19..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUPositionStorage.h"

@interface IUPositionStorage()

@property NSNumber* xUnit;
@property NSNumber* yUnit;

@end
@implementation IUPositionStorage

+ (NSArray *)iuDataList{
    return [IUPositionStorage properties];
}

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [super encodeWithJDCoder:aCoder];
    
    [aCoder encodeObject:_position forKey:@"position"];
    [aCoder encodeObject:_xUnit forKey:@"xUnit"];
    [aCoder encodeObject:_yUnit forKey:@"yUnit"];
    [aCoder encodeObject:_x forKey:@"x"];
    [aCoder encodeObject:_y forKey:@"y"];
    
}
- (id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [super initWithJDCoder:aDecoder];
    if (self){
        
        _position = [aDecoder decodeObjectForKey:@"position"];
        _xUnit = [aDecoder decodeObjectForKey:@"xUnit"];
        _yUnit = [aDecoder decodeObjectForKey:@"yUnit"];
        _x = [aDecoder decodeObjectForKey:@"x"];
        _y = [aDecoder decodeObjectForKey:@"y"];
        
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone{
    IUPositionStorage *copyStorage = [super copyWithZone:zone];
    [copyStorage disableUpdate:JD_CURRENT_FUNCTION];
    
    if(copyStorage){
        copyStorage.position = _position;
        copyStorage.xUnit = _xUnit;
        copyStorage.yUnit = _yUnit;
        copyStorage.x = _x;
        copyStorage.y = _y;
    }
    
    [copyStorage enableUpdate:JD_CURRENT_FUNCTION];
    return copyStorage;
}


- (void)setX:(NSNumber *)x unit:(NSNumber *)unit{
    [self beginTransaction:JD_CURRENT_FUNCTION];
    [self setX:x];
    [self setXUnit:unit];
    [self commitTransaction:JD_CURRENT_FUNCTION];
}

- (void)setY:(NSNumber *)y unit:(NSNumber *)unit{
    [self beginTransaction:JD_CURRENT_FUNCTION];
    [self setY:y];
    [self setYUnit:unit];
    [self commitTransaction:JD_CURRENT_FUNCTION];
}


- (void)overwritingDataStorageForNilValue:(IUPositionStorage*)aStorage{
    [super overwritingDataStorageForNilValue:aStorage];
    /* remove update manager for temporary */
    if (self.x == nil && aStorage.x != nil) {
        self.x = aStorage.x;
    }
}


/* it's for conversion */
- (void)setCSSValue:(id)value fromCSSforCSSKey:(NSString *)key{
    [self setValue:value forKey:key];
}


@end
