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
- (void)encodeObjectInArray:(id)object;
- (id)decodeObjectInArrayAtIndex:(NSUInteger)index;
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
    for (int i=0; i<self.count; i++) {
        [aCoder encodeObjectInArray:[self objectAtIndex:i]];
    }
}

- (id)initWithJDCoder:(JDCoder *)aDecoder{
    NSMutableArray *content = [[NSMutableArray alloc] init];
    for (int i=0; ; i++) {
        id obj = [aDecoder decodeObjectInArrayAtIndex:i];
        if (obj) {
            [content addObject:obj];
        }
        else {
            break;
        }
    }
    self = [self initWithArray:content];
    return self;
}


@end

@implementation NSDictionary(JDCoding)
- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [aCoder encodeObject:obj forKey:key];
    }];
}

- (id)initWithJDCoder:(JDCoder *)aDecoder{
    NSMutableDictionary *temp = [NSMutableDictionary dictionary];
    for (id key in [aDecoder keysOfCurrentDecodingObject]) {
        if ([key isEqualTo:@"class__"] == NO ) {
            temp[key] = [aDecoder decodeObjectForKey:key];
        }
    }
    return [self initWithDictionary:temp];
}
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
    NSMutableDictionary *decodedObjects;
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
    [object encodeWithJDCoder:self];
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

- (void)encodeObjectInArray:(id)object{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [workingDict[@"content__"] addObject:dict];
    
}

- (id)decodeObjectInArrayAtIndex:(NSUInteger)index{
    NSMutableDictionary* originalDict = workingDict;
    if ([workingDict[@"content__"] count] <= index) {
        return nil;
    }

    workingDict = [workingDict[@"content__"] objectAtIndex:index];
    NSString *className = workingDict[@"class__"];
    NSObject <JDCoding> *newObj;
    newObj= [(NSObject <JDCoding>  *)[NSClassFromString(className) alloc] initWithJDCoder:self];
    [decodedObjects setObject:@{@"object__":newObj, @"dict__":workingDict} forKey:workingDict[@"memory__"]];

    workingDict = originalDict;
    return newObj;

}


- (void)encodeByRefObject:(NSObject <JDCoding> *)obj forKey:(NSString*)key{
    if (obj == nil){
        return;
    }
    workingDict[key] = [NSMutableDictionary dictionary];
    workingDict[key][@"class__"] = NSStringFromClass([obj classForKeyedArchiver]);
    workingDict[key][@"memory__"] = [NSString stringWithFormat:@"%p", obj];
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


- (void)encodeObject:(NSObject <JDCoding> *)obj forKey:(NSString*)key{
    if (obj == nil) {
        return;
    }
    if ([obj isKindOfClass:[NSArray class]]){
        /* because of memory sharing ( weak object ), array should be saved as dictionary, to encode memory address */

        NSArray *objArray = (NSArray*)obj;
        NSMutableDictionary* savedworkingDict = workingDict;
        
        workingDict[key] = [NSMutableDictionary dictionary];
        workingDict[key][@"class__"] = NSStringFromClass([obj classForKeyedArchiver]);
        workingDict[key][@"memory__"] = obj.memoryAddress;
        
        NSMutableArray *content = [NSMutableArray array];
        workingDict[key][@"content__"] = content;
        
        for (int i=0; i< [objArray count]; i++) {
            NSObject <JDCoding> *item = [objArray objectAtIndex:i];
            
            NSMutableDictionary *itemworkingDict = [NSMutableDictionary dictionary];
            itemworkingDict[@"class__"] = NSStringFromClass([item classForKeyedArchiver]);
            itemworkingDict[@"memory__"] = item.memoryAddress;
            
            workingDict = itemworkingDict;
            [content addObject:workingDict];
            [item encodeWithJDCoder:self];
        }
        
        workingDict = savedworkingDict;
    }
    else {
        /* because of memory sharing ( weak object ), string or number should be saved as dictionary, to encode memory address */
        
        
        NSMutableDictionary *newworkingDict = [NSMutableDictionary dictionary];
        newworkingDict[@"class__"] = NSStringFromClass([obj classForKeyedArchiver]);
        newworkingDict[@"memory__"] = obj.memoryAddress;
        
        if (obj != nil) {
            NSMutableDictionary* originalworkingDict = workingDict;
            workingDict = newworkingDict;
            [obj encodeWithJDCoder:self];
            workingDict = originalworkingDict;
            workingDict[key] = newworkingDict;
        }
    }
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

- (id)decodeObjectForKey:(NSString*)key{
    if (workingDict[key]) {
        NSMutableDictionary* current = workingDict;
        workingDict = current[key];
        NSString *className = workingDict[@"class__"];
        NSObject <JDCoding> *newObj;
        newObj= [(NSObject <JDCoding>  *)[NSClassFromString(className) alloc] initWithJDCoder:self];
        [decodedObjects setObject:@{@"object__":newObj, @"dict__":workingDict} forKey:workingDict[@"memory__"]];
        workingDict = current;
        
        return newObj;
    }
    return nil;
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

- (BOOL)writeToFile:(NSString *)filePath error:(NSError **)error{
    NSData *data = [NSJSONSerialization dataWithJSONObject:workingDict options:0 error:error];
    
    return [data writeToFile:filePath options:0 error:error];
}

- (id)decodeContentOfFile:(NSString*)filePath error:(NSError **)error{
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    workingDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
    return [self decodeRootObject];
}

- (id)decodeRootObject {
    NSString *className = workingDict[@"class__"];
    NSObject <JDCoding> *newObj = [(NSObject <JDCoding>  *)[NSClassFromString(className) alloc] initWithJDCoder:self];
    [decodedObjects setObject:@{@"object__":newObj, @"dict__":workingDict} forKey:workingDict[@"memory__"]];
    
    for (NSString *selectorString in initSelectors) {
        SEL sel = NSSelectorFromString(selectorString);
        [decodedObjects enumerateKeysAndObjectsUsingBlock:^(id key, NSDictionary* dict, BOOL *stop) {
            id obj = dict[@"object__"];
            
            if ([obj respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                workingDict = dict[@"dict__"];
                [obj performSelector:sel withObject:self];
#pragma clang diagnostic pop
            }
        }];
    }
    return newObj;
}



- (void)loadFromURL:(NSURL *)url error:(NSError **)error{
}

- (NSArray*)keysOfCurrentDecodingObject{
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[workingDict allKeys]];
    [arr removeObject:@"memory__"];
    [arr removeObject:@"class__"];
    return [arr copy];
}

- (NSData*)jsonData{
    return [NSJSONSerialization dataWithJSONObject:workingDict options:0 error:nil];
}


@end