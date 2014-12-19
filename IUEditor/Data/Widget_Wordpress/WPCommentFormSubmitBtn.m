//
//  WPCommentFormSubmitBtn.m
//  IUEditor
//
//  Created by jd on 9/24/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "WPCommentFormSubmitBtn.h"

@implementation WPCommentFormSubmitBtn

- (id)initWithPreset{
    self = [super initWithPreset];
    if(self){
        self.defaultPositionStorage.firstPosition = @(IUFirstPositionTypeRelative);
        
        self.defaultStyleStorage.height = nil;
    }

    return self;
}

- (id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [super initWithJDCoder:aDecoder];
    if(self){
        [self.undoManager disableUndoRegistration];
        [aDecoder decodeToObject:self withProperties:[WPCommentFormSubmitBtn properties]];
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [super encodeWithJDCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[WPCommentFormSubmitBtn properties]];
}

- (NSString*)sampleHTML{
    return [NSString stringWithFormat:@"<input name='submit' type='submit' id='%@' class='%@' value='%@' />", self.htmlID, self.cssClassStringForHTML , self.label];
}

- (NSString*)htmlID{
    return @"iu_wp_comment_submit";
}

- (NSString*)cssIdentifier{
    return @"#iu_wp_comment_submit";
}

@end