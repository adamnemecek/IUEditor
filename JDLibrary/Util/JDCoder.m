//
//  JDCoder.m
//  IUEditor
//
//  Created by jd on 10/1/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "JDCoder.h"
#import "NSObject+JDExtension.h"

@interface JDCoder()
- (NSArray*)keysOfCurrentDecodingObject;
- (NSString*)decodeStringForKey:(NSString*)key;
- (void)setObject:(id)object forKey:(id<NSCopying>)aKey;
//- (id)decodeObjectInArrayAtIndex:(NSUInteger)index;
- (NSMutableDictionary*)dataDict;
@end

@implementation NSString(JDCoding)

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [aCoder setObject:self forKey:@"content__"];
}

- (id)initWithJDCoder:(JDCoder *)aDecoder{
    NSString *value = [aDecoder decodeStringForKey:@"content__"];
    self = [self initWithString:value];
    return self;
}

@end

@implementation NSArray(JDCoding)

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [aCoder encodeArray:self];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (id)initWithJDCoder:(JDCoder *)aDecoder{
    return [aDecoder decodeArray];
}
#pragma clang diagnostic pop

@end

@implementation NSDictionary(JDCoding)
- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [aCoder encodeObject:obj forKey:key];
    }];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (id)initWithJDCoder:(JDCoder *)aDecoder{
    return [aDecoder decodeDictionary];
}
#pragma clang diagnostic pop
@end

@implementation NSNumber (JDCoding)
- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [aCoder encodeDouble:[self doubleValue] forKey:@"content__"];
}

- (id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [self initWithDouble:[aDecoder decodeDoubleForKey:@"content__"]];
    return self;
}
@end



@implementation NSColor (JDCoding)

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    NSColor *convertedColor=[self colorUsingColorSpaceName:NSDeviceRGBColorSpace];
    [aCoder encodeDouble:[convertedColor redComponent] forKey:@"R"];
    [aCoder encodeDouble:[convertedColor greenComponent] forKey:@"G"];
    [aCoder encodeDouble:[convertedColor blueComponent] forKey:@"B"];
    [aCoder encodeDouble:[convertedColor alphaComponent] forKey:@"A"];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (id)initWithJDCoder:(JDCoder *)aDecoder{
    NSColor *color = [NSColor colorWithDeviceRed:[aDecoder decodeDoubleForKey:@"R"]
                                           green:[aDecoder decodeDoubleForKey:@"G"]
                                            blue:[aDecoder decodeDoubleForKey:@"B"]
                                           alpha:[aDecoder decodeDoubleForKey:@"A"]];
    return color;
}
#pragma clang diagnostic pop


@end


@implementation JDCoder {
    NSMutableArray *initSelectors;
    NSMutableDictionary *dataDict;
    NSMutableDictionary *workingDict;
    NSMutableDictionary *decodedObjects; /* decoded Objects has objects which finished decoding. It is updated at when object is decoded */
    NSMutableArray *encodingObjects; /* encoding objects has objects in current encoding. It is updated at when object will be encoded */
}

/**
 Register Notifications of initialize process
 */

- (instancetype)init{
    self = [super init];
    initSelectors = [NSMutableArray arrayWithObjects:@"awakeAfterUsingJDCoder:", nil];
    workingDict = [NSMutableDictionary dictionary];
    dataDict = workingDict;
    decodedObjects = [NSMutableDictionary dictionary];
    encodingObjects = [NSMutableArray array];
    return self;
}

- (void)appendSelectorInInitProcess:(SEL)selector{
    NSString *selectorStr = NSStringFromSelector(selector);
    [initSelectors addObject:selectorStr];
}

- (NSMutableDictionary*)dataDict{
    return dataDict;
}


/**
 encode / decode top object
 */

- (void)encodeRootObject:(NSObject <JDCoding> *)object{
    if (object == nil) {
        NSAssert(0, @"object should not be nil");
    }
    workingDict[@"class__"] = object.className;
    workingDict[@"memory__"] = object.memoryAddress;
    [encodingObjects addObject:object];
    [object encodeWithJDCoder:self];
    [encodingObjects removeObject:object];
}

- (void)encodeInteger:(NSInteger)value forKey:(NSString*)key{
    [workingDict setValue:@(value) forKey:key];
}

- (void)encodeBool:(BOOL)value forKey:(NSString*)key{
    [workingDict setValue:@(value) forKey:key];
}

- (void)encodeFloat:(float)value forKey:(NSString*)key{
    [workingDict setValue:@(value) forKey:key];
}

- (void)encodeDouble:(double)value forKey:(NSString*)key{
    [workingDict setValue:@(value) forKey:key];
}

- (void)setObject:(id)object forKey:(NSString*)key{
    [workingDict setObject:object forKey:key];
}

