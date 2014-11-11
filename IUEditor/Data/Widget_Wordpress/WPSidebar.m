//
//  WPSidebar.m
//  IUEditor
//
//  Created by jd on 8/14/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "WPSidebar.h"
#import "WPWidget.h"
#import "IUProject.h"

@implementation WPSidebar

- (id)initWithProject:(id <IUProjectProtocol>)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    [self.undoManager disableUndoRegistration];
    
    _wordpressName = @"IUWidgets";
//    self.widgetCount = 1;
    
    //setting for css
    [self.css setValue:@(180) forTag:IUCSSTagPixelWidth forViewport:IUCSSDefaultViewPort];
    [self.css eradicateTag:IUCSSTagPixelHeight];
    [self.css eradicateTag:IUCSSTagBGColor];
    
    //default widget
    WPWidget *widget = [[WPWidget alloc] initWithProject:project options:options];
    [self addIU:widget error:nil];
    
    
    [self.undoManager enableUndoRegistration];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    [self.undoManager disableUndoRegistration];
    [aDecoder decodeToObject:self withProperties:[WPSidebar properties]];
    [self.undoManager enableUndoRegistration];
    return self;
}

- (id)copyWithZone:(NSZone *)zone{
    WPSidebar *sidebar = [super copyWithZone:zone];
    sidebar.wordpressName = _wordpressName;
    return sidebar;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[WPSidebar properties]];
}

- (void)setWordpressName:(NSString *)wordpressName{
    if ([wordpressName length] == 0) {
        _wordpressName = @"IUWidgets";
        return;
    }
    _wordpressName = wordpressName;
}

- (NSString*)code{
    return [NSString stringWithFormat:@"<?php dynamic_sidebar( '%@' ); ?>", self.wordpressName];
}

/*
 - (void)setWidgetCount:(NSInteger)widgetCount{
    _widgetCount = widgetCount;
    [self updateHTML];
}
*/

- (BOOL)shouldCompileFontInfo{
    return NO;
}

- (NSString*)sampleInnerHTML{
    NSMutableString *retInnerHTML = [NSMutableString string];
    for (WPWidget *widget in self.children) {
        if([widget isKindOfClass:[WPWidget class]]){
            [retInnerHTML appendString:widget.sampleHTML];
        }
        else{
            NSString *string =  [self.project.compiler htmlCode:self target:IUTargetEditor].string;
            [retInnerHTML appendString:string];
        }
    }
    return retInnerHTML;
}

@end
