//
//  WPCommentFormCollection.m
//  IUEditor
//
//  Created by jd on 9/10/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "WPCommentFormCollection.h"
#import "WPCommentFormField.h"
#import "WPCommentForm.h"
#import "WPCommentFormSubmitBtn.h"

@implementation WPCommentFormCollection {
}

- (id)initWithProject:(IUProject *)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    
    //css
    self.positionType = IUPositionTypeRelative;
    
    [self.css setValue:@(0) forTag:IUCSSTagPixelX forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(40) forTag:IUCSSTagPixelY forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(YES) forTag:IUCSSTagWidthUnitIsPercent forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(100) forTag:IUCSSTagPercentWidth forViewport:IUCSSDefaultViewPort];
    [self.css eradicateTag:IUCSSTagPixelHeight];
    [self.css eradicateTag:IUCSSTagBGColor];

    
    WPCommentFormField *leaveAReplay = [[WPCommentFormField alloc] initWithProject:project options:nil];
    leaveAReplay.fieldType = WPCommentFormFieldLeaveAReply;
    [self addIU:leaveAReplay error:nil];
    leaveAReplay.name = @"Leave a reply";

    WPCommentFormField *commentBefore = [[WPCommentFormField alloc] initWithProject:project options:nil];
    commentBefore.fieldType = WPCommentFormFieldCommentBefore;
    [self addIU:commentBefore error:nil];
    commentBefore.name = @"Comment before";


    WPCommentForm *authorForm = [[WPCommentForm alloc] initWithProject:project options:nil];
    authorForm.formType = WPCommentFormTypeAuthor;
    [self addIU:authorForm error:nil];
    authorForm.name = @"Author form";

    WPCommentForm *siteForm = [[WPCommentForm alloc] initWithProject:project options:nil];
    siteForm.formType = WPCommentFormTypeWebsite;
    [self addIU:siteForm error:nil];
    siteForm.name = @"Site form";

    WPCommentForm *emailForm = [[WPCommentForm alloc] initWithProject:project options:nil];
    emailForm.formType = WPCommentFormTypeEmail;
    [self addIU:emailForm error:nil];
    emailForm.name = @"Email form";

    WPCommentForm *content = [[WPCommentForm alloc] initWithProject:project options:@{@"formType": @"content"}];
    content.formType = WPCommentFormTypeContent;
    [self addIU:content error:nil];
    content.name = @"Content form";
    
    WPCommentFormField *commentAfter = [[WPCommentFormField alloc] initWithProject:project options:nil];
    commentAfter.fieldType = WPCommentFormFieldCommentAfter;
    [self addIU:commentAfter error:nil];
    commentAfter.name = @"Comment after";
    
    WPCommentFormSubmitBtn *submitBtn = [[WPCommentFormSubmitBtn alloc] initWithProject:project options:nil];
    submitBtn.label = @"Comment";
    submitBtn.name = @"Submit";
    [self addIU:submitBtn error:nil];

    return self;
}

- (WPCommentForm *)formWithType:(WPCommentFormType)type{
    for (IUBox *box in self.children) {
        if ([box isKindOfClass:[WPCommentForm class]]) {
            if (((WPCommentForm*)box).formType == type){
                return (WPCommentForm *)box;
            }
        }
    }
    return nil;
}


- (WPCommentFormField *)formFieldWithType:(WPCommentFormFieldType)type{
    for (IUBox *box in self.children) {
        if ([box isKindOfClass:[WPCommentFormField class]]) {
            if (((WPCommentFormField*)box).fieldType == type){
                return (WPCommentFormField *)box;
            }
        }
    }
    return nil;
}

- (WPCommentFormSubmitBtn*)submitBtn{
    for (IUBox *box in self.children) {
        if ([box isKindOfClass:[WPCommentFormSubmitBtn class]]) {
            return (WPCommentFormSubmitBtn*)box;
        }
    }
    return nil;
}


- (NSString*)code{
    NSMutableString *str = [NSMutableString string];
    [str appendString:@"<?$args = array("];
    
    WPCommentFormField *commentBefore = [self formFieldWithType:WPCommentFormFieldCommentBefore];
    if (commentBefore) {
        [str appendFormat:@"'comment_notes_before' => \"%@\",\n", commentBefore.code];
    }
    
    
    WPCommentForm *content = [self formWithType:WPCommentFormTypeContent];
    if (content) {
        [str appendFormat:@"'comment_field' => '%@',\n", content.code];
    }
    
    WPCommentFormField *commentAfter = [self formFieldWithType:WPCommentFormFieldCommentAfter];
    if (commentAfter) {
        [str appendFormat:@"'comment_notes_after' => \"%@\",\n", commentAfter.code];
    }
    
    
    WPCommentFormSubmitBtn *submit = [self submitBtn];
    if (submit) {
        [str appendFormat:@"'label_submit' => '%@',\n", submit.label];
        [str appendFormat:@"'id_submit' => '%@',\n", submit.htmlID];
    }

    /* make field */
    [str appendString:@"'fields' => apply_filters( 'comment_form_default_fields', array("];
    
    WPCommentForm *author = [self formWithType:WPCommentFormTypeAuthor];
    if (author) {
        [str appendFormat:@"'author' => '%@',\n", author.code];
    }
    
    WPCommentForm *email = [self formWithType:WPCommentFormTypeEmail];
    if (author) {
        [str appendFormat:@"'email' => '%@',\n", email.code];
    }
    
    WPCommentForm *url = [self formWithType:WPCommentFormTypeWebsite];
    if (url) {
        [str appendFormat:@"'url' => '%@',\n", url.code];
    }
    

    [str appendString:@")),"];
    [str appendString:@");"];
    [str appendString:@"comment_form($args); ?>"];
    return str;
}

- (BOOL)shouldCompileChildrenForOutput{
    return NO;
}

@end
