//
//  IUPage+WP.m
//  IUEditor
//
//  Created by jd on 8/10/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUPage+WP.h"
#import "IUProject.h"
#import "IUSection.h"

#import "WPArticleList.h"
#import "WPPageLinks.h"
#import "WPSidebar.h"

#import "IUImage.h"
#import "IUCenterBox.h"
#import "IUText.h"

@implementation IUPage (WP)

-(void)WPInitializeAsHome{
    [self.undoManager disableUndoRegistration];
    [self.pageContent removeAllIU];
    
    //contents
    IUSection *section = [[IUSection alloc] initWithPreset];
    section.name = @"Contents";
    section.defaultStyleStorage.bgColor = nil;
    section.defaultStyleStorage.height = nil;
    [self.pageContent addIU:section error:nil];
    
    IUCenterBox *centerBox = [[IUCenterBox alloc] initWithPreset];
    centerBox.name = @"CenterBox";
    centerBox.enableHCenter = YES;
    centerBox.defaultPositionStorage.position = @(IUPositionTypeRelative);
    centerBox.defaultPositionStorage.y = @(0);
    
    centerBox.defaultStyleStorage.height = nil;
    centerBox.defaultStyleStorage.bgColor = nil;
    [section addIU:centerBox error:nil];

    WPSidebar *sidebar = [[WPSidebar alloc] initWithPreset];
    sidebar.defaultPositionStorage.position = @(IUPositionTypeFloatLeft);
    sidebar.defaultPositionStorage.y = @(40);
    [centerBox addIU:sidebar error:nil];
    
    WPArticleList *list = [[WPArticleList alloc] initWithPreset];
    list.defaultPositionStorage.position = @(IUPositionTypeRelative);
    sidebar.defaultPositionStorage.y = @(0);
    list.enableHCenter = YES;

    [centerBox addIU:list error:nil];
    
    WPPageLinks *links = [[WPPageLinks alloc] initWithPreset];
    links.defaultPositionStorage.y = @(60);

    [centerBox addIU:links error:nil];
    
    //footer
    IUSection *footer = [[IUSection alloc] initWithPreset];
    footer.name = @"Footer";
    footer.defaultStyleStorage.bgColor  = nil;
    footer.defaultStyleStorage.height = @(100);
    
    IUText *copyright = [IUText copyrightBox];
    
    [footer addIU:copyright error:nil];
    [self.pageContent addIU:footer error:nil];
    
    [self.undoManager enableUndoRegistration];
    [self.project.identifierManager addObjects:@[section, centerBox, sidebar, list, links, footer, copyright]];
}

-(void)WPInitializeAs404{
    [self.undoManager disableUndoRegistration];

    [self.pageContent removeAllIU];
    
    //contents
    IUSection *section = [[IUSection alloc] initWithPreset];
    section.name = @"Contents";
    section.defaultStyleStorage.bgColor = nil;
    section.defaultStyleStorage.height = @(400);
    [self.pageContent addIU:section error:nil];
    
    
    IUImage *image = [[IUImage alloc] initWithPreset];
    image.htmlID = @"image404";
    image.name = @"image404";
//    image.imagePath = @"clipArt/warning.png";
    image.enableHCenter = YES;
    
    image.defaultPositionStorage.y = @(110);
    image.defaultStyleStorage.width = @(140);
    image.defaultStyleStorage.height = @(140);
    image.defaultStyleStorage.bgColor = nil;
    
    
    [section addIU:image error:nil];
    
    IUText *text404 = [[IUText alloc] initWithPreset];
    text404.htmlID = @"text404";
    text404.name = @"text404";
    text404.defaultPropertyStorage.innerHTML= @"Sorry, but the page you are looking for has not been found.\nTry checking the URL for errors, then hit the refresh button.";

    //frame
    text404.enableHCenter = YES;
    text404.defaultPositionStorage.position = @(IUPositionTypeAbsolute);
    text404.defaultPositionStorage.y = @(270);

    
    [text404.defaultStyleStorage setWidth:@(75) unit:@(IUFrameUnitPercent)];
    text404.defaultStyleStorage.height = nil;
    text404.defaultStyleStorage.bgColor = nil;
    
    
    //font
    text404.defaultStyleStorage.fontName = @"Roboto";
    text404.defaultStyleStorage.fontSize = @(14);
    text404.defaultStyleStorage.fontLineHeight = @(2.0);
    text404.defaultStyleStorage.fontAlign = @(IUAlignCenter);

    [section addIU:text404 error:nil];
    
    //footer
    IUSection *footer = [[IUSection alloc] initWithPreset];
    footer.name = @"Footer";
    footer.defaultStyleStorage.bgColor = nil;
    footer.defaultStyleStorage.height = @(100);

    
    IUText *copyright = [IUText copyrightBox];

    [footer addIU:copyright error:nil];
    
    [self.pageContent addIU:footer error:nil];
    
    [self.undoManager enableUndoRegistration];
    [self.project.identifierManager addObjects:@[section, image, text404, footer, copyright]];
}

-(void)WPInitializeAsIndex{
    [self WPInitializeAsHome];
}

-(void)WPInitializeAsPage{
    [self WPInitializeAsHome];
}

-(void)WPInitializeAsCategory{
    [self WPInitializeAsHome];
}


@end
