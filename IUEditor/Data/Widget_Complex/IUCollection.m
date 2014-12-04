//
//  IUCollection.m
//  IUEditor
//
//  Created by jd on 4/25/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUCollection.h"

@implementation IUCollection

#pragma mark - class attributes

+ (NSImage *)classImage{
    return [NSImage imageNamed:@"tool_collection"];
}

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"stack_collection"];
}

+ (NSString *)widgetType{
    return kIUWidgetTypeSecondary;
}

#pragma mark - initialize

- (id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [super initWithJDCoder:aDecoder];
    if(self){
        [self.undoManager disableUndoRegistration];
        [aDecoder decodeToObject:self withProperties:[IUCollection properties]];
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [super encodeWithJDCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[IUCollection properties]];
}

- (id)initWithPreset{
    self = [super initWithPreset];
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
        
        iu.collectionVariable = [_collectionVariable copy];
        iu.responsiveSupport = _responsiveSupport;
        iu.responsiveSetting = [_responsiveSetting copy];
        iu.defaultItemCount = _defaultItemCount;
        
        [self.undoManager enableUndoRegistration];
    }
    return iu;
}
#pragma mark - update

- (void)updateHTML{
    [super updateHTML];
    if(self.sourceManager && self.isConnectedWithEditor){
        [self.sourceManager callWebScriptMethod:@"remakeCollection" withArguments:nil];
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
