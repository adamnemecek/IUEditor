//
//  WPCommentObject.h
//  IUEditor
//
//  Created by jd on 9/3/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUBox.h"
#import "IUProtocols.h"

typedef enum _WPCommentObjectType{
    WPCommentObjectTypeContent,
    WPCommentObjectTypeAuthor,
    WPCommentObjectTypeDate,
    WPCommentObjectTypeEmail,
    WPCommentObjectTypeURL,
}WPCommentObjectType;

@interface WPCommentObject : IUBox <IUPHPCodeProtocol, IUSampleHTMLProtocol>

@property (nonatomic) WPCommentObjectType objType;
@property (nonatomic) BOOL                linkToURL;

@end
