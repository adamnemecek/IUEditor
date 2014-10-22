//
//  WPCommentFormField.h
//  IUEditor
//
//  Created by jd on 9/10/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUBox.h"
#import "IUProtocols.h"

typedef enum _WPCommentFormFieldType{
    WPCommentFormFieldLeaveAReply,
    WPCommentFormFieldCommentBefore,
    WPCommentFormFieldCommentAfter,
    WPCommentFormFieldAuthorLabel,
    WPCommentFormFieldEmailLabel,
    WPCommentFormFieldContentLabel,
} WPCommentFormFieldType;

@interface WPCommentFormField : IUBox <IUSampleHTMLProtocol, IUPHPCodeProtocol>

@property (nonatomic) WPCommentFormFieldType fieldType;

@end
