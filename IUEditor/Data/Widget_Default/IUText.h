//
//  IUText.h
//  IUEditor
//
//  Created by seungmi on 2014. 11. 25..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUBox.h"

typedef enum{
    IUTextTypeDefault,
    IUTextTypeH1,
    IUTextTypeH2,
}IUTextType;

/**
 @description IUText Widget is text-only object. It cannot have children.
 */

@interface IUText : IUBox

/* default box - already customized box */
+(IUText *)copyrightBox;

//0 for default, 1 for H1, 2 for H2
@property (nonatomic) IUTextType textType;


@end