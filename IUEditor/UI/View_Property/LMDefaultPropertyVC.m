//
//  LMDefaultPropertyVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 8. 14..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMDefaultPropertyVC.h"

@interface LMDefaultPropertyVC ()

@end

@implementation LMDefaultPropertyVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib{
    
}
- (void)prepareDealloc{
    
}

- (void)setController:(IUController *)controller{
    _controller = controller;
    [_controller addObserver:self forKeyPath:@"selection" options:NSKeyValueObservingOptionNew context:nil];
}

- (IUResourceRootItem *)resourceRootItem{
    return [[[[NSApp mainWindow] windowController] document] performSelector:@selector(resourceRootItem)];
}

- (void)dealloc{
    if(_controller){
        [_controller removeObserver:self forKeyPath:@"selection"];
    }
}

#pragma mark - binding
- (void)outlet:(id)outlet bind:(NSString *)binding cssTag:(IUCSSTag)tag{
    [outlet bind:binding toObject:self withKeyPath:[self pathForCSSTag:tag] options:IUBindingDictNotRaisesApplicableAndContinuousUpdate];
}

- (void)outlet:(id)outlet bind:(NSString *)binding property:(IUPropertyTag)property{
    [outlet bind:binding toObject:self withKeyPath:[self pathForProperty:property] options:IUBindingDictNotRaisesApplicableAndContinuousUpdate];
}
- (void)outlet:(id)outlet bind:(NSString *)binding eventTag:(IUEventTag)tag{
    [outlet bind:binding toObject:self withKeyPath:[self pathForEventTag:tag] options:IUBindingDictNotRaisesApplicableAndContinuousUpdate];
}

- (void)outlet:(id)outlet bind:(NSString *)binding mqDataTag:(IUMQDataTag)tag{
    [outlet bind:binding toObject:self withKeyPath:[self pathForMqDataTag:tag] options:IUBindingDictNotRaisesApplicableAndContinuousUpdate];
}

- (void)outlet:(id)outlet bind:(NSString *)binding cssTag:(IUCSSTag)tag options:(NSDictionary *)options{
    [outlet bind:binding toObject:self withKeyPath:[self pathForCSSTag:tag] options:options];
}

- (void)outlet:(id)outlet bind:(NSString *)binding property:(IUPropertyTag)property options:(NSDictionary *)options{
    [outlet bind:binding toObject:self withKeyPath:[self pathForProperty:property] options:options];
}

- (void)outlet:(id)outlet bind:(NSString *)binding eventTag:(IUEventTag)tag options:(NSDictionary *)options{
    [outlet bind:binding toObject:self withKeyPath:[self pathForEventTag:tag] options:options];
}

- (void)outlet:(id)outlet bind:(NSString *)binding mqDataTag:(IUMQDataTag)tag options:(NSDictionary *)options{
    [outlet bind:binding toObject:self withKeyPath:[self pathForMqDataTag:tag] options:options];
}


#pragma mark - value
- (id)valueForCSSTag:(IUCSSTag)tag{
    return [self valueForKeyPath:[self pathForCSSTag:tag]];
}
- (id)valueForProperty:(IUPropertyTag)property{
     return [self valueForKeyPath:[self pathForProperty:property]];
}

- (void)setValue:(id)value forCSSTag:(IUCSSTag)tag{
    [self setValue:value forKeyPath:[self pathForCSSTag:tag]];
}

- (void)setValue:(id)value forIUProperty:(IUPropertyTag)property{
    [self setValue:value forKeyPath:[self pathForProperty:property]];
}

#pragma mark - observer

- (void)addObserverForCSSTag:(IUCSSTag)tag options:(NSKeyValueObservingOptions)options context:(void *)context{
    [self addObserver:self forKeyPath:[self pathForCSSTag:tag] options:options context:context];
}
- (void)addObserverForProperty:(IUPropertyTag)property options:(NSKeyValueObservingOptions)options context:(void *)context{
    [self addObserver:self forKeyPath:[self pathForProperty:property] options:options context:context];

}

- (void)removeObserverForCSSTag:(IUCSSTag)tag{
    [self removeObserver:self forKeyPath:[self pathForCSSTag:tag]];

}

- (void)removeObserverForProperty:(NSString *)property{
    [self removeObserver:self forKeyPath:[self pathForProperty:property]];
}

#pragma mark - keyPath
//REVIEW: self.selection not working (proxy multiple 전달 안됨)
- (NSString *)pathForCSSTag:(IUCSSTag)tag{
    return [@"controller.selection.css.effectiveTagDictionary." stringByAppendingString:tag];
}
- (NSString *)pathForProperty:(IUPropertyTag)property{
    return [@"controller.selection." stringByAppendingString:property];
}
- (NSString *)pathForEventTag:(IUEventTag)tag{
    return [@"controller.selection.event." stringByAppendingString:tag];
}
- (NSString *)pathForMqDataTag:(IUMQDataTag)tag{
    return [@"controller.selection.mqData." stringByAppendingString:tag];
}

@end
