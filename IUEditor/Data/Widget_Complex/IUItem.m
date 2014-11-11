//
//  IUItem.m
//  IUEditor
//
//  Created by jd on 4/15/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUItem.h"
#import "IUCarousel.h"
#import "IUTransition.h"

@implementation IUItem


#pragma mark - class attributes

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"stack_carousel_item"];
}

#pragma mark - should XXX

- (BOOL)shouldCompileX{
    return NO;
}

- (BOOL)shouldCompileY{
    return NO;
}
- (BOOL)shouldCompileWidth{
    return NO;
}
- (BOOL)shouldCompileHeight{
    return NO;
}

//자기 자신대신 parent를 옮기는 경우
- (BOOL)shouldMoveParent{
    return YES;
}
- (BOOL)shouldExtendParent{
    return YES;
}

- (BOOL)canChangePositionType{
    return NO;
}
- (BOOL)canRemoveIUByUserInput{
    return NO;
}
- (BOOL)canCopy{
    return NO;
}

- (BOOL)shouldSelectParentFirst{
    return YES;
}

- (BOOL)canMoveToOtherParent{
    return NO;
}

@end
