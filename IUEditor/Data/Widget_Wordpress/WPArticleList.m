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

+ (NSString *)widgetType{
    return kIUWidgetTypeWordpress;
}


#pragma mark - initialize

- (id)initWithPreset{
    self = [super initWithPreset];
    if(self){
        [self.undoManager disableUndoRegistration];

        self.defaultStyleStorage.width = @(680);
        self.defaultStyleStorage.height = nil;

        WPArticle *article = [[WPArticle alloc] initWithPreset];
        [self addIU:article error:nil];
        
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

- (NSString*)code{
    return @"<? while ( have_posts() ) : the_post(); ?>";
}

- (NSString*)codeAfterChildren{
    return @"<? endwhile ?>";
}

@end
