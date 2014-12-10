//
//  IUPageContent.m
//  IUEditor
//
//  Created by JD on 3/31/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUPageContent.h"
#import "IUSection.h"
#import "IUText.h"

@implementation IUPageContent

#pragma mark - class attributes

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"ic_contents"];
}

#pragma mark - Initialize
- (id)initWithPreset{
    self  = [super initWithPreset];
    if(self){
        [self.undoManager disableUndoRegistration];
        self.defaultStyleStorage.bgColor = [NSColor whiteColor];
        [self.defaultStyleStorage setWidth:@(100) unit:@(IUFrameUnitPercent)];
        
        IUSection *section = [[IUSection alloc] initWithPreset];
        section.defaultStyleStorage.bgColor = nil;
        section.defaultStyleStorage.height = @(720);
        
        [self addIU:section error:nil];
        
        IUText *titleBox = [[IUText alloc] initWithPreset];
        titleBox.defaultStyleStorage.width = @(240);
        titleBox.defaultStyleStorage.height = @(35);
        titleBox.defaultStyleStorage.fontSize = @(36);
        titleBox.defaultStyleStorage.fontAlign = @(IUAlignCenter);
        titleBox.defaultStyleStorage.fontColor = [NSColor rgbColorRed:179 green:179 blue:179 alpha:1];
        titleBox.defaultStyleStorage.bgColor = nil;
        titleBox.defaultStyleStorage.fontName = @"Helvetica";
        
        titleBox.defaultPositionStorage.y = @(285);
        titleBox.defaultPositionStorage.position = @(IUPositionTypeAbsolute);

        titleBox.livePropertyStorage.innerHTML = @"Content Area";
        
        titleBox.enableHCenter = YES;
                
        [section addIU:titleBox error:nil];
        
        
        IUText *contentBox = [[IUText alloc] initWithPreset];
        contentBox.defaultStyleStorage.width = @(420);
        contentBox.defaultStyleStorage.height = @(75);
        contentBox.defaultStyleStorage.fontSize = @(18);
        contentBox.defaultStyleStorage.fontAlign = @(IUAlignCenter);
        contentBox.defaultStyleStorage.fontColor = [NSColor rgbColorRed:179 green:179 blue:179 alpha:1];
        contentBox.defaultStyleStorage.bgColor = nil;
        contentBox.defaultStyleStorage.fontName = @"Helvetica";
        
        contentBox.defaultPositionStorage.y = @(335);
        contentBox.defaultPositionStorage.position = @(IUPositionTypeAbsolute);
        
        contentBox.defaultPropertyStorage.innerHTML = @"Double-click to edit text\n\nThis box has absolute-center position.\nFor free movement, see the position at the right.";
        
        contentBox.enableHCenter = YES;
        
        
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
