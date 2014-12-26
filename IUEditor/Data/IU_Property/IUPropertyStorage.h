
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
 IUPropertyStorage supports properties changed by media query.
 
 A property can be a iubox specific property (e.g)carousel, collectioncount
 A property can be a html property, not a css property
 (this property is supported by javascript)
 
 */
@interface IUPropertyStorage : IUDataStorage

/**
 property for IUCollection
 */
@property (nonatomic) NSNumber* collectionCount;
/**
 property for IUCarousel
 static NSString *IUCSSTagCarouselArrowDisable = @"carouselDisable";
*/
@property (nonatomic) NSNumber* carouselArrowDisable;


/**
 property for IUText
 */
@property (nonatomic) NSString* innerHTML;
/**
 Programming ellipsis line for IUText
 */
@property (nonatomic) NSString *pgEllipsisLine;


- (void)setPropertyValue:(id)value fromMQDataforKey:(NSString *)key;

@end
