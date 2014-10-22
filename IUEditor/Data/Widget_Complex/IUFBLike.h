//
//  IUFBLike.h
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 4. 23..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUHTML.h"

typedef enum{
 IUFBLikeColorLight,
 IUFBLikeColorDark,
}IUFBLikeColor;

/**
 @brief
 FBLike의 경우 css가 조합되어 html이 생성되기 때문에
 IUBox의 subclass가 아니라 IUHTML의 subclass로 만들어서 innerHTML을 사용
 */
@interface IUFBLike : IUHTML

@property (nonatomic) NSString *likePage;
@property (nonatomic) BOOL showFriendsFace;
@property (nonatomic) IUFBLikeColor colorscheme;

@end
