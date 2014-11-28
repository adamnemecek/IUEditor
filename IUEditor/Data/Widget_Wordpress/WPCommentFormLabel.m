//
//  WPCommentFormLabel.m
//  IUEditor
//
//  Created by jd on 9/17/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "WPCommentFormLabel.h"

@implementation WPCommentFormLabel

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    [aDecoder decodeToObject:self withProperties:[WPCommentFormLabel properties]];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[WPCommentFormLabel properties]];
}


- (id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [super initWithJDCoder:aDecoder];
    if(self){
        [self.undoManager disableUndoRegistration];
        [aDecoder decodeToObject:self withProperties:[WPCommentFormLabel properties]];
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [super encodeWithJDCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[WPCommentFormLabel properties]];
}


- (NSString*)sampleHTML{
    switch (self.formType) {
        case WPCommentFormTypeAuthor:
            return [NSString stringWithFormat:@"<label for=\"author\" id=\"%@\" class=\"%@\">Name <span class=\"required\">*</span></label>", self.htmlID, self.cssClassStringForHTML];
        case WPCommentFormTypeEmail:
            return [NSString stringWithFormat:@"<label for=\"email\" id=\"%@\" class=\"%@\">Email <span class=\"required\">*</span></label>", self.htmlID, self.cssClassStringForHTML];
        case WPCommentFormTypeWebsite:
            return [NSString stringWithFormat:@"<label for=\"url\" id=\"%@\" class=\"%@\">Website <span class=\"required\">*</span></label>", self.htmlID, self.cssClassStringForHTML];
        case WPCommentFormTypeContent:
            return [NSString stringWithFormat:@"<label for=\"comment\" id=\"%@\" class=\"%@\">Comment</label>", self.htmlID, self.cssClassStringForHTML];
            
        default:
            break;
    }
}

- (NSString*)code{
    switch (self.formType) {
        case WPCommentFormTypeAuthor:
            return [NSString stringWithFormat:@"<label for=\"author\" class=\"%@\">Name <span class=\"required\">*</span></label>", self.cssClassStringForHTML];
        case WPCommentFormTypeEmail:
            return [NSString stringWithFormat:@"<label for=\"email\" class=\"%@\">Email <span class=\"required\">*</span></label>", self.cssClassStringForHTML];
        case WPCommentFormTypeWebsite:
            return [NSString stringWithFormat:@"<label for=\"url\"  class=\"%@\">Website <span class=\"required\">*</span></label>", self.cssClassStringForHTML];
        case WPCommentFormTypeContent:
            return [NSString stringWithFormat:@"<label for=\"comment\" class=\"%@\">Comment</label>", self.cssClassStringForHTML];
            
        default:
            break;
    }
}

- (BOOL)shouldCompileChildrenForOutput{
    return NO;
}


@end
