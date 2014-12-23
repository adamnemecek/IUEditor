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
@property id cascadingStorage;
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

- (NSString *)description {
    return [[super description] stringByAppendingString:[_storage description]];
}
/**
@brief iubox에서 사용하는 property list (datastorage 자체의 property와 구분하기 위해서 사용)
 */
+(NSArray *)iuDataList{
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
    if([[self class] iuDataList]){
        NSArray *keyPaths = [[[self class] iuDataList] valueForKey:@"name"];
        [self addObserver:self forKeyPaths:keyPaths options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:@"storageProperty"];
    }
    
    return self;

}



- (void)dealloc{
    if([[self class] iuDataList]){
        NSArray *keyPaths = [[[self class] iuDataList] valueForKey:@"name"];
        for (NSString *keyPath in keyPaths) {
            [self removeObserver:self forKeyPath:keyPath];
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
    
    NSArray *keyArray = [[[self class] iuDataList] valueForKey:@"name"];
    for (NSString *key in keyArray){
        if([self valueForKey:key] == nil){
            id value = [aStorage valueForKey:key];
            if(value){
                [self setValue:value forKey:key];
            }
        }
    }
}
- (void)beginTransaction:(id)sender{
    _transactionLevel++;
}


- (void)commitTransaction:(id)sender{
    _transactionLevel--;
    
    NSAssert(_transactionLevel >= 0, @"transactionLevel is smaller than 0");
    
    if(_transactionLevel == 0){
        [self.manager.undoManager beginUndoGrouping];
        for(NSDictionary *change in _changePropertyStack){
            [[self.manager.undoManager prepareWithInvocationTarget:self] setValue:change[@"oldValue"] forKey:change[@"key"]];
            
        }
        [self.manager.undoManager endUndoGrouping];
        if(_changePropertyStack.count > 0){
            [self.manager storage:self changes:[_changePropertyStack copy]];
        }
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

    _workingStorages = [[JDMutableArrayDict alloc] init];
    _storageClassName = @"IUDataStorage";
    
    IUDataStorage *defaultStorage = [self newStorage];
    defaultStorage.manager = self;
    
    _maxViewPort = IUDefaultViewPort;
    [self.workingStorages insertObject:defaultStorage forKey:@(_maxViewPort) atIndex:0];
    _defaultStorage = defaultStorage;
    
    [self setDefaultProperties];

    return self;
}

- (id)initWithStorageClassName:(NSString *)className{
    self = [super init];
    if(self){
        _workingStorages = [[JDMutableArrayDict alloc] init];
        _storageClassName = className;
        
        IUDataStorage *defaultStorage = [self newStorage];
        defaultStorage.manager = self;
        
        _maxViewPort = IUDefaultViewPort;
        [self.workingStorages insertObject:defaultStorage forKey:@(_maxViewPort) atIndex:0];
        _defaultStorage = defaultStorage;
        
        [self setDefaultProperties];

    }
    
    return self;
}


- (void)dealloc{
    [self removeObserver:self forKeyPath:@"currentViewPort"];
}

- (id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [super init];
    if(self){
        
        //decoder
        _workingStorages = [aDecoder decodeObjectForKey:@"storages"];
        _maxViewPort = [aDecoder decodeIntegerForKey:@"maxViewPort"];
     
        _storageClassName = [aDecoder decodeObjectForKey:@"storageClassName"];
        _defaultStorage =  [_workingStorages objectForKey:@(_maxViewPort)];
        
        [self setDefaultProperties];

    }
    return self;
}

/**
@brief set default properties after calling initialize process (init/initWithStorageClassName/initWithJDCoder)
 */
- (void)setDefaultProperties{

    _currentStorage = _defaultStorage;
    _cascadingStorage = _currentStorage;
    _currentViewPort = _maxViewPort;
    _owners = [NSMutableArray array];
    
    [self addObserver:self forKeyPath:@"currentViewPort" options:0 context:nil];

}

- (void)awakeAfterUsingJDCoder:(JDCoder *)aDecoder{
    
    for(IUDataStorage *storage in [_workingStorages allValues]){
        storage.manager = self;
    }
}

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [aCoder encodeObject:self.workingStorages forKey:@"storages"];
    [aCoder encodeInteger:_maxViewPort forKey:@"maxViewPort"];
    [aCoder encodeObject:_storageClassName forKey:@"storageClassName"];
}

- (id)copyWithZone:(NSZone *)zone{
    IUDataStorageManager *manager = [[[self class] allocWithZone:zone] init];
    manager.workingStorages = [_workingStorages copy];
    manager.defaultStorage = [manager.workingStorages objectForKey:@(self.maxViewPort)];
    manager.currentViewPort = _currentViewPort; //create cascading storages
    
    for(IUDataStorage *storage in [manager.workingStorages allValues]){
        storage.manager = manager;
    }
    
    
    return manager;
}

#pragma mark - properties

- (void)addOwner:(id<IUDataStorageManagerDelegate,JDCoding>)box{
    /**
     REVIEW : owner should be a weak object
     http://stackoverflow.com/questions/21797617/how-to-store-weak-reference-object-in-array-dictionary-in-objc
     */
    NSValue *weakObj = [NSValue valueWithNonretainedObject:box];
    [_owners addObject:weakObj];
}

- (void)removeOwner:(id<IUDataStorageManagerDelegate,JDCoding>)box{
    NSValue *weakObj = [NSValue valueWithNonretainedObject:box];
    [_owners removeObject:weakObj];
}

- (NSArray *)owners{
    NSMutableArray *realOwners = [NSMutableArray array];
    for(NSValue *weakObj in _owners){
        id box = [weakObj nonretainedObjectValue];
        [realOwners addObject:box];
    }
    return [realOwners copy];
}



- (id)cascadingStorageForViewPort:(NSInteger)viewPort{
    /* does not send information to manager */
    IUDataStorage *cascadingStorage = [[self storageForViewPort:viewPort] copy];
    [cascadingStorage disableUpdate:self];
    /*
     get overwrite all data
     */
    IUDataStorage *currStorage = self.currentStorage;
    while ( (currStorage = [self storageWithBiggerViewPortOf:currStorage]) ) {
        [cascadingStorage overwritingDataStorageForNilValue:currStorage];
    }
    [cascadingStorage enableUpdate:self];
    return cascadingStorage;
}

- (void)setCurrentViewPort:(NSInteger)currentViewPort{
    if (_currentViewPort == currentViewPort) {
        return;
    }
    [self willChangeValueForKey:@"currentViewPort"];
    if ([self.workingStorages objectForKey:@(currentViewPort)] == nil) {
        [self createStorageForViewPort:currentViewPort];
    }
    
    self.currentStorage = [self.workingStorages objectForKey:@(currentViewPort)];
    self.cascadingStorage = [self cascadingStorageForViewPort:currentViewPort];
    ((IUDataStorage *)self.cascadingStorage).manager = self;
    
    _currentViewPort = currentViewPort;
    [self didChangeValueForKey:@"currentViewPort"];
}

- (void)copyDataStorageFrom:(NSInteger)from to:(NSInteger)to{
    IUDataStorage *originalMaxStorage = [self storageForViewPort:from];
    IUDataStorage *maxStorage = [originalMaxStorage copy];
    maxStorage.manager = self;
    [self.workingStorages setObject:maxStorage forKey:@(to)];
    [self.workingStorages reverseSortArrayWithDictKey];
}


- (IUDataStorage*)storageForViewPort:(NSInteger)viewPort{
    return [_workingStorages objectForKey:@(viewPort)];
}

- (NSInteger)viewPortOfStorage:(IUDataStorage*)storage{
    return [[self.workingStorages firstKeyForObject:storage] integerValue];
}

- (void)createStorageForViewPort:(NSInteger)viewPort{
    IUDataStorage *newStorage = [self newStorage];
    newStorage.manager = self;
    [self.workingStorages setObject:newStorage forKey:@(viewPort)];
    [self.workingStorages reverseSortArrayWithDictKey];
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

- (NSInteger)countOfValueForKey:(NSString *)key{
    NSInteger count =0;
    for(IUDataStorage *storage in [_workingStorages allValues]){
        id value = [storage valueForKey:key];
        if(value){
            count++;
        }
    }
    return count;
}
- (NSDictionary *)dictionaryWithWidthForKey:(NSString *)key{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for(NSNumber *viewport in [_workingStorages allKeys]){
        IUDataStorage *storage = [_workingStorages objectForKey:viewport];
        id value = [storage valueForKey:key];
        if(value){
            [dictionary setObject:value forKey:viewport];
        }
    }
    return [dictionary copy];
}


/**
 Manage new value of cascading storage = currentStroage
 */
- (void)storage:(IUDataStorage*)storage changes:(NSArray *)changes{
    NSMutableArray *changedKeys = [NSMutableArray array];
    for(NSDictionary *changeDict in changes){
        NSString *key = changeDict[@"key"];
        [changedKeys addObject:key];
        
        //   there are "newValue" and "oldValue" in dictionary, but not using in here
        //    id newValue = change[@"newValue"];
        //    id oldValue = change[@"oldValue"];
        
        if (storage == self.currentStorage) {
            [self.cascadingStorage disableUpdate:self];
            [self.cascadingStorage setValue:changeDict[@"newValue"] forKey:key];
            [self.cascadingStorage enableUpdate:self];
        }
        else if (storage == self.cascadingStorage) {
            [self.currentStorage disableUpdate:self];
            [self.currentStorage setValue:changeDict[@"newValue"] forKey:key];
            [self.currentStorage enableUpdate:self];
        }
        else {
            NSAssert(0, @"Only current storage and cascading storage is updatable");
        }
    }
    
    if(changedKeys.count > 0){
        for(id <IUDataStorageManagerDelegate> box in self.owners){
            [box setNeedsToUpdateStorage:storage keys:[changedKeys copy]];
        }
    }
}


- (id)liveValueForKey:(id)key forViewPort:(NSInteger)viewPort __deprecated{
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

