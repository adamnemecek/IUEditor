//
//  IUCarousel.h
//  IUEditor
//
//  Created by jd on 4/15/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUBox.h"

typedef enum{
    IUCarouselControlBottom,
    IUCarouselControlTypeNone,
    
}IUCarouselControlType;

typedef enum{
    IUCarouselArrowLeft,
    IUCarouselArrowRight,
}IUCarouselArrow;

@interface IUCarousel : IUBox

@property (nonatomic) BOOL autoplay;
@property (nonatomic) NSInteger timer;

@property (nonatomic) NSString *leftArrowImage, *rightArrowImage;
@property (nonatomic) int leftX, leftY, rightX, rightY;


@property (nonatomic) IUCarouselControlType controlType;
@property (nonatomic) NSInteger pagerPosition;
@property (nonatomic) NSColor *selectColor;
@property (nonatomic) NSColor *deselectColor;


- (NSInteger)count;
- (void)setCount:(NSInteger)count;


//css identifier
- (NSString *)pagerWrapperID;
- (NSString *)pagerID;
- (NSString *)pagerIDHover;
- (NSString *)pagerIDActive;
- (NSString *)prevID;
- (NSString *)nextID;

@end