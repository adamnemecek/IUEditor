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



-(id)initWithProject:(IUProject*)project options:(NSDictionary*)options{
    self = [super initWithProject:project options:options];
    if(self){
        
        [[self undoManager] disableUndoRegistration];
        
        
        [self.css setValue:@(0) forTag:IUCSSTagPixelY forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(1) forTag:IUCSSTagHeightUnitIsPercent forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(100) forTag:IUCSSTagPercentHeight forViewport:IUCSSDefaultViewPort];
        
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
