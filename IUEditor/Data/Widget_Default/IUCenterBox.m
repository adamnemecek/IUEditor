//
//  IUCenterBox.m
//  IUEditor
//
//  Created by seungmi on 2014. 9. 4..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUCenterBox.h"
#import "IUProject.h"

@implementation IUCenterBox

#pragma mark - class attributes

+ (NSImage *)classImage{
    return [NSImage imageNamed:@"tool_centerbox"];
}

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"stack_centerbox"];
}

#pragma mark - init
- (id)initWithPresetWithViewports:(NSArray *)viewports{
    self = [super initWithPreset];
    if(self){
        [[self undoManager] disableUndoRegistration];
        
        self.defaultPositionStorage.y = @(0);
        [self.defaultStyleStorage setHeight:@(100) unit:@(IUFrameUnitPercent)];
        
        int i=0;
        for(NSNumber *width in viewports){
            NSInteger viewport = [width integerValue];
            if(i != 0){
                //default viewport는 만들지 않음.
                [self.defaultStyleManager createStorageForViewPort:viewport];
            }
            IUStyleStorage *styleStorage = (IUStyleStorage *)[self.defaultStyleManager storageForViewPort:viewport];
            [styleStorage setWidth:width unit:@(IUFrameUnitPixel)];
            
            i++;
        }
        
        
        self.enableHCenter = YES;
        
        [[self undoManager] enableUndoRegistration];
    }
    return self;
}


- (BOOL)canChangeXByUserInput{
    return NO;
}

- (BOOL)canChangeYByUserInput{
    return NO;
}

- (BOOL)canChangeHCenter{
    return NO;
}

- (BOOL)enableHCenter{
    //always YES
    return YES;
}
@end
