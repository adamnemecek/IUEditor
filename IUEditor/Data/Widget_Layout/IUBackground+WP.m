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
    WPSiteTitle *title = [[WPSiteTitle alloc] initWithPreset];
    title.htmlID = @"SiteTitle";
    title.name = @"SiteTitle";
    title.cascadingPositionStorage.y = @(60);
    title.enableHCenter = YES;

    [self.header addIU:title error:nil];
    
    WPSiteDescription *desc = [[WPSiteDescription alloc] initWithPreset];
    desc.htmlID = @"SiteDescription";
    desc.name = @"SiteDescription";
    desc.cascadingPositionStorage.y = @(110);
    
    [self.header addIU:desc error:nil];


    WPMenu *menu = [[WPMenu alloc] initWithPreset];
    menu.htmlID = @"Menu";
    menu.name = @"Menu";
    
    [self.header addIU:menu error:nil];
    
    self.header.cascadingStyleStorage.height = @(200);
    self.header.cascadingStyleStorage.bgColor1 = nil;

    
}

@end
