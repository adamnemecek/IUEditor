//
//  IUPageContent.m
//  IUEditor
//
//  Created by JD on 3/31/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUPageContent.h"
#import "IUSection.h"

@implementation IUPageContent

#pragma mark - class attributes

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"ic_contents"];
}

#pragma mark - Initialize


- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    //REVIEW: old file conversion - absolute포함되어있음
    self.positionType = IUPositionTypeRelative;

    return self;
}

- (id)initWithPreset{
    self  = [super initWithPreset];
    if(self){
        [self.undoManager disableUndoRegistration];
        self.liveStyleStorage.bgColor = [NSColor whiteColor];
        [self.liveStyleStorage setWidth:@(100) unit:@(IUFrameUnitPercent)];
        
        IUSection *section = [[IUSection alloc] initWithPreset];
        section.liveStyleStorage.bgColor = nil;
        section.liveStyleStorage.height = @(720);
        
        [self addIU:section error:nil];
        
        IUBox *titleBox = [[IUBox alloc] initWithPreset];
        titleBox.liveStyleStorage.width = @(240);
        titleBox.liveStyleStorage.height = @(35);
        titleBox.liveStyleStorage.fontSize = @(36);
        titleBox.liveStyleStorage.fontAlign = @(IUAlignCenter);
        titleBox.liveStyleStorage.fontColor = [NSColor rgbColorRed:179 green:179 blue:179 alpha:1];
        titleBox.liveStyleStorage.bgColor = nil;
        titleBox.liveStyleStorage.fontName = @"Helvetica";
        
        titleBox.livePositionStorage.y = @(285);
        titleBox.livePositionStorage.position = @(IUPositionTypeAbsolute);

        titleBox.livePropertyStorage.innerHTML = @"Content Area";
        
        titleBox.enableHCenter = YES;
        
        [section addIU:titleBox error:nil];
        
        
        IUBox *contentBox = [[IUBox alloc] initWithPreset];
        contentBox.liveStyleStorage.width = @(420);
        contentBox.liveStyleStorage.height = @(75);
        contentBox.liveStyleStorage.fontSize = @(18);
        contentBox.liveStyleStorage.fontAlign = @(IUAlignCenter);
        contentBox.liveStyleStorage.fontColor = [NSColor rgbColorRed:179 green:179 blue:179 alpha:1];
        contentBox.liveStyleStorage.bgColor = nil;
        contentBox.liveStyleStorage.fontName = @"Helvetica";
        
        contentBox.livePositionStorage.y = @(335);
        contentBox.livePositionStorage.position = @(IUPositionTypeAbsolute);
        
        contentBox.livePropertyStorage.innerHTML = @"Double-click to edit text\n\nThis box has absolute-center position.\nFor free movement, see the position at the right.";
        
        contentBox.enableHCenter = YES;
        
        [section addIU:contentBox error:nil];

        
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

- (id)initWithProject:(id <IUProjectProtocol>)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    if(self){
        
        [self.undoManager disableUndoRegistration];
        
        
        self.positionType = IUPositionTypeRelative;
        [self.css setValue:[NSColor whiteColor] forTag:IUCSSTagBGColor forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(YES) forTag:IUCSSTagWidthUnitIsPercent forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(100) forTag:IUCSSTagPercentWidth forViewport:IUCSSDefaultViewPort];
        
        
        
        IUSection *section = [[IUSection alloc] initWithProject:project options:options];
        [section.css setValue:nil forTag:IUCSSTagBGColor forViewport:IUCSSDefaultViewPort];
        [section.css setValue:@(720) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];

        [self addIU:section error:nil];
        
        IUBox *titleBox = [[IUBox alloc] initWithProject:project options:options];
        [titleBox.css setValue:@(240) forTag:IUCSSTagPixelWidth forViewport:IUCSSDefaultViewPort];
        [titleBox.css setValue:@(35) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];
        [titleBox.css setValue:@(285) forTag:IUCSSTagPixelY forViewport:IUCSSDefaultViewPort];
        [titleBox.css setValue:@(36) forTag:IUCSSTagFontSize forViewport:IUCSSDefaultViewPort];
        [titleBox.css setValue:@(IUAlignCenter) forTag:IUCSSTagTextAlign forViewport:IUCSSDefaultViewPort];
        [titleBox.css setValue:[NSColor rgbColorRed:179 green:179 blue:179 alpha:1] forTag:IUCSSTagFontColor forViewport:IUCSSDefaultViewPort];
        [titleBox.css setValue:nil forTag:IUCSSTagBGColor forViewport:IUCSSDefaultViewPort];
        [titleBox.css setValue:@"Helvetica" forTag:IUCSSTagFontName forViewport:IUCSSDefaultViewPort];

        titleBox.positionType = IUPositionTypeAbsolute;
        titleBox.enableHCenter = YES;
        [titleBox.mqData setValue:@"Content Area" forTag:IUMQDataTagInnerHTML forViewport:IUCSSDefaultViewPort];

        [section addIU:titleBox error:nil];
        
        IUBox *contentBox = [[IUBox alloc] initWithProject:project options:options];
        [contentBox.css setValue:@(420) forTag:IUCSSTagPixelWidth forViewport:IUCSSDefaultViewPort];
        [contentBox.css setValue:@(75) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];
        [contentBox.css setValue:@(335) forTag:IUCSSTagPixelY forViewport:IUCSSDefaultViewPort];
        [contentBox.css setValue:@(18) forTag:IUCSSTagFontSize forViewport:IUCSSDefaultViewPort];
        [contentBox.css setValue:@(IUAlignCenter) forTag:IUCSSTagTextAlign forViewport:IUCSSDefaultViewPort];
        [contentBox.css setValue:[NSColor rgbColorRed:179 green:179 blue:179 alpha:1] forTag:IUCSSTagFontColor forViewport:IUCSSDefaultViewPort];
        [contentBox.css setValue:nil forTag:IUCSSTagBGColor forViewport:IUCSSDefaultViewPort];
        [contentBox.css setValue:@"Helvetica" forTag:IUCSSTagFontName forViewport:IUCSSDefaultViewPort];
        
        contentBox.positionType = IUPositionTypeAbsolute;
        contentBox.enableHCenter = YES;
        [contentBox.mqData setValue:@"Double-click to edit text\n\nThis box has absolute-center position.\nFor free movement, see the position at the right." forTag:IUMQDataTagInnerHTML forViewport:IUCSSDefaultViewPort];
        
        [section addIU:contentBox error:nil];
        
        [self.undoManager enableUndoRegistration];
    }
    return self;
}
- (BOOL)hasMinHeight{
    for(IUBox *box in self.children){
        if([box isKindOfClass:[IUSection class]] == NO){
            return YES;
        }
    }
    
    return NO;
}


#pragma mark - should

-(BOOL)shouldCompileX{
    return NO;
}
-(BOOL)shouldCompileY{
    return NO;
}
-(BOOL)shouldCompileHeight{
    return NO;
}

-(BOOL)canRemoveIUByUserInput{
    return NO;
}

- (BOOL)canChangePositionType{
    return NO;
}

- (BOOL)canChangeOverflow{
    return NO;
}

- (BOOL)canChangeXByUserInput{
    return NO;
}
- (BOOL)canChangeYByUserInput{
    return NO;
}
- (BOOL)canChangeWidthByUserInput{
    return NO;
}

- (BOOL)canChangeHeightByUserInput{
    return NO;
}
- (BOOL)canCopy{
    return NO;
}

- (BOOL)canMoveToOtherParent{
    return NO;
}

@end
