//
//  WPCommentObject.m
//  IUEditor
//
//  Created by jd on 9/3/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "WPCommentObject.h"

@implementation WPCommentObject

- (void)setObjType:(WPCommentObjectType)objType{
    _objType = objType;
    [self updateHTML];
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[WPCommentObject properties]];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    [aDecoder decodeToObject:self withProperties:[WPCommentObject properties]];
    return self;
}

- (NSString*)sampleInnerHTML{
    switch (self.objType) {
        case WPCommentObjectTypeContent:
            return @"You should do better";
        case WPCommentObjectTypeDate:
            return @"Oct. 18. 2014";
        case WPCommentObjectTypeAuthor:
            return @"Bill Gates";
        case WPCommentObjectTypeEmail:
            return @"bill@microsoft.com";
        case WPCommentObjectTypeURL:
            return @"www.jdlab.org";
        default:
            break;
    }
}

- (NSString*)code{
    switch (self.objType) {
        case WPCommentObjectTypeContent:
            return @"<? echo $comment->comment_content ?>";
        case WPCommentObjectTypeDate:
            return @"<? echo $comment->comment_date ?>";
        case WPCommentObjectTypeAuthor:
            return @"<? echo $comment->comment_author ?>";
        case WPCommentObjectTypeEmail:
            return @"<? echo $comment->comment_author_email ?>";
        case WPCommentObjectTypeURL:
            return @"<? echo $comment->comment_author_url ?>";
        default:
            break;
    }
}

@end
