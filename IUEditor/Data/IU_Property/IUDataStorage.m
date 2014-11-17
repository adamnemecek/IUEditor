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

@property IUDataStorage *currentStorage;
@property IUDataStorage *defaultStorage;
@property IUDataStorage *liveStorage;
- (void)storage:(IUDataStorage*)storage changes:(NSArray *)changes;
@end



@implementation IUDataStorage {
    IUDataStorageManager *manager;
    int _transactionLevel;
    int _disableUpdateLevel;
    NSMutableArray *_changePropertyStack;
}

/* using cache for multiple calling [IUDataStorage properties] */
static NSArray *storageProperties_cache;

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
    
    if (storageProperties_cache == nil) {
        NSArray *properties = [[self class] observingList];
        storageProperties_cache = [properties valueForKey:@"name"];
    }

    if(storageProperties_cache){
        [self addObserver:self forKeyPaths:storageProperties_cache options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:@"storageProperty"];
    }
    
    return self;

}


- (void)dealloc{
    if(storageProperties_cache){
        [self removeObserver:self forKeyPaths:storageProperties_cache];
    }
}


- (void)storagePropertyContextDidChange:(NSDictionary*)change{\
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
    [self beginTransaction:self];
    manager = [aDecoder decodeByRefObjectForKey:@"manager"];
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



@implementation IUDataStorageManager{
    NSMutableArray *_owners;
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
    _owners = [NSMutableArray array];
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


@implementation IUCSSStorage {
}

+ (NSArray *)observingList{
    return [IUCSSStorage properties];
}


#pragma mark - property

- (void)initPropertiesForDefaultViewPort{
    _xUnit = @(IUFrameUnitPixel);
    _yUnit = @(IUFrameUnitPixel);
    _widthUnit = @(IUFrameUnitPixel);
    _heightUnit = @(IUFrameUnitPixel);
}

- (NSRect)currentFrameByChangingFromUnit:(IUFrameUnit)from toUnit:(IUFrameUnit)to{
    if(from == IUFrameUnitPixel && to == IUFrameUnitPercent){
        NSRect frame = [self.manager.box currentPercentFrame];
        return frame;
    }
    else if(from == IUFrameUnitPercent && to == IUFrameUnitPixel){
        NSRect frame = [self.manager.box currentPixelFrame];
        return frame;
        
    }
    return NSZeroRect;
    
}

- (void)setXUnitAndChangeX:(NSNumber *)xUnit{
    
    if(_xUnit != xUnit){
        [self willChangeValueForKey:@"xUnit"];
        [self beginTransaction:JD_CURRENT_FUNCTION];
        
        //change xValue
        NSRect frame = [self currentFrameByChangingFromUnit:[_xUnit intValue] toUnit:[xUnit intValue]];
        [self setX:@(frame.origin.x)];
        
        //change Unit
        _xUnit = xUnit;
        
        [self endTransactoin:JD_CURRENT_FUNCTION];
        [self didChangeValueForKey:@"xUnit"];
    }
    
}

- (void)setYUnitAndChangeY:(NSNumber *)yUnit{
    
    if (yUnit != _yUnit) {
        
        [self willChangeValueForKey:@"yUnit"];
        [self beginTransaction:JD_CURRENT_FUNCTION];
        
        //change yValue
        NSRect frame = [self currentFrameByChangingFromUnit:[_yUnit intValue] toUnit:[yUnit intValue]];
        [self setY:@(frame.origin.y)];
        
        _yUnit = yUnit;
        
        [self endTransactoin:JD_CURRENT_FUNCTION];
        [self didChangeValueForKey:@"yUnit"];
    }
}

- (void)setWidthUnitAndChangeWidth:(NSNumber *)widthUnit{
    

    if (widthUnit != _widthUnit) {
        
        [self willChangeValueForKey:@"widthUnit"];
        [self beginTransaction:JD_CURRENT_FUNCTION];
        
        //change widthValue
        NSRect frame = [self currentFrameByChangingFromUnit:[_widthUnit intValue] toUnit:[widthUnit intValue]];
        [self setWidth:@(frame.size.width)];
        
        _widthUnit = widthUnit;
        [self endTransactoin:JD_CURRENT_FUNCTION];
        [self didChangeValueForKey:@"widthUnit"];
        
    }
}

- (void)setHeightUnitAndChangeHeight:(NSNumber *)heightUnit{
    if (heightUnit != _heightUnit) {
        
        [self willChangeValueForKey:@"heightUnit"];
        [self beginTransaction:JD_CURRENT_FUNCTION];
        
        //change heightValue
        NSRect frame = [self currentFrameByChangingFromUnit:[_heightUnit intValue] toUnit:[heightUnit intValue]];
        [self setHeight:@(frame.size.height)];
        
        _heightUnit = heightUnit;
        
        [self endTransactoin:JD_CURRENT_FUNCTION];
        [self didChangeValueForKey:@"heightUnit"];

    }
}

- (void)setBorderColor:(id)borderColor{
    [self beginTransaction:JD_CURRENT_FUNCTION];
    
    [self setTopBorderColor:borderColor];
    [self setLeftBorderColor:borderColor];
    [self setRightBorderColor:borderColor];
    [self setBottomBorderColor:borderColor];
    
    [self commitTransaction:JD_CURRENT_FUNCTION];
    
}

- (BOOL)isAllBorderColorsEqual{
    
    if([_topBorderColor isEqualTo:_bottomBorderColor]
       && [_topBorderColor isEqualTo:_leftBorderColor]
       && [_topBorderColor isEqualTo:_rightBorderColor]){
        return YES;
    }
    return NO;
}
- (NSColor *)borderColor{
    if ([self isAllBorderColorsEqual]) {
        return _topBorderColor;
    }
    return NSMultipleValuesMarker;
}

- (void)setBorderWidth:(NSNumber *)borderWidth{
    
    [self beginTransaction:JD_CURRENT_FUNCTION];
    
    [self setTopBorderWidth:borderWidth];
    [self setBottomBorderWidth:borderWidth];
    [self setLeftBorderWidth:borderWidth];
    [self setRightBorderWidth:borderWidth];
    
    [self commitTransaction:JD_CURRENT_FUNCTION];
    
}

- (BOOL)isAllBorderWidthEqual{
    if([_topBorderWidth isEqualToNumber:_bottomBorderWidth]
       && [_topBorderWidth isEqualToNumber:_leftBorderWidth]
       && [_topBorderWidth isEqualToNumber:_rightBorderWidth]){
        return YES;
    }
    return NO;
}

- (NSNumber *)borderWidth{
    if([self isAllBorderWidthEqual]){
        return _topBorderWidth;
    }
    return NSMultipleValuesMarker;
}

- (void)setBorderRadius:(NSNumber *)borderRadius{
    
    [self beginTransaction:JD_CURRENT_FUNCTION];

    [self setTopLeftBorderRadius:borderRadius];
    [self setTopRightBorderRadius:borderRadius];
    [self setBottomLeftborderRadius:borderRadius];
    [self setBottomRightBorderRadius:borderRadius];
    
    [self commitTransaction:JD_CURRENT_FUNCTION];

}

- (BOOL)isAllBorderRadiusEqual{
    if([_topLeftBorderRadius isEqualToNumber:_topRightBorderRadius]
       && [_topLeftBorderRadius isEqualToNumber:_bottomLeftborderRadius]
       && [_topLeftBorderRadius isEqualToNumber:_bottomRightBorderRadius]
       ){
        return YES;
    }
    return NO;
}

- (NSNumber *)borderRadius{
    if([self isAllBorderRadiusEqual]){
        return _topLeftBorderRadius;
    }
    
    return NSMultipleValuesMarker;
}


- (void)overwritingDataStorageForNilValue:(IUCSSStorage*)aStorage{
    [super overwritingDataStorageForNilValue:aStorage];
    /* remove update manager for temporary */
    if (self.x == nil && aStorage.x != nil) {
        self.x = aStorage.x;
    }
}


/* it's for conversion */
- (void)setCSSValue:(id)value fromCSSforCSSKey:(NSString *)key{
    if([value isEqualTo:NSMultipleValuesMarker]){
        //border, radius, color - 서로 다른 값을 가질때.
        return;
    }
    [self setValue:value forKey:key];
    
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
    
    IUCSSStorage *cssStorage  = [defaultSelectorStorages objectForKey:@(IUDefaultViewPort)];
    [cssStorage initPropertiesForDefaultViewPort];
    
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
}

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [aCoder encodeObject:defaultSelectorStorages forKey:@"defaultSelectorStorages"];
    [aCoder encodeObject:activeSelectorStorages forKey:@"activeSelectorStorages"];
    [aCoder encodeObject:hoverSelectorStorages forKey:@"hoverSelectorStorages"];
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


- (void)storage:(IUCSSStorage*)storage changes:(NSArray *)changes{
    //sync current storage and live storage
    [super storage:storage changes:changes];
    
    for(NSDictionary *change in changes){
        
        /*
        NSString *key = change[@"key"];
        id newValue = change[@"newValue"];
        // id oldValue = change[@"oldValue"]; // use this value if needed
        */
        
        /*
        // X set from non-nil -> nil value
        // set XUnit as nil
        // X set from nil -> non-nil value
        // set XUnit as live value
        
        if ([key isEqualToString:@"x"] && newValue != nil ) {
            if (self.liveStorage.xUnit == nil) {
                self.liveStorage.xUnit = @(IUFrameUnitPixel);
            }
        }
         */
    }
}


- (IUCSSStorage*)storageForViewPort:(NSInteger)viewPort{
    return (IUCSSStorage*)[super storageForViewPort:viewPort];
}

@end

