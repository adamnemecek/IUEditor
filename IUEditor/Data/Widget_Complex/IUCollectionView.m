//
//  IUCollectionView.m
//  IUEditor
//
//  Created by seungmi on 2014. 9. 11..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUCollectionView.h"

@implementation IUCollectionView

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    [self.undoManager disableUndoRegistration];
    
    [aDecoder decodeToObject:self withProperties:[IUCollectionView properties]];

    
    [self.undoManager enableUndoRegistration];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeFromObject:self withProperties:[IUCollectionView properties]];
}

- (id)copyWithZone:(NSZone *)zone{
    IUCollectionView *iu = [super copyWithZone:zone];
    [self.undoManager disableUndoRegistration];
    [_canvasVC disableUpdateAll:self];
    
    
    iu.collection = _collection;
    
    [_canvasVC enableUpdateAll:self];
    [self.undoManager enableUndoRegistration];
    return iu;
}

@end
