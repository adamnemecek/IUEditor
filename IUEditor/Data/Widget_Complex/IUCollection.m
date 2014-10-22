//
//  IUCollection.m
//  IUEditor
//
//  Created by jd on 4/25/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUCollection.h"

@implementation IUCollection

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self.undoManager disableUndoRegistration];
        
        _collectionVariable = [aDecoder decodeObjectForKey:@"collectionVariable"];
        _responsiveSetting = [aDecoder decodeObjectForKey:@"responsiveSetting"];
        _responsiveSupport = [aDecoder decodeIntegerForKey:@"responsiveSupport"];
        _defaultItemCount = [aDecoder decodeIntegerForKey:@"defaultItemCount"];

        [self.undoManager enableUndoRegistration];
    
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_collectionVariable forKey:@"collectionVariable"];
    [aCoder encodeObject:_responsiveSetting forKey:@"responsiveSetting"];
    [aCoder encodeInteger:_responsiveSupport forKey:@"responsiveSupport"];
    [aCoder encodeInteger:_defaultItemCount forKey:@"defaultItemCount"];
}

- (id)initWithProject:(IUProject *)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    if(self){
        [self.undoManager disableUndoRegistration];
        
        self.defaultItemCount = 1;
        self.responsiveSetting = [NSArray array];
        
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone{
    IUCollection *iu = [super copyWithZone:zone];
    if(iu){
        [self.undoManager disableUndoRegistration];
        [self.delegate disableUpdateAll:self];
        
        iu.collectionVariable = [_collectionVariable copy];
        iu.responsiveSupport = _responsiveSupport;
        iu.responsiveSetting = [_responsiveSetting copy];
        iu.defaultItemCount = _defaultItemCount;
        
        
        [self.delegate enableUpdateAll:self];
        [self.undoManager enableUndoRegistration];
    }
    return iu;
}
#pragma mark - update

- (void)updateHTML{
    [super updateHTML];
    if(self.delegate){
        [self.delegate callWebScriptMethod:@"remakeCollection" withArguments:nil];
    }
}

#pragma mark - property

- (void)setResponsiveSupport:(BOOL)responsiveSupport{
    if(_responsiveSupport == responsiveSupport){
        return;
    }
    [[self.undoManager prepareWithInvocationTarget:self] setResponsiveSupport:_responsiveSupport];
    
    _responsiveSupport = responsiveSupport;
}

- (void)setDefaultItemCount:(NSInteger)defaultItemCount{
    if(_defaultItemCount == defaultItemCount){
        return;
    }
    [[self.undoManager prepareWithInvocationTarget:self] setDefaultItemCount:_defaultItemCount];
    _defaultItemCount = defaultItemCount;
    
    [self updateHTML];
}

- (void)setCollectionVariable:(NSString *)collectionVariable{
    if([_collectionVariable isEqualToString:collectionVariable]){
        return;
    }
    [[self.undoManager prepareWithInvocationTarget:self] setCollectionVariable:_collectionVariable];
    _collectionVariable = collectionVariable;
}

- (void)setResponsiveSetting:(NSArray *)responsiveSetting{
    [[self.undoManager prepareWithInvocationTarget:self] setResponsiveSetting:_responsiveSetting];
    _responsiveSetting = responsiveSetting;
    
    [self updateHTML];
}
@end
