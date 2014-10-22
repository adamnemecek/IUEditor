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

@implementation IUPage (WP)

-(void)WPInitializeAsHome{
    [self.undoManager disableUndoRegistration];
    [self.pageContent removeAllIU];
    
    //contents
    IUSection *section = [[IUSection alloc] initWithProject:self.project options:nil];
    section.name = @"Contents";
    [section.css eradicateTag:IUCSSTagBGColor];
    [section.css eradicateTag:IUCSSTagPixelHeight];
    [self.pageContent addIU:section error:nil];
    
    IUBox *centerBox = [[IUBox alloc] initWithProject:self.project options:nil];
    centerBox.name = @"CenterBox";
    centerBox.enableHCenter = YES;
    centerBox.positionType = IUPositionTypeRelative;
    [centerBox.css setValue:@(0) forTag:IUCSSTagPixelY forViewport:IUCSSDefaultViewPort];
    [centerBox.css setValue:@(960) forTag:IUCSSTagPixelWidth forViewport:IUCSSDefaultViewPort];
    [centerBox.css eradicateTag:IUCSSTagPixelHeight];
    [centerBox.css eradicateTag:IUCSSTagBGColor];
    [section addIU:centerBox error:nil];

    WPSidebar *sidebar = [[WPSidebar alloc] initWithProject:self.project options:nil];
    sidebar.positionType = IUPositionTypeFloatLeft;
    [sidebar.css setValue:@(40) forTag:IUCSSTagPixelX forViewport:IUCSSDefaultViewPort];
    [sidebar.css setValue:@(40) forTag:IUCSSTagPixelY forViewport:IUCSSDefaultViewPort];
    [centerBox addIU:sidebar error:nil];
    
    WPArticleList *list = [[WPArticleList alloc] initWithProject:self.project options:nil];
    [list.css setValue:@(-40) forTag:IUCSSTagPixelX forViewport:IUCSSDefaultViewPort];
    [list.css setValue:@(0) forTag:IUCSSTagPixelY forViewport:IUCSSDefaultViewPort];
    list.positionType = IUPositionTypeRelative;
    list.enableHCenter = YES;

    [centerBox addIU:list error:nil];
    
    WPPageLinks *links = [[WPPageLinks alloc] initWithProject:self.project options:nil];
    [links.css setValue:@(60) forTag:IUCSSTagPixelY forViewport:IUCSSDefaultViewPort];
    [centerBox addIU:links error:nil];
    
    //footer
    IUSection *footer = [[IUSection alloc] initWithProject:self.project options:nil];
    footer.name = @"Footer";
    [footer.css eradicateTag:IUCSSTagBGColor];
    [footer.css setValue:@(100) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];
    
    IUBox *copyright = [IUBox copyrightBoxWithProject:self.project];
    
    [footer addIU:copyright error:nil];
    [self.pageContent addIU:footer error:nil];
    
    [self.undoManager enableUndoRegistration];
    [self.project.identifierManager registerIUs:@[section, centerBox, sidebar, list, links, footer, copyright]];
}

-(void)WPInitializeAs404{
    [self.undoManager disableUndoRegistration];

    [self.pageContent removeAllIU];
    
    //contents
    IUSection *section = [[IUSection alloc] initWithProject:self.project options:nil];
    section.name = @"Contents";
    [section.css eradicateTag:IUCSSTagBGColor];
    [section.css setValue:@(400) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];
    [self.pageContent addIU:section error:nil];
    
    
    IUImage *image = [[IUImage alloc] initWithProject:self.project options:nil];
    image.htmlID = @"image404";
    image.name = @"image404";
    image.imageName = @"clipArt/warning.png";
    image.enableHCenter = YES;
    [image.css setValue:@(110) forTag:IUCSSTagPixelY forViewport:IUCSSDefaultViewPort];
    [image.css setValue:@(140) forTag:IUCSSTagPixelWidth forViewport:IUCSSDefaultViewPort];
    [image.css setValue:@(140) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];
    [image.css eradicateTag:IUCSSTagBGColor];
    
    [section addIU:image error:nil];
    
    IUBox *text404 = [[IUBox alloc] initWithProject:self.project options:nil];
    text404.htmlID = @"text404";
    text404.name = @"text404";
    [text404.mqData setValue:@"Sorry, but the page you are looking for has not been found.\nTry checking the URL for errors, then hit the refresh button." forTag:IUMQDataTagInnerHTML forViewport:IUCSSDefaultViewPort];

    //frame
    text404.enableHCenter = YES;
    [text404 setPositionType:IUPositionTypeAbsolute];
    
    [text404.css setValue:@(270) forTag:IUCSSTagPixelY forViewport:IUCSSDefaultViewPort];
    [text404.css setValue:@(YES) forTag:IUCSSTagWidthUnitIsPercent forViewport:IUCSSDefaultViewPort];
    [text404.css setValue:@(750) forTag:IUCSSTagPercentWidth forViewport:IUCSSDefaultViewPort];
    [text404.css eradicateTag:IUCSSTagPixelHeight];
    [text404.css eradicateTag:IUCSSTagBGColor];
    
    //font
    [text404.css setValue:@"Roboto" forTag:IUCSSTagFontName forViewport:IUCSSDefaultViewPort];
    [text404.css setValue:@(14) forTag:IUCSSTagFontSize forViewport:IUCSSDefaultViewPort];
    [text404.css setValue:@(2.0) forTag:IUCSSTagLineHeight forViewport:IUCSSDefaultViewPort];
    [text404.css setValue:@(IUAlignCenter) forTag:IUCSSTagTextAlign forViewport:IUCSSDefaultViewPort];

    [section addIU:text404 error:nil];
    
    //footer
    IUSection *footer = [[IUSection alloc] initWithProject:self.project options:nil];
    footer.name = @"Footer";
    [footer.css eradicateTag:IUCSSTagBGColor];
    [footer.css setValue:@(100) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];
    
    IUBox *copyright = [IUBox copyrightBoxWithProject:self.project];

    [footer addIU:copyright error:nil];
    
    [self.pageContent addIU:footer error:nil];
    
    [self.undoManager enableUndoRegistration];
    [self.project.identifierManager registerIUs:@[section, image, text404, footer, copyright]];
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
