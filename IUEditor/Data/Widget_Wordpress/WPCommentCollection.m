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

- (id)initWithPreset{
    self = [super initWithPreset];
    if (self) {
        
        [self.undoManager disableUndoRegistration];
        
        self.defaultPositionStorage.position = @(IUPositionTypeRelative);
        
        [self.defaultStyleStorage setWidth:@(100) unit:@(IUFrameUnitPercent)];
        self.defaultStyleStorage.height = nil;
        

        /* WPCommentForm */
        WPCommentObject *authorObj = [[WPCommentObject alloc] initWithPreset];
        authorObj.objType = WPCommentObjectTypeAuthor;
        
        authorObj.defaultStyleStorage.height = nil;
        authorObj.defaultStyleStorage.width = nil;
        authorObj.defaultPositionStorage.position = @(IUPositionTypeRelative);
        
        [self addIU:authorObj error:nil];
        
        WPCommentObject *dateObj = [[WPCommentObject alloc] initWithPreset];
        dateObj.objType = WPCommentObjectTypeDate;
        
        dateObj.defaultStyleStorage.height = nil;
        dateObj.defaultStyleStorage.width = nil;
        dateObj.defaultPositionStorage.position = @(IUPositionTypeRelative);

        [self addIU:dateObj error:nil];

        WPCommentObject *commentObj = [[WPCommentObject alloc] initWithPreset];
        commentObj.objType = WPCommentObjectTypeContent;
        commentObj.defaultStyleStorage.height = nil;
        commentObj.defaultStyleStorage.width = nil;
        commentObj.defaultPositionStorage.position = @(IUPositionTypeRelative);
        
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
