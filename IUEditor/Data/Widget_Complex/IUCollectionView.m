//
//  IUCollectionView.m
//  IUEditor
//
//  Created by seungmi on 2014. 9. 11..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUCollectionView.h"

@implementation IUCollectionView

#pragma mark - class attributes

+ (NSImage *)classImage{
    return [NSImage imageNamed:@"tool_collection"];
}

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"stack_collection"];
}

+ (IUWidgetType)widgetType{
    return IUWidgetTypeSecondary;
}


#pragma mark - initialize

- (void)awakeAfterUsingJDCoder:(JDCoder *)aDecoder{
    [super awakeAfterUsingJDCoder:aDecoder];
    [self.undoManager disableUndoRegistration];
    
    _collection = [aDecoder decodeByRefObjectForKey:@"collection"];
    
    [self.undoManager enableUndoRegistration];
}

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [super encodeWithJDCoder:aCoder];
    [aCoder encodeByRefObject:_collection forKey:@"collection"];
}

- (id)copyWithZone:(NSZone *)zone{
    IUCollectionView *iu = [super copyWithZone:zone];
    [self.undoManager disableUndoRegistration];
    
    
    iu.collection = _collection;
    
    [self.undoManager enableUndoRegistration];
    return iu;
}

@end
