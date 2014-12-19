//
//  WPCommentForm.m
//  IUEditor
//
//  Created by jd on 9/3/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "WPCommentForm.h"
#import "WPCommentFormLabel.h"
#import "WPCommentFormCell.h"

@implementation WPCommentForm {
}

- (id)initWithPreset{
    self = [super initWithPreset];
    if(self){
        
        self.defaultPositionStorage.firstPosition = @(IUFirstPositionTypeRelative);
        self.defaultPositionStorage.x = nil;
        
        [self.defaultStyleStorage setWidth:@(100) unit:@(IUFrameUnitPercent)];
        
        //label allocation
        WPCommentFormLabel *label = [[WPCommentFormLabel alloc] initWithPreset];
        label.defaultPositionStorage.x = @(5);
        label.defaultPositionStorage.y = @(5);
        
        label.defaultStyleStorage.width = @(100);
        label.defaultStyleStorage.height = @(20);
        
        [self addIU:label error:nil];
        label.name = @"Label";
        
        //cell allocation
        WPCommentFormCell *cell = [[WPCommentFormCell alloc] initWithPreset];
        cell.defaultPositionStorage.x = @(120);
        cell.defaultPositionStorage.y = @(5);
        cell.defaultStyleStorage.width = @(200);
        cell.defaultStyleStorage.height = @(20);
        
        [self addIU:cell error:nil];
        cell.name = @"Cell";
        
        /*
         FIXME : option사용중이 었음
        if ([options[@"formType"] isEqualToString:@"content"]) {
            self.formType = WPCommentFormTypeContent;
            [self.css setValue:@(30) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];
        }
        else {
            [self.css setValue:@(30) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];
        }
         */
    }

    return self;
}

- (id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [super initWithJDCoder:aDecoder];
    [aDecoder decodeToObject:self withProperties:[WPCommentForm properties]];
    return self;
}

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [super encodeWithJDCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[WPCommentForm properties]];
}


- (void)setFormType:(WPCommentFormType)formType{
    if (formType != WPCommentFormTypeContent && _formType == WPCommentFormTypeContent) {
        self.cell.cellType = WPCommentFormCellTypeField;
    }
    else if (formType == WPCommentFormTypeContent && _formType != WPCommentFormTypeContent) {
        self.cell.cellType = WPCommentFormCellTypeTextArea;
    }
    _formType = formType;
    [self label].formType = formType;
    [self cell].formType = formType;
}

- (WPCommentFormLabel*)label{
    return [self.children objectAtIndex:0];
}

- (WPCommentFormCell*)cell{
    return [self.children objectAtIndex:1];
}

- (NSString*)wpCommentFormClass{
    switch (self.formType) {
        case WPCommentFormTypeAuthor:{
            return @"comment-form-author";
        }
        case WPCommentFormTypeEmail:{
            return @"comment-form-email";
        }
        case WPCommentFormTypeWebsite:{
            return @"comment-form-url";
        }
        default:
        case WPCommentFormTypeContent:{
            return @"comment-form-comment";
        }
    }
}

- (NSString*)sampleHTML{
    return [NSString stringWithFormat:@"<p class='%@ %@' id='%@'>%@%@</p>",self.wpCommentFormClass, self.cssClassStringForHTML, self.htmlID, self.label.sampleHTML, self.cell.sampleHTML];
}

- (NSString*)code{
    switch (self.formType) {
        case WPCommentFormTypeAuthor:{
            return [NSString stringWithFormat:@"<p class=\"comment-form-author %@\">%@ %@</p>", self.cssClassStringForHTML, self.label.code, self.cell.code];
        }
        case WPCommentFormTypeEmail:{
            return [NSString stringWithFormat: @"<p class=\"comment-form-email %@\">%@ %@</p>", self.cssClassStringForHTML, self.label.code, self.cell.code];
        }
        case WPCommentFormTypeWebsite:{
            return [NSString stringWithFormat: @"<p class=\"comment-form-url %@\">%@ %@</p>", self.cssClassStringForHTML, self.label.code, self.cell.code ];
        }
        case WPCommentFormTypeContent:{
            return [NSString stringWithFormat: @"<p class=\"comment-form-comment %@\">%@ %@</p>", self.cssClassStringForHTML, self.label.code, self.cell.code];
        }

        default:{
            assert(0);
        }
    }
    return nil;
}

- (BOOL)shouldCompileChildrenForOutput{
    return NO;
}


@end