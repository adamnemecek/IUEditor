//
//  WPCommentForm.h
//  IUEditor
//
//  Created by jd on 9/3/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUBox.h"
#import "IUProtocols.h"

typedef enum _WPCommentFormType {
    WPCommentFormTypeAuthor,
    WPCommentFormTypeEmail,
    WPCommentFormTypeWebsite,
    WPCommentFormTypeContent,
}WPCommentFormType;


@interface WPCommentForm : IUBox <IUSampleHTMLProtocol, IUPHPCodeProtocol>

@property (nonatomic) WPCommentFormType formType;

@end