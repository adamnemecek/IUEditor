//
//  IUActionStorage.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 23..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUActionStorage.h"


@implementation IUActionStorage

+ (NSArray *)iuDataList{
    return [IUActionStorage properties];
}

- (id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [super initWithJDCoder:aDecoder];
    if(self){
        _hoverBGColor = [aDecoder decodeObjectForKey:@"hoverBGColor"];
        _hoverBGDuration = [aDecoder decodeObjectForKey:@"hoverBGDuration"];
        _hoverTextColor = [aDecoder decodeObjectForKey:@"hoverTextColor"];
        _hoverTextDuration = [aDecoder decodeObjectForKey:@"hoverTextDuration"];
        _hoverBGPositionX = [aDecoder decodeObjectForKey:@"hoverBGPositionX"];
        _hoverBGPositionY = [aDecoder decodeObjectForKey:@"hoverBGPositionY"];
        
        _activeBGColor = [aDecoder decodeObjectForKey:@"activeBGColor"];
        _activeTextColor = [aDecoder decodeObjectForKey:@"activeTextColor"];
    }
    return self;
}
- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [super encodeWithJDCoder:aCoder];
    
    [aCoder encodeObject:_hoverBGColor forKey:@"hoverBGColor"];
    [aCoder encodeObject:_hoverBGDuration forKey:@"hoverBGDuration"];
    [aCoder encodeObject:_hoverTextColor forKey:@"hoverTextColor"];
    [aCoder encodeObject:_hoverTextDuration forKey:@"hoverTextDuration"];
    [aCoder encodeObject:_hoverBGPositionX forKey:@"hoverBGPositionX"];
    [aCoder encodeObject:_hoverBGPositionY forKey:@"hoverBGPositionY"];
    
    [aCoder encodeObject:_activeBGColor forKey:@"activeBGColor"];
    [aCoder encodeObject:_activeTextColor forKey:@"activeTextColor"];
}

- (id)copyWithZone:(NSZone *)zone{
    IUActionStorage *actionStorage = [super copyWithZone:zone];
    [actionStorage disableUpdate:JD_CURRENT_FUNCTION];
    if(actionStorage){
        actionStorage.hoverBGColor = _hoverBGColor;
        actionStorage.hoverBGDuration = _hoverBGDuration;
        actionStorage.hoverTextColor = _hoverTextColor;
        actionStorage.hoverTextDuration = _hoverTextDuration;
        actionStorage.hoverBGPositionX = _hoverBGPositionX;
        actionStorage.hoverBGPositionY = _hoverBGPositionY;

        actionStorage.activeBGColor = _activeBGColor;
        actionStorage.activeTextColor = _activeTextColor;
        
    }
    [actionStorage enableUpdate:JD_CURRENT_FUNCTION];
    return actionStorage;
}
@end
