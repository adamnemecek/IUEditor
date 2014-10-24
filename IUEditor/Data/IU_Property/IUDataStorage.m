//
//  IUDataStorage.m
//  IUEditor
//
//  Created by jd on 10/20/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUDataStorage.h"
#import "NSString+IUTag.h"

@interface IUDataStorage()
- (void)setManager:(IUDataStorageManager *)manager;
- (IUDataStorageManager *)manager;

@property NSMutableDictionary *storage;
@property BOOL enableUpdate;
@end

@interface IUDataStorageManager()

@property NSMutableDictionary *storages; //key == viewPort(NSNumber) value=IUDataStorage.
@property NSArray * allViewPorts;
@property IUDataStorage *currentStorage;
@property IUDataStorage *defaultStorage;
@property IUDataStorage *liveStorage;
- (void)storage:(IUDataStorage*)storage updated:(NSString*)key;
@end



@implementation IUDataStorage {
    IUDataStorageManager *manager;
}

- (id)init{
    self = [super init];
    _storage = [NSMutableDictionary dictionary];
    _enableUpdate = YES;
    return self;
}

- (id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [super init];
    _storage = [aDecoder decodeObjectForKey:@"storage"];
    return self;
}

- (void)awakeAfterUsingJDCoder:(JDCoder *)aDecoder{
    manager = [aDecoder decodeByRefObjectForKey:@"manager"];
    _enableUpdate = YES;
}

- (IUDataStorageManager *)manager{
    return manager;
}

- (void)setManager:(IUDataStorageManager *)aManager{
    manager = aManager;
}

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [aCoder encodeObject:_storage forKey:@"storage"];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    [self willChangeValueForKey:key];
    [_storage setValue:value forKey:key];
    if (_enableUpdate){
        [manager storage:self updated:key];
    }
    [self didChangeValueForKey:key];
}

- (id)valueForUndefinedKey:(NSString *)key{
    return [_storage valueForKey:key];
}

- (NSDictionary*)dictionary{
    return [_storage copy];
}

- (IUDataStorage*)storageByOverwritingDataStorage:(IUDataStorage*)aStorage{
    IUDataStorage *returnValue = [[IUDataStorage alloc] init];
    returnValue.storage = [_storage mutableCopy];
    
    for (NSString *key in aStorage.storage) {
        returnValue.storage[key] = aStorage.storage[key];
    }
    
    return returnValue;
}

@end




@implementation IUDataStorageManager{
}

- (IUDataStorage *)newStorage{
    IUDataStorage *storage = [[IUDataStorage alloc] init];
    return storage;
}

- (id)init{
    self = [super init];

    _allViewPorts = [NSArray arrayWithObject:@(IUDefaultViewPort)];
    _storages = [NSMutableDictionary dictionary];
    _storages[@(IUDefaultViewPort)] = [self newStorage];
    _defaultStorage = _storages[@(IUDefaultViewPort)];
    _defaultStorage.manager = self;
    
    [self addObserver:self forKeyPath:@"currentViewPort" options:0 context:nil];
    self.currentViewPort = IUCSSDefaultViewPort;
    return self;
}

- (id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [super init];

    //storages
    _storages = [NSMutableDictionary dictionary];
    NSDictionary *savedStorage = [aDecoder decodeObjectForKey:@"storages"];
    [savedStorage enumerateKeysAndObjectsUsingBlock:^(NSString* key, id obj, BOOL *stop) {
        _storages[@([key integerValue])] = obj;
    }];
    return self;
}

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    NSMutableDictionary *saveStorage = [NSMutableDictionary dictionary];
    [_storages enumerateKeysAndObjectsUsingBlock:^(NSNumber* key, id obj, BOOL *stop) {
        saveStorage[[key stringValue]] = obj;
    }];
    [aCoder encodeObject:saveStorage forKey:@"storages"];
}

- (void)currentViewPortDidChange:(NSDictionary*)change{
    [self updateStorages];
}

- (void)updateStorages{
    //update
    if (_storages[@(_currentViewPort)] == nil) {
        IUDataStorage *newStorage = [self newStorage];
        newStorage.manager = self;
        _storages[@(_currentViewPort)] = newStorage;
    }
    
    self.currentStorage = _storages[@(_currentViewPort)];
    self.liveStorage = [self.defaultStorage storageByOverwritingDataStorage:self.currentStorage];
}

