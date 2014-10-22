//
//  WPPageLink.m
//  IUEditor
//
//  Created by jw on 7/15/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "WPPageLinks.h"
#import "WPPageLink.h"

@implementation WPPageLinks

- (id)initWithProject:(IUProject *)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    [self.undoManager disableUndoRegistration];
    
    self.positionType = IUPositionTypeRelative;
    self.enableHCenter = YES;
    self.align = IUAlignRight;
    self.leftRightPadding = 5;
    
    [self.css setValue:@(900) forTag:IUCSSTagPixelWidth forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(100) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];
    [self.css eradicateTag:IUCSSTagBGColor];
    
    
    WPPageLink *pageLink = [[WPPageLink alloc] initWithProject:project options:options];
    [self addIU:pageLink error:nil];
    
    [self.undoManager enableUndoRegistration];
    return self;
}

- (NSString*)code{
    return @"<?php\n\
    global $wp_query;\n\
    $big = 999999999;\n\
    echo paginate_links( array(\n\
        'base' => str_replace( $big, '%%#%%', esc_url( get_pagenum_link( $big ) ) ),\n\
        'format' => '?paged=%%#%%',\n\
        'current' => max( 1, get_query_var('paged') ),\n\
        'total' => $wp_query->max_num_pages,\n\
        'type' => 'list',\n\
    ) );\n\
    ?>";
}
- (NSString*)sampleInnerHTML{
    if(self.children.count == 1){
        return ((WPPageLink *)self.children[0]).sampleInnerHTML;
    }
    else{
        return @"<ul class='page-numbers'>\
        <li class='WPPageLink'><span class='page-numbers current'>1</span></li>\
        <li class='WPPageLink'><a class= 'page-numbers' href='http://127.0.0.1/~jd/wordpress/?paged=2'>2</a></li>\
        <li class='WPPageLink'><a class='page-numbers' href='http://127.0.0.1/~jd/wordpress/?paged=3'>3</a></li>\
        <li class='WPPageLink'><a class='next page-numbers' href='http://127.0.0.1/~jd/wordpress/?paged=2'>Next &raquo;</a></li>\
        </ul>";
    }
}


#pragma mark - property

- (void)setAlign:(IUAlign)align{
    if(_align != align){
        
        [[self.undoManager prepareWithInvocationTarget:self] setAlign:_align];
        _align = align;
        [self updateCSS];
        
        for(WPPageLink *link in self.children){
            [link updateCSS];
        }
    }
}

- (void)setLeftRightPadding:(NSInteger)leftRightPadding{
    if(_leftRightPadding != leftRightPadding){
        [[self.undoManager prepareWithInvocationTarget:self] setLeftRightPadding:_leftRightPadding];
        _leftRightPadding = leftRightPadding;
        for(WPPageLink *link in self.children){
            [link updateCSS];
        }
    }
}

#pragma mark - css

- (NSArray *)cssIdentifierArray{
    return [[super cssIdentifierArray] arrayByAddingObjectsFromArray:@[self.containerIdentifier]];
}
- (NSString *)containerIdentifier{
    return [self.cssIdentifier stringByAppendingString:@" > ul"];
}

- (BOOL)shouldCompileChildrenForOutput{
    return NO;
}


@end
