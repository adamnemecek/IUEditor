//
//  WPCommentFormCell.m
//  IUEditor
//
//  Created by jd on 9/16/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "WPCommentFormCell.h"

@implementation WPCommentFormCell

- (WPCommentForm*)parent{
    return (WPCommentForm*)[super parent];
}


- (NSString*)sampleHTML{
    if (_cellType == WPCommentFormCellTypeField) {
        switch (self.formType) {
            case WPCommentFormTypeAuthor:
                return [NSString stringWithFormat:@"<input id=\"%@\" name=\"author\" class=\"%@\" type=\"text\" value=\"\" size=\"30\" aria-required=\"true\" />", self.htmlID, self.cssClassStringForHTML];
                break;
            case WPCommentFormTypeEmail:
                return [NSString stringWithFormat:@"<input id=\"%@\" name=\"email\" class=\"%@\" type=\"text\" value=\"\" size=\"30\" aria-required=\"true\" />", self.htmlID, self.cssClassStringForHTML];
                break;
            case WPCommentFormTypeWebsite:
                return [NSString stringWithFormat:@"<input id=\"%@\" name=\"url\" class=\"%@\" type=\"text\" value=\"\" size=\"30\" aria-required=\"true\" />", self.htmlID, self.cssClassStringForHTML];
                break;
            case WPCommentFormTypeContent:
                return [NSString stringWithFormat:@"<input id=\"%@\" name=\"comment\" class=\"%@\" type=\"text\" value=\"\" size=\"30\" aria-required=\"true\" />", self.htmlID, self.cssClassStringForHTML];
                break;
            default:
                break;
        }
    }
    else if (_cellType == WPCommentFormCellTypeTextArea){
        switch (self.formType) {
            case WPCommentFormTypeAuthor:
                return [NSString stringWithFormat:@"<textarea id=\"%@\" name=\"author\" class=\"%@\" cols=\"45\" rows=\"8\"  aria-required=\"true\" />", self.htmlID, self.cssClassStringForHTML];
                break;
            case WPCommentFormTypeEmail:
                return [NSString stringWithFormat:@"<textarea id=\"%@\" name=\"email\" class=\"%@\"  cols=\"45\" rows=\"8\" aria-required=\"true\" />", self.htmlID, self.cssClassStringForHTML];
                break;
            case WPCommentFormTypeWebsite:
                return [NSString stringWithFormat:@"<textarea id=\"%@\" name=\"url\" class=\"%@\"  cols=\"45\" rows=\"8\" aria-required=\"true\" />", self.htmlID, self.cssClassStringForHTML];
                break;
            case WPCommentFormTypeContent:
                return [NSString stringWithFormat:@"<textarea id=\"%@\" name=\"comment\" class=\"%@\"  cols=\"45\" rows=\"8\" aria-required=\"true\" ></textarea>", self.htmlID, self.cssClassStringForHTML];
                break;
            default:
                break;
        }
    }
    return nil;
}

- (NSString*)code{
    return self.sampleHTML;
}

- (BOOL)shouldCompileFontInfo{
    return YES;
}

- (BOOL)shouldCompileChildrenForOutput{
    return YES;
}

@end
