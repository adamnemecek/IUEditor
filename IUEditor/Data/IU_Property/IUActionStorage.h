//
//  IUActionStorage.h
//  IUEditor
//
//  Created by seungmi on 2014. 12. 23..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUDataStorage.h"
/**
 manage hover, active, scroll data
 */
@interface IUActionStorage : IUDataStorage

@property (nonatomic) NSColor *hoverBGColor;
@property (nonatomic) NSNumber *hoverBGDuration;
@property (nonatomic) NSColor *hoverTextColor;
@property (nonatomic) NSNumber *hoverTextDuration;
@property (nonatomic) NSNumber *hoverBGPositionX;
@property (nonatomic) NSNumber *hoverBGPositionY;

@property (nonatomic) NSColor *activeBGColor;
@property (nonatomic) NSColor *activeTextColor;

@property (nonatomic) NSNumber *scrollXPosition;
@property (nonatomic) NSNumber *scrollYPosition;
@property (nonatomic) NSNumber *scrollOpacity;


@end
