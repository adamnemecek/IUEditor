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

- (id)initWithPreset{
    self = [super initWithPreset];
    if(self){
        
        //css
        self.defaultPositionStorage.firstPosition = @(IUFirstPositionTypeRelative);
        self.defaultPositionStorage.x = nil;
        self.defaultPositionStorage.y = @(40);
        
        [self.defaultStyleStorage setWidth:@(100) unit:@(IUFrameUnitPercent)];
        self.defaultStyleStorage.height = nil;
        
        
        //alloc children
        WPCommentFormField *leaveAReplay = [[WPCommentFormField alloc] initWithPreset];
        leaveAReplay.fieldType = WPCommentFormFieldLeaveAReply;
        [self addIU:leaveAReplay error:nil];
        leaveAReplay.name = @"Leave a reply";
        
        WPCommentFormField *commentBefore = [[WPCommentFormField alloc] initWithPreset];
        commentBefore.fieldType = WPCommentFormFieldCommentBefore;
        [self addIU:commentBefore error:nil];
        commentBefore.name = @"Comment before";
        
        
        WPCommentForm *authorForm = [[WPCommentForm alloc] initWithPreset];
        authorForm.formType = WPCommentFormTypeAuthor;
        [self addIU:authorForm error:nil];
        authorForm.name = @"Author form";
        
        WPCommentForm *siteForm = [[WPCommentForm alloc] initWithPreset];
        siteForm.formType = WPCommentFormTypeWebsite;
        [self addIU:siteForm error:nil];
        siteForm.name = @"Site form";
        
        WPCommentForm *emailForm = [[WPCommentForm alloc] initWithPreset];
        emailForm.formType = WPCommentFormTypeEmail;
        [self addIU:emailForm error:nil];
        emailForm.name = @"Email form";
        
        /* FIXME : option
         WPCommentForm *content = [[WPCommentForm alloc] initWithProject:project options:@{@"formType": @"content"}];
         */
        WPCommentForm *content = [[WPCommentForm alloc] initWithPreset];
        content.formType = WPCommentFormTypeContent;
        [self addIU:content error:nil];
        content.name = @"Content form";
        
        WPCommentFormField *commentAfter = [[WPCommentFormField alloc] initWithPreset];
        commentAfter.fieldType = WPCommentFormFieldCommentAfter;
        [self addIU:commentAfter error:nil];
        commentAfter.name = @"Comment after";
        
        WPCommentFormSubmitBtn *submitBtn = [[WPCommentFormSubmitBtn alloc] initWithPreset];
        submitBtn.label = @"Comment";
        submitBtn.name = @"Submit";
        [self addIU:submitBtn error:nil];
    }

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
