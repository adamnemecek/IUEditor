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
- (id)initWithPreset{
    self = [super initWithPreset];
    if(self){
        [[self undoManager] disableUndoRegistration];
        
        self.defaultPositionStorage.y = @(0);
        [self.defaultStyleStorage setHeight:@(100) unit:@(IUFrameUnitPercent)];
        
        /*
         FIXME : mqSize를 가져와서 디폴트 값으로 세팅
         int i=0;
         for(NSNumber *width in project.mqSizes){
         NSInteger viewport = [width integerValue];
         if(i==0){
         [self.css setValue:width forTag:IUCSSTagPixelWidth forViewport:IUCSSDefaultViewPort];
         
         }
         else{
         [self.css setValue:width forTag:IUCSSTagPixelWidth forViewport:viewport];
         
         }
         i++;
         }
         */
        
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
