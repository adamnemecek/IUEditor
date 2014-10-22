//
//  WPContentCollection.h
//  IUEditor
//
//  Created by jw on 7/15/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUBox.h"

@interface WPArticle : IUBox

@property (nonatomic) BOOL enableTitle;
@property (nonatomic) BOOL enableDate;
@property (nonatomic) BOOL enableBody;
@property (nonatomic) BOOL enableComment;
@property (nonatomic) BOOL enableCommentForm;

@end
