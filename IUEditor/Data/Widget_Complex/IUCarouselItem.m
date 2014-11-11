//
//  IUCarouselItem.m
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 4. 28..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUCarouselItem.h"

@implementation IUCarouselItem

- (id)initWithProject:(id <IUProjectProtocol>)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    if(self){
        [self.undoManager disableUndoRegistration];
        self.positionType = IUPositionTypeFloatLeft;
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

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

- (BOOL)canChangePositionType{
    return NO;
}

- (BOOL)canAddIUByUserInput{
    return YES;
}
-(BOOL)canRemoveIUByUserInput{
    return NO;
}

- (BOOL)canSelectedWhenOpenProject{
    return NO;
}
@end
