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
@end

@interface IUDataStorageManager()

@property JDMutableArrayDict *workingStorages; //key == viewPort(NSNumber) value=IUDataStorage.

@property id currentStorage;
@property id defaultStorage;
@property id liveStorage;
- (void)storage:(IUDataStorage*)storage changes:(NSArray *)changes;
@end



@implementation IUDataStorage {
    IUDataStorageManager *manager;
    int _transactionLevel;
    int _disableUpdateLevel;
    NSMutableArray *_changePropertyStack;
}

/* using cache for multiple calling [IUDataStorage properties] */
//static NSArray *storageProperties_cache;
//subclass 불가능

+(NSArray *)observingList{
    return nil;
}

- (void)disableUpdate:(id)sender{
    _disableUpdateLevel ++;
}
- (void)enableUpdate:(id)sender{
    _disableUpdateLevel --;
}


- (id)init{
    self = [super init];
    _storage = [NSMutableDictionary dictionary];
    _changePropertyStack = [NSMutableArray array];
    _transactionLevel = 0;
    
    /*
    if (storageProperties_cache == nil) {
        NSArray *properties = [[self class] observingList];
        storageProperties_cache = [properties valueForKey:@"name"];
    }

    if(storageProperties_cache){
        [self addObserver:self forKeyPaths:storageProperties_cache options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:@"storageProperty"];
    }
     */
    if([[self class] observingList]){
        NSArray *keyPaths = [[[self class] observingList] valueForKey:@"name"];
        [self addObserver:self forKeyPaths:keyPaths options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:@"storageProperty"];
    }
    
    return self;

}



- (void)dealloc{
    if([[self class] observingList]){
        NSArray *keyPaths = [[[self class] observingList] valueForKey:@"name"];
        [self removeObserver:self forKeyPaths:keyPaths];
    }
}


- (void)storagePropertyContextDidChange:(NSDictionary*)change{
    if (_disableUpdateLevel == NO) {
        NSMutableDictionary *changeDict = [NSMutableDictionary dictionary];
        if (change[NSKeyValueChangeOldKey] != [NSNull null]) {
            [changeDict setValue:change[NSKeyValueChangeOldKey] forKey:@"oldValue"];
        }
        if (change[NSKeyValueChangeNewKey] != [NSNull null]) {
            [changeDict setValue:change[NSKeyValueChangeNewKey] forKey:@"newValue"];
        }
        [changeDict setValue:change[kJDKey] forKey:@"key"];
        
        if( _transactionLevel != 0 ){
            [_changePropertyStack addObject:changeDict];
        }
        else{
            [self.manager storage:self changes:@[changeDict]];
        }
    }
}