- (IUDataStorage*)storageForViewPort:(NSInteger)viewPort{
    return _storages[@(viewPort)];
}

- (void)removeStorageForViewPort:(NSInteger)viewPort{
    [_storages removeObjectForKey:@(viewPort)];
}


/**
 Manage new value of liveStorage = currentStroage
 */
- (void)storage:(IUDataStorage*)storage updated:(NSString*)key{
    if (storage == self.currentStorage) {
        [self.liveStorage setEnableUpdate:NO];
        [self.liveStorage setValue:self.currentStorage.storage[key] forKey:key];
        [self.liveStorage setEnableUpdate:YES];
    }
    else if (storage == self.liveStorage) {
        [self.currentStorage setEnableUpdate:NO];
        [self.currentStorage setValue:self.currentStorage.storage[key] forKey:key];
        [self.currentStorage setEnableUpdate:NO];
    }
    else {
        NSAssert(0, @"Cannot come to here");
    }
}

@end

@implementation IUCSSStorage {
    BOOL changing;
}

- (void)setBorderColor:(id)borderColor{
    if (changing == NO) {
        changing = YES;
    }
    else {
        return;
    }

    _borderColor = borderColor;


    [self setValue:borderColor forKey:IUCSSTagBorderTopColor];
    [self setValue:borderColor forKey:IUCSSTagBorderLeftColor];
    [self setValue:borderColor forKey:IUCSSTagBorderRightColor];
    [self setValue:borderColor forKey:IUCSSTagBorderBottomColor];
    
    changing = NO;
}


- (void)setValue:(id)value forKey:(IUCSSTag)key{
    [super setValue:value forKey:key];

    if (changing == NO && [key isBorderColorComponentTag]) {
        if ([self isAllBorderColorsEqual]) {
            if (_borderColor == value) {
                return;
            }
            [self willChangeValueForKey:@"borderColor"];
            _borderColor = value;
            [self didChangeValueForKey:@"borderColor"];
        }
        else {
            if (_borderColor == NSMultipleValuesMarker) {
                return;
            }
            [self willChangeValueForKey:@"borderColor"];
            _borderColor = NSMultipleValuesMarker;
            [self didChangeValueForKey:@"borderColor"];
        }
    }
}

- (BOOL)isAllBorderColorsEqual{
    if ([self valueForKey:IUCSSTagBorderTopColor] == [self valueForKey:IUCSSTagBorderBottomColor] &&
        [self valueForKey:IUCSSTagBorderTopColor] == [self valueForKey:IUCSSTagBorderLeftColor] &&
        [self valueForKey:IUCSSTagBorderTopColor] == [self valueForKey:IUCSSTagBorderRightColor] ) {
        return YES;
    }
    return NO;
}


@end

@implementation IUCSSStorageManager {
    NSMutableDictionary *defaultSelectorStorages;
    NSMutableDictionary *activeSelectorStorages;
    NSMutableDictionary *hoverSelectorStorages;
    
}

- (IUDataStorage *)newStorage{
    return [[IUCSSStorage alloc] init];
}

- (id)init{
    self = [super init];
    defaultSelectorStorages = self.storages;
    activeSelectorStorages = [NSMutableDictionary dictionary];
    hoverSelectorStorages = [NSMutableDictionary dictionary];
    return self;
}

- (void)setSelector:(IUCSSSelector)selector{
    _selector = selector;
    switch (selector) {
        case IUCSSSelectorDefault:
            self.storages = defaultSelectorStorages;
            break;
        case IUCSSSelectorActive:
            self.storages = activeSelectorStorages;
        case IUCSSSelectorHover:
        default:
            self.storages = hoverSelectorStorages;
            break;
    }
    [self updateStorages];
}

- (void)updateStorages{
    if ([self.storages objectForKey:@(IUDefaultViewPort)] == nil) {
        self.storages[@(IUDefaultViewPort)] = [self newStorage];
    }
    self.defaultStorage = [self.storages objectForKey:@(IUDefaultViewPort)];
    [super updateStorages];
}

- (IUCSSStorage*)storageForViewPort:(NSInteger)viewPort{
    return (IUCSSStorage*)[super storageForViewPort:viewPort];
}

@end