- (void)encodeArray:(NSArray *)array {
    NSMutableDictionary *workingDict_cache = workingDict;
    NSMutableArray *contentArray = [NSMutableArray array];
    workingDict[@"content__"] = contentArray;
    for (id item in array) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [contentArray addObject:dict];
        workingDict = dict;
        if ([encodingObjects containsObject:item]) {
            [self encodeByRefObject:item];
        }
        else {
            [encodingObjects addObject:item];
            [self encodeObject:item];
            [encodingObjects removeObject:item];
        }
    }
    workingDict = workingDict_cache;
}
- (NSDictionary*)decodeDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSMutableDictionary *originalDict = workingDict;
    for (NSMutableDictionary *key in workingDict) {
        if ([key isEqualTo:@"memory__"] || [key isEqualTo:@"class__"]) {
            continue;
        }
        workingDict = workingDict[key];
        if (decodedObjects[workingDict[@"memory__"]]){
            dict[key] = decodedObjects[workingDict[@"memory__"]][@"object__"];
        }
        else {
            dict[key] = [self decodeObject];
        }
        workingDict = originalDict;
    }
    
    NSString *className = workingDict[@"class__"];
    NSDictionary *retDict = [[NSClassFromString(className) alloc] initWithDictionary:dict];
    return retDict;
}

- (NSArray *)decodeArray {
    /* we already checked decoded object in decodeObjectForKey: */
    NSMutableArray *array = [NSMutableArray array];
    NSMutableDictionary *originalDict = workingDict;
    NSArray *contentArray = workingDict[@"content__"];
    for (NSMutableDictionary *itemDict in contentArray) {
        workingDict = itemDict;
        if (decodedObjects[workingDict[@"memory__"]]){
            [array addObject:decodedObjects[workingDict[@"memory__"]][@"object__"]];
        }
        else {
            [array addObject:[self decodeObject]];
        }
    }
    
    workingDict = originalDict;
    
    NSString *className = workingDict[@"class__"];
    NSArray *returnArray = [[NSClassFromString(className) alloc] initWithArray:array];
    return returnArray;
}

- (void)encodeByRefObject:(NSObject <JDCoding> *)obj forKey:(NSString*)key{
    if (obj == nil){
        return;
    }
    workingDict[key] = [NSMutableDictionary dictionary];
    workingDict[key][@"class__"] = NSStringFromClass([obj classForKeyedArchiver]);
    workingDict[key][@"memory__"] = [NSString stringWithFormat:@"%p", obj];
}

- (void)encodeByRefObject:(NSObject <JDCoding> *)obj{
    workingDict[@"class__"] = NSStringFromClass([obj classForKeyedArchiver]);
    workingDict[@"memory__"] = [NSString stringWithFormat:@"%p", obj];
}

- (id)decodeByRefObjectForKey:(NSString *)key{
    if (workingDict[key]) {
        NSString *memoryAddress = workingDict[key][@"memory__"];
        if (decodedObjects[memoryAddress] == nil) {
            [NSException raise:@"JDDecodeError" format:@"Object Not decoded before decodeByRefObjectForKey:%@ is called", key];
        }
        return decodedObjects[memoryAddress][@"object__"];
    }
    else {
        return nil;
    }
}

- (void)encodeObject:(NSObject <JDCoding> *)obj{
    if (obj == nil) {
        return;
    }
    /* because of memory sharing ( weak object ), string or number should be saved as dictionary, to encode memory address */
    workingDict[@"class__"] = NSStringFromClass([obj classForKeyedArchiver]);
    workingDict[@"memory__"] = obj.memoryAddress;
    [obj encodeWithJDCoder:self];
}

- (id)decodeObjectForKey:(NSString*)key{
    if (workingDict[key]) {
        id memory = workingDict[key][@"memory__"];
        if (decodedObjects[memory]) {
            return decodedObjects[memory][@"object__"];
        }
        
        NSMutableDictionary *originalWorkingDict = workingDict;
        workingDict = workingDict[key];
        id obj;
        if ([[workingDict objectForKey:@"content__"] isKindOfClass:[NSArray class]]) {
            obj = [self decodeArray];
        }
        else {
            obj = [self decodeObject];
        }
        workingDict = originalWorkingDict;
        return obj;
    }
    return nil;
}

- (id)decodeObject {
    NSString *className = workingDict[@"class__"];
    NSString *memory = workingDict[@"memory__"];
    
    NSObject <JDCoding> *newObj = [(NSObject <JDCoding>  *)[NSClassFromString(className) alloc] initWithJDCoder:self];
    decodedObjects[memory] = @{@"workingDict__":workingDict, @"object__":newObj};
    return newObj;
}

- (void)encodeObject:(NSObject <JDCoding> *)obj forKey:(NSString*)key{
    if (obj == nil) {
        return;
    }
        /* because of memory sharing ( weak object ), string or number should be saved as dictionary, to encode memory address */

    NSMutableDictionary* originalworkingDict = workingDict;
    NSMutableDictionary *newworkingDict = [NSMutableDictionary dictionary];
    workingDict[key] = newworkingDict;
    workingDict = newworkingDict;
    if ([encodingObjects containsObject:obj]) {
        [self encodeByRefObject:obj];
    }
    else {
        [encodingObjects addObject:obj];
        [self encodeObject:obj];
        [encodingObjects removeObject:obj];
    }
    workingDict = originalworkingDict;
}

