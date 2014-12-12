//
//  IUPropertyStorage.m
//  IUEditor
//
//  Created by seungmi on 2014. 11. 19..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUPropertyStorage.h"

@implementation IUPropertyStorage


+ (NSArray *)iuDataList{
    return [IUPropertyStorage properties];
}

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [super encodeWithJDCoder:aCoder];
    
    [aCoder encodeObject:_innerHTML forKey:@"innerHTML"];
    [aCoder encodeObject:_collectionCount forKey:@"collectionCount"];
    [aCoder encodeObject:_carouselArrowDisable forKey:@"carouselArrowDisable"];
}
- (id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [super initWithJDCoder:aDecoder];
    if (self) {
        _innerHTML = [aDecoder decodeObjectForKey:@"innerHTML"];
        _collectionCount = [aDecoder decodeObjectForKey:@"collectionCount"];
        _carouselArrowDisable = [aDecoder decodeObjectForKey:@"carouselArrowDisable"];
    }
    return self;
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
