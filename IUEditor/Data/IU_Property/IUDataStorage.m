//
//  IUDataStorage.m
//  IUEditor
//
//  Created by jd on 10/20/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUDataStorage.h"
#import "NSString+IUTag.h"
#import "JDMutableArrayDict.h"

@interface IUDataStorage()
- (void)setManager:(IUDataStorageManager *)manager;
- (IUDataStorageManager *)manager;

@property NSMutableDictionary *storage;
@property BOOL enableUpdate;
@end

@interface IUDataStorageManager()

@property JDMutableArrayDict *workingStorages; //key == viewPort(NSNumber) value=IUDataStorage.

@property IUDataStorage *currentStorage;
@property IUDataStorage *defaultStorage;
@property IUDataStorage *liveStorage;
- (void)storage:(IUDataStorage*)storage change:(NSDictionary*)change;
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

- (id)copyWithZone:(NSZone *)zone{
    IUDataStorage *returnObject = [[[self class] allocWithZone:zone] init];
    returnObject.manager = self.manager;
    returnObject.storage = [self.storage mutableCopy];
    return returnObject;
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
    id oldValue = [self valueForKey:key];
    if ([oldValue isEqualTo:value]) {
        /* if two object are equal, just return */
        return;
    }
    [_storage setValue:value forKey:key];
    
    if (_enableUpdate){
        if (oldValue && value) {
            [manager storage:self change:@{@"key":key, @"oldValue":oldValue, @"newValue":value}];
        }
        else if (oldValue) {
            [manager storage:self change:@{@"key":key, @"oldValue":oldValue,}];
        }
        else {
            [manager storage:self change:@{@"key":key, @"newValue":value,}];
        }
    }
    [self didChangeValueForKey:key];
}

- (id)valueForUndefinedKey:(NSString *)key{
    return [_storage valueForKey:key];
}

- (NSDictionary*)dictionary{
    return [_storage copy];
}

- (void)overwritingDataStorageForNilValue:(IUDataStorage*)aStorage{
    for (NSString *key in aStorage.storage) {
        if (self.storage[key] == nil) {
            self.storage[key] = aStorage.storage[key];
        }
    }
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

    self.workingStorages = [[JDMutableArrayDict alloc] init];
    IUDataStorage *defaultStorage = [self newStorage];
    defaultStorage.manager = self;
    
    [self.workingStorages insertObject:defaultStorage forKey:@(IUDefaultViewPort) atIndex:0];

    _defaultStorage = defaultStorage;
    _currentStorage = defaultStorage;
    
    [self addObserver:self forKeyPath:@"currentViewPort" options:0 context:nil];
    self.currentViewPort = IUCSSDefaultViewPort;
    return self;
}

- (void)dealloc{
    [self removeObserver:self forKeyPath:@"currentViewPort"];
}

- (id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [super init];
    self.workingStorages = [aDecoder decodeObjectForKey:@"storages"];
    
    [self addObserver:self forKeyPath:@"currentViewPort" options:0 context:nil];
    self.currentViewPort = IUCSSDefaultViewPort;
    return self;
}

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [aCoder encodeObject:self.workingStorages forKey:@"storages"];
}

- (void)currentViewPortDidChange:(NSDictionary*)change{
    if ([self.workingStorages objectForKey:@(_currentViewPort)] == nil) {
        IUDataStorage *newStorage = [self newStorage];
        newStorage.manager = self;
        [self.workingStorages setObject:newStorage forKey:@(_currentViewPort)];
        [self.workingStorages reverseSortArrayWithDictKey];
    }
    self.currentStorage = [self.workingStorages objectForKey:@(_currentViewPort)];
    self.liveStorage = [self createLiveStorage];
}

- (IUDataStorage*)createLiveStorage{
    /* does not send information to manager */
    IUDataStorage *liveStorage = [self.currentStorage copy];
    [liveStorage setEnableUpdate:NO];
    /*
     get overwrite all data
     */
    IUDataStorage *currStorage = self.currentStorage;
    while ( (currStorage = [self storageWithBiggerViewPortOf:currStorage]) ) {
        [liveStorage overwritingDataStorageForNilValue:currStorage];
    }
    [liveStorage setEnableUpdate:YES];
    return liveStorage;
}