- (void)encodeFromObject:(NSObject *)obj withProperties:(NSArray*)properties{
    for (JDProperty *property in properties) {
        if ([property isReadonly]) {
            continue;
        }
        else if ([property isWeak]){
            [self encodeByRefObject:[obj valueForKey:property.name] forKey:property.name];
        }
        else if ([property isInteger]){
            [self encodeInteger:[[obj valueForKey:property.name] integerValue] forKey:property.name];
        }
        else if ([property isChar]){
            [self encodeInteger:[[obj valueForKey:property.name] charValue] forKey:property.name];
        }
        else if ([property isFloat]){
            [self encodeFloat:[[obj valueForKey:property.name] floatValue] forKey:property.name];
        }
        else if ([property isDouble]){
            [self encodeDouble:[[obj valueForKey:property.name] doubleValue] forKey:property.name];
        }
        else if ([property isID]){
            [self encodeObject:[obj valueForKey:property.name] forKey:property.name];
        }
        else if ([property isSize]){
            NSAssert(0, @"You cannot encode size");
        }
        else if ([property isPoint]){
            NSAssert(0, @"You cannot encode point");
        }
        else if ([property isRect]){
            NSAssert(0, @"You cannot encode rect");
        }
        else{
            NSAssert(0, @"");
        }
    }
}



- (NSInteger)decodeIntegerForKey:(NSString*)key{
    return [workingDict[key] integerValue];
}


- (float)decodeFloatForKey:(NSString*)key{
    return [workingDict[key] floatValue];
}

- (double)decodeDoubleForKey:(NSString*)key{
    return [workingDict[key] doubleValue];
}

- (BOOL)decodeBoolForKey:(NSString*)key{
    return [workingDict[key] boolValue];
}

- (NSString*)decodeStringForKey:(NSString*)key{
    return workingDict[key];
}

-(void) decodeToObject:(id)obj withProperties:(NSArray*)properties{
    for (JDProperty *property in properties) {
        if ([property isReadonly]) {
            continue;
        }
        if ([property isWeak]) {
            id obj = [self decodeByRefObjectForKey:property.name];
            [obj setValue:obj forKey:property.name];
        }
        else if ([property isInteger]){
            [obj setValue:@([self decodeIntegerForKey:property.name]) forKey:property.name];
        }
        else if ([property isFloat]){
            [obj setValue:@([self decodeFloatForKey:property.name]) forKey:property.name];
        }
        else if ([property isDouble]){
            [obj setValue:@([self decodeDoubleForKey:property.name]) forKey:property.name];
        }
        else if ([property isChar]){
            [obj setValue:@([self decodeIntegerForKey:property.name]) forKey:property.name];
        }
        else if ([property isID]){
            id v = [self decodeObjectForKey:property.name];
            if (v) {
                [obj setValue:v forKey:property.name];
            }
        }
        else if ([property isSize]){
            NSAssert(0, @"Cannot decode size");
        }
        else if ([property isPoint]){
            NSAssert(0, @"Cannot decode point");
        }
        else if ([property isRect]){
            NSAssert(0, @"Cannot decode rect");
        }
        else{
            NSAssert(0, @"");
        }
    }
}

- (BOOL)writeToFilePath:(NSString *)filePath error:(NSError **)error{
    NSData *data = [self data];
    return [data writeToFile:filePath options:0 error:error];
}

- (id)decodeContentOfData:(NSData *)data error:(NSError *__autoreleasing *)error{
    workingDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
    return [self decodeRootObject];
}

- (id)decodeContentOfFilePath:(NSString*)filePath error:(NSError **)error{
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    workingDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
    return [self decodeRootObject];
}

- (id)decodeRootObject {
    NSString *className = workingDict[@"class__"];
    NSObject <JDCoding> *newObj = [(NSObject <JDCoding>  *)[NSClassFromString(className) alloc] initWithJDCoder:self];
    [decodedObjects setObject:@{@"workingDict__":dataDict, @"object__":newObj} forKey:workingDict[@"memory__"]];
    
    for (NSString *selectorString in initSelectors) {
        SEL sel = NSSelectorFromString(selectorString);
        [decodedObjects enumerateKeysAndObjectsUsingBlock:^(id key, NSDictionary* obj, BOOL *stop) {
            workingDict = obj[@"workingDict__"];
            if ([obj[@"object__"] respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [obj[@"object__"] performSelector:sel withObject:self];
#pragma clang diagnostic pop
            }
        }];
    }
    return newObj;
}



- (NSArray*)keysOfCurrentDecodingObject{
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[workingDict allKeys]];
    [arr removeObject:@"memory__"];
    [arr removeObject:@"class__"];
    return [arr copy];
}

- (NSData*)data{
    return [NSJSONSerialization dataWithJSONObject:workingDict options:0 error:nil];
}


@end