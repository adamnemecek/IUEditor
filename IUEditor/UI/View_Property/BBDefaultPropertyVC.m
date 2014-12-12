//
//  BBDefaultPropertyVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 8..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBDefaultPropertyVC.h"
#import "IUDocumentProtocol.h"

@interface BBDefaultPropertyVC ()

@end

@implementation BBDefaultPropertyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

#pragma mark - binding

- (void)outlet:(id)outlet bind:(NSString *)binding cascadingStyleStorageProperty:(NSString *)property{
    [self outlet:outlet bind:binding cascadingStyleStorageProperty:property options:IUBindingDictNotRaisesApplicableAndContinuousUpdate];
    
}
- (void)outlet:(id)outlet bind:(NSString *)binding cascadingPositionStorageProperty:(NSString *)property{
    [self outlet:outlet bind:binding cascadingPositionStorageProperty:property options:IUBindingDictNotRaisesApplicableAndContinuousUpdate];
}
- (void)outlet:(id)outlet bind:(NSString *)binding cascadingPropertyStorageProperty:(NSString *)property{
     [self outlet:outlet bind:binding cascadingPropertyStorageProperty:property options:IUBindingDictNotRaisesApplicableAndContinuousUpdate];
}
- (void)outlet:(id)outlet bind:(NSString *)binding property:(NSString *)property{
    [self outlet:outlet bind:binding property:property options:IUBindingDictNotRaisesApplicableAndContinuousUpdate];
}


- (void)outlet:(id)outlet bind:(NSString *)binding cascadingStyleStorageProperty:(NSString *)property options:(NSDictionary *)options{
    [outlet bind:binding toObject:self withKeyPath:[self pathForCascadingStyleStorageProperty:property] options:options];
    
}
- (void)outlet:(id)outlet bind:(NSString *)binding cascadingPositionStorageProperty:(NSString *)property options:(NSDictionary *)options{
    [outlet bind:binding toObject:self withKeyPath:[self pathForCascadingPositionStorageProperty:property] options:options];
}
- (void)outlet:(id)outlet bind:(NSString *)binding cascadingPropertyStorageProperty:(NSString *)property options:(NSDictionary *)options{
     [outlet bind:binding toObject:self withKeyPath:[self pathForCascadingPropertyStorageProperty:property] options:options];
}
- (void)outlet:(id)outlet bind:(NSString *)binding property:(NSString *)property options:(NSDictionary *)options{
    [outlet bind:binding toObject:self withKeyPath:[self pathForProperty:property] options:options];
}

#pragma mark - keyPath

- (NSString *)pathForCascadingStyleStorageProperty:(NSString *)property{
    return [@"self.iuController.selection.cascadingStyleStorage." stringByAppendingString:property];
}
- (NSString *)pathForCascadingPositionStorageProperty:(NSString *)property{
    return [@"self.iuController.selection.cascadingPositionStorage." stringByAppendingString:property];
}
- (NSString *)pathForCascadingPropertyStorageProperty:(NSString *)property{
    return [@"self.iuController.selection.cascadingPropertyStorage." stringByAppendingString:property];
}
- (NSString *)pathForProperty:(NSString *)property{
    return [@"self.iuController.selection." stringByAppendingString:property];
}

#pragma mark - storage 

- (IUStyleStorage *)cascadingStyleStorage{
    return [self valueForKeyPath:@"self.iuController.selection.cascadingStyleStorage"];
}
- (IUPositionStorage *)cascadingPositionStorage{
    return [self valueForKeyPath:@"self.iuController.selection.cascadingPositionStorage"];
}
- (IUPropertyStorage *)cascadingPropertyStorage{
     return [self valueForKeyPath:@"self.iuController.selection.cascadingPropertyStorage"];
}



@end