- (IUDataStorage*)storageForViewPort:(NSInteger)viewPort{
    return [_workingStorages objectForKey:@(viewPort)];
}

- (NSInteger)viewPortOfStorage:(IUDataStorage*)storage{
    return [[self.workingStorages firstKeyForObject:storage] integerValue];
}


- (void)removeStorageForViewPort:(NSInteger)viewPort{
    [_workingStorages removeObjectForKey:@(viewPort)];
}

- (NSArray*)allViewPorts{
    return [self.workingStorages allKeys];
}

- (id)storageWithBiggerViewPortOf:(IUDataStorage*)storage{
    NSInteger viewPort = [self viewPortOfStorage:storage];
    for (NSNumber *number in [self.allViewPorts reversedArray]) {
        if ([number integerValue] > viewPort) {
            return [self storageForViewPort:[number integerValue]];
        }
    }
    return nil;
}




/**
 Manage new value of liveStorage = currentStroage
 */
- (void)storage:(IUDataStorage*)storage change:(NSDictionary *)change{
    NSString *key = change[@"key"];

//   there are "newValue" and "oldValue" in dictionary, but not using in here
//    id newValue = change[@"newValue"];
//    id oldValue = change[@"oldValue"];

    if (storage == self.currentStorage) {
        [self.liveStorage setEnableUpdate:NO];
        [self.liveStorage setValue:change[@"newValue"] forKey:key];
        [self.liveStorage setEnableUpdate:YES];
    }
    else if (storage == self.liveStorage) {
        [self.currentStorage setEnableUpdate:NO];
        [self.currentStorage setValue:change[@"newValue"] forKey:key];
        [self.currentStorage setEnableUpdate:NO];
    }
    else {
        NSAssert(0, @"Only current storage and live storage is updatable");
    }
}


- (id)liveValueForKey:(id)key forViewPort:(NSInteger)viewPort{
    IUDataStorage *storage = [self storageForViewPort:viewPort];
    
    while (1) {
        id value = [storage valueForKey:key];
        if (value) {
            return value;
        }
        storage = [self storageOfBiggerViewPortOfStorage:storage];
        if (storage == nil) {
            return nil;
        }
    }
}

- (IUDataStorage *)storageOfSmallerViewPortOfStorage:(IUDataStorage*)storage{
    NSInteger index = [self.workingStorages.array indexOfObject:storage];
    if (index == [self.workingStorages.array count]  - 1) {
        return nil;
    }
    return [self.workingStorages.array objectAtIndex:index+1];
}

- (IUDataStorage *)storageOfBiggerViewPortOfStorage:(IUDataStorage*)storage{
    NSInteger index = [self.workingStorages.array indexOfObject:storage];
    if (index == 0) {
        return nil;
    }
    return [self.workingStorages.array objectAtIndex:index-1];
}


@end

@implementation IUCSSStorage {
    BOOL changing;
}

/* using cache for multiple calling [IUCSSStorage properties] */
static NSArray *cssProperties_cache;

- (id)init{
    self = [super init];
    if (cssProperties_cache == nil) {
        NSArray *properties = [IUCSSStorage properties];
        cssProperties_cache = [properties valueForKey:@"name"];
    }
    [self addObserver:self forKeyPaths:cssProperties_cache options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:@"cssProperty"];
    return self;
}

- (void)dealloc{
    [self removeObserver:self forKeyPaths:cssProperties_cache];
}

- (void)setX:(id)x{
    _x = x;
}

