//
//  SizeBox.h
//  IUCanvas
//
//  Created by ChoiSeungmi on 2014. 4. 1..
//  Copyright (c) 2014년 ChoiSeungmi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


#if 0

/**
@brief Deprecated 141029
 */
__attribute__((deprecated))
@interface InnerSizeBox : NSBox

@property id boxDelegate;

- (id)initWithFrame:(NSRect)frame width:(NSInteger)aWidth;
- (NSInteger)frameWidth;
- (void)select;

- (void)setSmallerColor;
- (void)setLargerColor;


@end

#endif

