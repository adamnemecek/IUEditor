//
//  BBDefaultPropertyVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 8..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBDefaultPropertyVC.h"

@interface BBDefaultPropertyVC ()

@end

@implementation BBDefaultPropertyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IUResourceRootItem *)resourceRootItem{
    return [[[[NSApp mainWindow] windowController] document] performSelector:@selector(resourceRootItem)];
}

#pragma mark - binding

- (void)outlet:(id)outlet bind:(NSString *)binding liveStyleStorageProperty:(NSString *)property{
    [self outlet:outlet bind:binding liveStyleStorageProperty:property options:IUBindingDictNotRaisesApplicableAndContinuousUpdate];
    
}
- (void)outlet:(id)outlet bind:(NSString *)binding livePositionStorageProperty:(NSString *)property{
    [self outlet:outlet bind:binding livePositionStorageProperty:property options:IUBindingDictNotRaisesApplicableAndContinuousUpdate];
}
- (void)outlet:(id)outlet bind:(NSString *)binding livePropertyStorageProperty:(NSString *)property{
     [self outlet:outlet bind:binding livePropertyStorageProperty:property options:IUBindingDictNotRaisesApplicableAndContinuousUpdate];
}
- (void)outlet:(id)outlet bind:(NSString *)binding property:(NSString *)property{
    [self outlet:outlet bind:binding property:property options:IUBindingDictNotRaisesApplicableAndContinuousUpdate];
}


- (void)outlet:(id)outlet bind:(NSString *)binding liveStyleStorageProperty:(NSString *)property options:(NSDictionary *)options{
    [outlet bind:binding toObject:self withKeyPath:[self pathForLiveStyleStorageProperty:property] options:options];
    
}
- (void)outlet:(id)outlet bind:(NSString *)binding livePositionStorageProperty:(NSString *)property options:(NSDictionary *)options{
    [outlet bind:binding toObject:self withKeyPath:[self pathForLivePositionStorageProperty:property] options:options];
}
- (void)outlet:(id)outlet bind:(NSString *)binding livePropertyStorageProperty:(NSString *)property options:(NSDictionary *)options{
     [outlet bind:binding toObject:self withKeyPath:[self pathForLivePropertyStorageProperty:property] options:options];
}
- (void)outlet:(id)outlet bind:(NSString *)binding property:(NSString *)property options:(NSDictionary *)options{
    [outlet bind:binding toObject:self withKeyPath:[self pathForProperty:property] options:options];
}

#pragma mark - keyPath

- (NSString *)pathForLiveStyleStorageProperty:(NSString *)property{
    return [@"self.controller.selection.liveStyleStorage." stringByAppendingString:property];
}
- (NSString *)pathForLivePositionStorageProperty:(NSString *)property{
    return [@"self.controller.selection.livePositionStorage." stringByAppendingString:property];
}
- (NSString *)pathForLivePropertyStorageProperty:(NSString *)property{
    return [@"self.controller.selection.livePropertyStorage." stringByAppendingString:property];
}
- (NSString *)pathForProperty:(NSString *)property{
    return [@"self.controller.selection." stringByAppendingString:property];
}

#pragma mark - storage
- (IUStyleStorage *)liveStyleStorage{
    return [self valueForKeyPath:@"self.controller.selection.liveStyleStorage"];
}
- (IUPositionStorage *)livePositionStorage{
    return [self valueForKeyPath:@"self.controller.selection.livePositionStorage"];
}
- (IUPropertyStorage *)livePropertyStorage{
     return [self valueForKeyPath:@"self.controller.selection.livePropertyStorage"];
}



@end