- (id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [self init];
    _changePropertyStack = [NSMutableArray array];
    _transactionLevel = 0;
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
    
    if([[self class] observingList]){
        NSArray *keyPaths = [[[self class] observingList] valueForKey:@"name"];
        [self addObserver:self forKeyPaths:keyPaths options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:@"storageProperty"];
    }
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
    [_storage setObject:value forKey:key];
    
    if (_disableUpdateLevel == NO) {
        NSDictionary *changeLogDict;
        if (oldValue && value) {
            changeLogDict = @{@"key":key, @"oldValue":oldValue, @"newValue":value};
        }
        else if (oldValue) {
            changeLogDict = @{@"key":key, @"oldValue":oldValue,};
        }
        else {
            changeLogDict = @{@"key":key, @"newValue":value,};
        }
        
        if (_transactionLevel) {
            [_changePropertyStack addObject:changeLogDict];
        }
        else {
            [self.manager storage:self changes:@[changeLogDict]];
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
- (void)beginTransaction:(id)sender{
    _transactionLevel++;
}


- (void)commitTransaction:(id)sender{
    _transactionLevel--;
    
    if(_transactionLevel == 0){
        [self.manager.undoManager beginUndoGrouping];
        for(NSDictionary *change in _changePropertyStack){
            [[self.manager.undoManager prepareWithInvocationTarget:self] setValue:change[@"oldValue"] forKey:change[@"key"]];
            
        }
        [self.manager.undoManager endUndoGrouping];
        [self.manager storage:self changes:[_changePropertyStack copy]];
        [_changePropertyStack removeAllObjects];
    }
}

- (BOOL)isUpdateEnabled{
    if(_transactionLevel==0){
        return YES;
    }
    return NO;
}
#if DEBUG
- (NSArray *)currentPropertyStackForTest{
    return [_changePropertyStack copy];
}
#endif

@end


#pragma mark - IUDataStorageManager

@implementation IUDataStorageManager{
    NSMutableArray *_owners;
    NSString *_storageClassName;
}

- (IUDataStorage *)newStorage{
    IUDataStorage *storage = [[NSClassFromString(_storageClassName) alloc] init];
    return storage;
}

- (NSString *)storageClassName{
    return _storageClassName;
}

- (id)init{
    self = [super init];

    self.workingStorages = [[JDMutableArrayDict alloc] init];
    _storageClassName = @"IUDataStorage";
    IUDataStorage *defaultStorage = [self newStorage];
    defaultStorage.manager = self;
    
    [self.workingStorages insertObject:defaultStorage forKey:@(IUDefaultViewPort) atIndex:0];

    _defaultStorage = defaultStorage;
    _currentStorage = defaultStorage;
    
    [self addObserver:self forKeyPath:@"currentViewPort" options:0 context:nil];
    self.currentViewPort = IUCSSDefaultViewPort;
    _owners = [NSMutableArray array];
    return self;
}

- (id)initWithStorageClassName:(NSString *)className{
    self = [super init];
    if(self){
        self.workingStorages = [[JDMutableArrayDict alloc] init];
        _storageClassName = className;
        IUDataStorage *defaultStorage = [self newStorage];
        defaultStorage.manager = self;
        
        [self.workingStorages insertObject:defaultStorage forKey:@(IUDefaultViewPort) atIndex:0];
        
        _defaultStorage = defaultStorage;
        _currentStorage = defaultStorage;
        
        [self addObserver:self forKeyPath:@"currentViewPort" options:0 context:nil];
        self.currentViewPort = IUCSSDefaultViewPort;
        _owners = [NSMutableArray array];
    }
    
    return self;
}

- (void)addOwner:(id<IUDataStorageManagerDelegate,JDCoding>)box{
    [_owners addObject:box];
}

- (void)removeOwner:(id<IUDataStorageManagerDelegate,JDCoding>)box{
    [_owners removeObject:box];
}

- (NSArray *)owners{
    return [_owners copy];
}

- (void)dealloc{
    [self removeObserver:self forKeyPath:@"currentViewPort"];
}

- (id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [super init];
    _workingStorages = [aDecoder decodeObjectForKey:@"storages"];
    
    [self addObserver:self forKeyPath:@"currentViewPort" options:0 context:nil];
    self.currentViewPort = IUCSSDefaultViewPort;
    return self;
}

- (void)awakeAfterUsingJDCoder:(JDCoder *)aDecoder{
    //TODO: decode owner
}

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [aCoder encodeObject:self.workingStorages forKey:@"storages"];
    [aCoder encodeObject:_owners forKey:@"owners"];
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
    [liveStorage disableUpdate:self];
    /*
     get overwrite all data
     */
    IUDataStorage *currStorage = self.currentStorage;
    while ( (currStorage = [self storageWithBiggerViewPortOf:currStorage]) ) {
        [liveStorage overwritingDataStorageForNilValue:currStorage];
    }
    [liveStorage enableUpdate:self];
    return liveStorage;
}

- (void)setCurrentViewPort:(NSInteger)currentViewPort{
    
    if ([self.workingStorages objectForKey:@(currentViewPort)] == nil) {
        IUDataStorage *newStorage = [self newStorage];
        newStorage.manager = self;
        [self.workingStorages setObject:newStorage forKey:@(currentViewPort)];
        [self.workingStorages reverseSortArrayWithDictKey];
    }
    self.currentStorage = [self.workingStorages objectForKey:@(currentViewPort)];
    self.liveStorage = [self createLiveStorage];
    
    _currentViewPort = currentViewPort;
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
- (void)storage:(IUDataStorage*)storage changes:(NSArray *)changes{
    for(NSDictionary *changeDict in changes){
        NSString *key = changeDict[@"key"];
        
        //   there are "newValue" and "oldValue" in dictionary, but not using in here
        //    id newValue = change[@"newValue"];
        //    id oldValue = change[@"oldValue"];
        
        if (storage == self.currentStorage) {
            [self.liveStorage disableUpdate:self];
            [self.liveStorage setValue:changeDict[@"newValue"] forKey:key];
            [self.liveStorage enableUpdate:self];
        }
        else if (storage == self.liveStorage) {
            [self.currentStorage disableUpdate:self];
            [self.currentStorage setValue:changeDict[@"newValue"] forKey:key];
            [self.currentStorage enableUpdate:self];
        }
        else {
            NSAssert(0, @"Only current storage and live storage is updatable");
        }
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

