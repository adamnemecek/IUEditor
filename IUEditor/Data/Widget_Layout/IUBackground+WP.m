//
//  IUBackground+WP.m
//  IUEditor
//
//  Created by jd on 8/10/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUBackground+WP.h"
#import "WPSiteTitle.h"
#import "WPMenu.h"
#import "WPSiteDescription.h"
#import "IUProject.h"

@implementation IUBackground (WP)

- (void)WPInitialize{
    for (IUBox *box in self.header.children) {
        [self.header removeIU:box];
    }
    WPSiteTitle *title = [[WPSiteTitle alloc] initWithProject:self.project options:nil];
    title.htmlID = @"SiteTitle";
    title.name = @"SiteTitle";
    [title.css setValue:@(60) forTag:IUCSSTagPixelY forViewport:IUCSSDefaultViewPort];
    title.enableHCenter = YES;

    [self.header addIU:title error:nil];
    [self.project.identifierManager registerIUs:@[title]];
    
    WPSiteDescription *desc = [[WPSiteDescription alloc] initWithProject:self.project options:nil];
    desc.htmlID = @"SiteDescription";
    desc.name = @"SiteDescription";
    [desc.css setValue:@(110) forTag:IUCSSTagPixelY forViewport:IUCSSDefaultViewPort];
    [self.header addIU:desc error:nil];
    [self.project.identifierManager registerIUs:@[desc]];

    WPMenu *menu = [[WPMenu alloc] initWithProject:self.project options:nil];
    menu.htmlID = @"Menu";
    menu.name = @"Menu";
    [self.header addIU:menu error:nil];
    [self.project.identifierManager registerIUs:@[menu]];
    
    [self.header.css setValue:@(200) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];
    
    [self.header.css eradicateTag:IUCSSTagBGColor];
}

@end
