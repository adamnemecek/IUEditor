//
//  WPCommentFormSubmitBtn.m
//  IUEditor
//
//  Created by jd on 9/24/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "WPCommentFormSubmitBtn.h"

@implementation WPCommentFormSubmitBtn

- (id)initWithProject:(IUProject *)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    self.positionType = IUPositionTypeRelative;
    
    [self.css eradicateTag:IUCSSTagPixelHeight];
    [self.css eradicateTag:IUCSSTagBGColor];

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    [aDecoder decodeToObject:self withProperties:[WPCommentFormSubmitBtn properties]];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
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

- (BOOL)shouldCompileFontInfo{
    return YES;
}

@end