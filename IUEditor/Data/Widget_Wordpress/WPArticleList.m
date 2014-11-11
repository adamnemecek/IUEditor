//
//  WPArticleList.m
//  IUEditor
//
//  Created by jd on 2014. 7. 16..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "WPArticleList.h"
#import "WPArticle.h"

/*
 code structure
 
 WP article list prefix code
       [wp article code]
 wp article list postfix code
 */

@implementation WPArticleList

#pragma mark - class attributes

+ (NSImage *)classImage{
    return [NSImage imageNamed:@"wp_articlelist"];
}

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"stack_wparticlelist"];
}

+ (IUWidgetType)widgetType{
    return IUWidgetTypeWP;
}


#pragma mark - initialize

- (id)initWithProject:(id <IUProjectProtocol>)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    [self.undoManager disableUndoRegistration];
    
    [self.css eradicateTag:IUCSSTagPixelHeight];
    [self.css eradicateTag:IUCSSTagBGColor];
    [self.css setValue:@(680) forTag:IUCSSTagPixelWidth];

    WPArticle *article = [[WPArticle alloc] initWithProject:project options:options];
    [self addIU:article error:nil];
    
    [self.undoManager enableUndoRegistration];
    return self;
}

- (NSString*)code{
    return @"<? while ( have_posts() ) : the_post(); ?>";
}

- (NSString*)codeAfterChildren{
    return @"<? endwhile ?>";
}

@end
