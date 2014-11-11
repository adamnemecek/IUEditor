//
//  WPCommentFormField.m
//  IUEditor
//
//  Created by jd on 9/10/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "WPCommentFormField.h"

@implementation WPCommentFormField

- (id)initWithProject:(id <IUProjectProtocol>)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    self.positionType = IUPositionTypeRelative;
    
    [self.css setValue:@(0) forTag:IUCSSTagPixelX forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(YES) forTag:IUCSSTagWidthUnitIsPercent forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(100) forTag:IUCSSTagPercentWidth forViewport:IUCSSDefaultViewPort];
    [self.css eradicateTag:IUCSSTagPixelHeight];
    [self.css eradicateTag:IUCSSTagBGColor];
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    [aDecoder decodeToObject:self withProperties:[WPCommentFormField properties]];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
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

- (BOOL)shouldCompileFontInfo{
    return YES;
}

@end
