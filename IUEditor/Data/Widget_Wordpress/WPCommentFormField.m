//
//  WPCommentFormField.m
//  IUEditor
//
//  Created by jd on 9/10/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "WPCommentFormField.h"

@implementation WPCommentFormField

- (id)initWithPreset{
    self = [super initWithPreset];
    if(self){
        
        self.defaultPositionStorage.firstPosition = @(IUFirstPositionTypeRelative);
        self.defaultPositionStorage.x = nil;
        
        [self.defaultStyleStorage setWidth:@(100) unit:@(IUFrameUnitPercent)];
        self.defaultStyleStorage.height = nil;
    }
    return self;
}

- (id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [super initWithJDCoder:aDecoder];
    if(self){
        [self.undoManager disableUndoRegistration];
        [aDecoder decodeToObject:self withProperties:[WPCommentFormField properties]];
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [super encodeWithJDCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[WPCommentFormField properties]];
}


- (void)setFieldType:(WPCommentFormFieldType)fieldType{
    _fieldType = fieldType;
    [self updateHTML];
}

- (NSString*)sampleHTML{
    switch (self.fieldType) {
        case WPCommentFormFieldLeaveAReply:
            return [NSString stringWithFormat:@"<div id='%@' class='comment-reply-title %@'>Leave a Reply <small><a rel='nofollow' id='cancel-comment-reply-link' href='/~jd/wordpress/?page_id=4#respond' style='display:none;'>Cancel reply</a></small></div>", self.htmlID, self.cssClassStringForHTML];
        case WPCommentFormFieldCommentBefore:
            return [NSString stringWithFormat: @"<p class='comment-notes %@' id = '%@'>Your email address will not be published. Required fields are marked <span class='required'>*</span></p>", self.cssClassStringForHTML, self.htmlID];
        case WPCommentFormFieldCommentAfter:
            return [NSString stringWithFormat: @"<p class='form-allowed-tags %@' id='%@'>You may use these <abbr title='HyperText Markup Language'>HTML</abbr> tags and attributes:  <code>&lt;a href=&quot;&quot; title=&quot;&quot;&gt; &lt;abbr title=&quot;&quot;&gt; &lt;acronym title=&quot;&quot;&gt; &lt;b&gt; &lt;blockquote cite=&quot;&quot;&gt; &lt;cite&gt; &lt;code&gt; &lt;del datetime=&quot;&quot;&gt; &lt;em&gt; &lt;i&gt; &lt;q cite=&quot;&quot;&gt; &lt;strike&gt; &lt;strong&gt; </code></p>", self.cssClassStringForHTML, self.htmlID];

        default:
            NSAssert(0, @"Wrong");
            return nil;
            break;
    }
}


- (NSString*)code{
    switch (self.fieldType) {
        case WPCommentFormFieldLeaveAReply:
            return [NSString stringWithFormat:@"<div class='comment-reply-title %@'>Leave a Reply <small><a rel='nofollow' id='cancel-comment-reply-link' href='/~jd/wordpress/?page_id=4#respond' style='display:none;'>Cancel reply</a></small></div>",  self.cssClassStringForHTML];
        case WPCommentFormFieldCommentBefore:
            return [NSString stringWithFormat: @"<p class='comment-notes %@'>Your email address will not be published. Required fields are marked <span class='required'>*</span></p>", self.cssClassStringForHTML];
        case WPCommentFormFieldCommentAfter:
            return [NSString stringWithFormat: @"<p class='form-allowed-tags %@'>You may use these <abbr title='HyperText Markup Language'>HTML</abbr> tags and attributes:  <code>&lt;a href=&quot;&quot; title=&quot;&quot;&gt; &lt;abbr title=&quot;&quot;&gt; &lt;acronym title=&quot;&quot;&gt; &lt;b&gt; &lt;blockquote cite=&quot;&quot;&gt; &lt;cite&gt; &lt;code&gt; &lt;del datetime=&quot;&quot;&gt; &lt;em&gt; &lt;i&gt; &lt;q cite=&quot;&quot;&gt; &lt;strike&gt; &lt;strong&gt; </code></p>", self.cssClassStringForHTML];
        default:
            NSAssert(0, @"Wrong");
            return nil;
            break;
    }
}


@end
