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

- (id)initWithProject:(IUProject *)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    
    self.positionType = IUPositionTypeRelative;
    
    [self.css setValue:@(0) forTag:IUCSSTagPixelX forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(YES) forTag:IUCSSTagWidthUnitIsPercent forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(100) forTag:IUCSSTagPercentWidth forViewport:IUCSSDefaultViewPort];
    

    [self.css eradicateTag:IUCSSTagBGColor];

    WPCommentFormLabel *label = [[WPCommentFormLabel alloc] initWithProject:project options:nil];
    [label.css setValue:@(5) forTag:IUCSSTagPixelX];
    [label.css setValue:@(5) forTag:IUCSSTagPixelY];
    [label.css setValue:@(100) forTag:IUCSSTagPixelWidth];
    [label.css setValue:@(20) forTag:IUCSSTagPixelHeight];
    [self addIU:label error:nil];
    label.name = @"Label";

    WPCommentFormCell *cell = [[WPCommentFormCell alloc] initWithProject:project options:nil];
    [cell.css setValue:@(120) forTag:IUCSSTagPixelX];
    [cell.css setValue:@(5) forTag:IUCSSTagPixelY];
    [cell.css setValue:@(200) forTag:IUCSSTagPixelWidth];
    [cell.css setValue:@(20) forTag:IUCSSTagPixelHeight];
    [self addIU:cell error:nil];
    cell.name = @"Cell";
    
    if ([options[@"formType"] isEqualToString:@"content"]) {
        self.formType = WPCommentFormTypeContent;
        [self.css setValue:@(30) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];
    }
    else {
        [self.css setValue:@(30) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    [aDecoder decodeToObject:self withProperties:[WPCommentForm properties]];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
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

- (BOOL)shouldCompileFontInfo{
    return YES;
}

- (BOOL)shouldCompileChildrenForOutput{
    return NO;
}


@end