- (void)cssPropertyContextDidChange:(NSDictionary*)change{
    
    if (self.enableUpdate) {
        NSMutableDictionary *changeDict = [NSMutableDictionary dictionary];
        if (change[NSKeyValueChangeOldKey] != [NSNull null]) {
            [changeDict setValue:change[NSKeyValueChangeOldKey] forKey:@"oldValue"];
        }
        if (change[NSKeyValueChangeNewKey] != [NSNull null]) {
            [changeDict setValue:change[NSKeyValueChangeNewKey] forKey:@"newValue"];
        }
        [changeDict setValue:change[kJDKey] forKey:@"key"];
        [self.manager storage:self change:changeDict];
    }
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

- (void)overwritingDataStorageForNilValue:(IUCSSStorage*)aStorage{
    [super overwritingDataStorageForNilValue:aStorage];
    /* remove update manager for temporary */
    if (self.x == nil && aStorage.x != nil) {
        self.x = aStorage.x;
    }
}



@end

@implementation IUCSSStorageManager {
    JDMutableArrayDict *defaultSelectorStorages;
    JDMutableArrayDict *activeSelectorStorages;
    JDMutableArrayDict *hoverSelectorStorages;
    
}

- (IUDataStorage *)newStorage{
    return [[IUCSSStorage alloc] init];
}

- (id)init{
    self = [super init];
    defaultSelectorStorages = self.workingStorages;
    activeSelectorStorages = [[JDMutableArrayDict alloc] init];
    hoverSelectorStorages = [[JDMutableArrayDict alloc] init];
    return self;
}

- (id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [super init];
    defaultSelectorStorages = [aDecoder decodeObjectForKey:@"defaultSelectorStorages"];
    activeSelectorStorages = [aDecoder decodeObjectForKey:@"activeSelectorStorages"];
    hoverSelectorStorages = [aDecoder decodeObjectForKey:@"hoverSelectorStorages"];
    self.workingStorages = defaultSelectorStorages;
    self.currentViewPort = IUDefaultViewPort;
    return self;
}

- (void)awakeAfterUsingJDCoder:(JDCoder *)aDecoder{
    self.box = [aDecoder decodeByRefObjectForKey:@"box"];
}

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [aCoder encodeObject:defaultSelectorStorages forKey:@"defaultSelectorStorages"];
    [aCoder encodeObject:activeSelectorStorages forKey:@"activeSelectorStorages"];
    [aCoder encodeObject:hoverSelectorStorages forKey:@"hoverSelectorStorages"];
    [aCoder encodeByRefObject:self.box forKey:@"box"];
}

- (void)setSelector:(IUCSSSelector)selector{
    _selector = selector;
    switch (selector) {
        case IUCSSSelectorDefault:
            self.workingStorages = defaultSelectorStorages;
            break;
        case IUCSSSelectorActive:
            self.workingStorages = activeSelectorStorages;
        case IUCSSSelectorHover:
        default:
            self.workingStorages = hoverSelectorStorages;
            break;
    }
    if ([self.workingStorages objectForKey:@(self.currentViewPort)] == nil) {
        IUDataStorage *newStorage = [self newStorage];
        newStorage.manager = self;
        [self.workingStorages setObject:newStorage forKey:@(self.currentViewPort)];
        [self.workingStorages reverseSortArrayWithDictKey];
    }
    self.currentStorage = [self.workingStorages objectForKey:@(self.currentViewPort)];
    self.liveStorage = [self createLiveStorage];
}

- (IUCSSStorage*)storageForViewPort:(NSInteger)viewPort selector:(IUCSSSelector)selector{
    switch (selector) {
        case IUCSSSelectorActive:
            return [activeSelectorStorages objectForKey:@(viewPort)];
            break;
        case IUCSSSelectorDefault:
            return [defaultSelectorStorages objectForKey:@(viewPort)];
            break;
        case IUCSSSelectorHover:
        default:
            return [hoverSelectorStorages objectForKey:@(viewPort)];
    }
}


- (void)storage:(IUCSSStorage*)storage change:(NSDictionary *)change {
    //sync current storage and live storage
    [super storage:storage change:change];

    NSString *key = change[@"key"];
    id newValue = change[@"newValue"];
    // id oldValue = change[@"oldValue"]; // use this value if needed
    
    // X set from non-nil -> nil value
    // set XUnit as nil
    // X set from nil -> non-nil value
    // set XUnit as live value

    if ([key isEqualToString:@"x"] && newValue != nil ) {
        if (self.liveStorage.xUnit == nil) {
            self.liveStorage.xUnit = @(IUFrameUnitPixel);
        }
    }
}


- (IUCSSStorage*)storageForViewPort:(NSInteger)viewPort{
    return (IUCSSStorage*)[super storageForViewPort:viewPort];
}

@end

