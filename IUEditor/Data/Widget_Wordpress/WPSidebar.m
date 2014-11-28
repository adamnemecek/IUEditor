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

#pragma mark - class attributes

+ (NSImage *)classImage{
    return [NSImage imageNamed:@"wp_sidebar"];
}

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"stack_wpsidebar"];
}

+ (IUWidgetType)widgetType{
    return IUWidgetTypeWP;
}


#pragma mark - initialize

- (id)initWithPreset{
    self = [super initWithPreset];
    if(self){
        [self.undoManager disableUndoRegistration];
        
        _wordpressName = @"IUWidgets";
        //    self.widgetCount = 1;

        //setting for css
        self.defaultStyleStorage.width = @(180);
        self.defaultStyleStorage.height = nil;
        self.defaultStyleStorage.bgColor = nil;
        

        //default widget
        WPWidget *widget = [[WPWidget alloc] initWithPreset];
        [self addIU:widget error:nil];
        
        
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    [aDecoder decodeToObject:self withProperties:[WPSidebar properties]];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[WPSidebar properties]];
}

- (id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [super initWithJDCoder:aDecoder];
    if(self){
        [self.undoManager disableUndoRegistration];
        [aDecoder decodeToObject:self withProperties:[WPSidebar properties]];
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [super encodeWithJDCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[WPSidebar properties]];
}

- (id)copyWithZone:(NSZone *)zone{
    WPSidebar *sidebar = [super copyWithZone:zone];
    sidebar.wordpressName = _wordpressName;
    return sidebar;
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

- (NSString*)sampleInnerHTML{
    NSMutableString *retInnerHTML = [NSMutableString string];
    for (WPWidget *widget in self.children) {
        if([widget isKindOfClass:[WPWidget class]]){
            [retInnerHTML appendString:widget.sampleHTML];
        }
        else{
            //FIXME:
            NSString *string =  [self.project.compiler htmlCode:self target:IUTargetEditor].string;
            [retInnerHTML appendString:string];
        }
    }
    return retInnerHTML;
}

@end
