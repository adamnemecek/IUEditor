//
//  WPComment.m
//  IUEditor
//
//  Created by jd on 9/2/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "WPCommentCollection.h"

#import "WPCommentAvator.h"
#import "WPCommentReplyBtn.h"
#import "PGForm.h"
#import "PGSubmitButton.h"

#import "WPCommentObject.h"

@interface WPCommentCollection()

@property (nonatomic) WPCommentAvator *avatar;
@property (nonatomic) IUBox *saying;
@end

@implementation WPCommentCollection

- (id)initWithProject:(id <IUProjectProtocol>)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    if (self) {
        
        [self.undoManager disableUndoRegistration];
        
        
        self.positionType = IUPositionTypeRelative;
        [self.css setValue:@(YES) forTag:IUCSSTagWidthUnitIsPercent forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(100) forTag:IUCSSTagPercentWidth forViewport:IUCSSDefaultViewPort];
        [self.css eradicateTag:IUCSSTagPixelHeight];

        /* WPCommentForm */
        WPCommentObject *authorObj = [[WPCommentObject alloc] initWithProject:project options:options];
        authorObj.objType = WPCommentObjectTypeAuthor;
        [authorObj.css eradicateTag:IUCSSTagPixelHeight];
        [authorObj.css eradicateTag:IUCSSTagPixelWidth];
        authorObj.positionType = IUPositionTypeRelative;
        [self addIU:authorObj error:nil];
        
        WPCommentObject *dateObj = [[WPCommentObject alloc] initWithProject:project options:options];
        dateObj.objType = WPCommentObjectTypeDate;
        [dateObj.css eradicateTag:IUCSSTagPixelHeight];
        [dateObj.css eradicateTag:IUCSSTagPixelWidth];
        dateObj.positionType = IUPositionTypeRelative;
        [self addIU:dateObj error:nil];

        WPCommentObject *commentObj = [[WPCommentObject alloc] initWithProject:project options:options];
        commentObj.objType = WPCommentObjectTypeContent;
        [commentObj.css eradicateTag:IUCSSTagPixelHeight];
        [commentObj.css eradicateTag:IUCSSTagPixelWidth];
        commentObj.positionType = IUPositionTypeRelative;
        [self addIU:commentObj error:nil];
        
        [self.undoManager enableUndoRegistration];
    }
    return self;
}


- (NSString*)code{
    return @"<?php\n\
    $args = array(\n\
    // args here\n\
    );\n\
    \n\
    $comments_query = new WP_Comment_Query;\n\
    $comments = array_reverse($comments_query->query( $args ));\n\
    // Comment Loop\n\
    if ( $comments ) {\n\
    foreach ( $comments as $comment ) { ?>\n";
}

- (NSString*)codeAfterChildren{
    return @"<?\n\
            }\n\
        } else {\n\
        echo 'No comments found.';\n\
    }\n\
    ?>";
}


@end
