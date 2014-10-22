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
- (void)encodeString:(NSString*)string forKey:(NSString*)key;
- (NSString*)decodeStringForKey:(NSString*)key;
@end

@implementation NSArray(JDCoding)

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    for (NSUInteger i=0; i<self.count; i++) {
        NSObject <JDCoding> *obj = [self objectAtIndex:i];
        [aCoder encodeObject:obj forKey:[NSString stringWithFormat:@"%ld", i]];
    }
    [aCoder encodeInteger:self.count forKey:@"count"];
}

- (id)initWithJDCoder:(JDCoder *)aDecoder{
    NSMutableArray *tempArr = [NSMutableArray array];
    NSUInteger count = [aDecoder decodeIntegerForKey:@"count"];
    for (NSUInteger i=0; i<count; i++) {
        NSObject <JDCoding> *obj = [aDecoder decodeObjectForKey:[NSString stringWithFormat:@"%ld", i]];
        [tempArr addObject:obj];
    }
    self = [self initWithArray:tempArr];
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
        if ([key isEqualTo:@"JDClassName_"] == NO ) {
            temp[key] = [aDecoder decodeObjectForKey:key];
        }
    }
    return [self initWithDictionary:temp];
}
@end

@implementation NSString (JDCoding)
- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [aCoder encodeString:self forKey:@"value"];
}

- (id)initWithJDCoder:(JDCoder *)aDecoder{
    NSString *str = [aDecoder decodeStringForKey:@"value"];
    self = [self initWithString:str];
    return self;
}
@end

@implementation NSNumber (JDCoding)
- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [aCoder encodeDouble:[self doubleValue] forKey:@"value"];
}

- (id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [self initWithDouble:[aDecoder decodeDoubleForKey:@"value"]];
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
    NSMutableDictionary *decodedObjects;
}

/**
 Register Notifications of initialize process
 */

- (instancetype)init{
    self = [super init];
    initSelectors = [NSMutableArray arrayWithObjects:@"awakeAfterUsingJDCoder:", nil];
    dataDict = [NSMutableDictionary dictionary];
    decodedObjects = [NSMutableDictionary dictionary];
    return self;
}

- (void)appendSelectorInInitProcess:(SEL)selector{
    NSString *selectorStr = NSStringFromSelector(selector);
    [initSelectors addObject:selectorStr];
}


/**
 encode / decode top object
 */

- (void)encodeRootObject:(NSObject <JDCoding> *)object{
    if (object == nil) {
        NSAssert(0, @"object should not be nil");
    }
    dataDict[@"JDClassName_"] = object.className;
    dataDict[@"JDMemory_"] = object.memoryAddress;
    [object encodeWithJDCoder:self];
}

- (id)decodedAndInitializeObject{
    NSString *className = dataDict[@"JDClassName_"];
    NSObject <JDCoding> *newObj = [(NSObject <JDCoding>  *)[NSClassFromString(className) alloc] initWithJDCoder:self];
    [decodedObjects setObject:@{@"Object":newObj, @"Dict":dataDict} forKey:dataDict[@"JDMemory_"]];

    for (NSString *selectorString in initSelectors) {
        SEL sel = NSSelectorFromString(selectorString);
        [decodedObjects enumerateKeysAndObjectsUsingBlock:^(id key, NSDictionary* dict, BOOL *stop) {
            id obj = dict[@"Object"];
            
            if ([obj respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                dataDict = dict[@"Dict"];
                [obj performSelector:sel withObject:self];
#pragma clang diagnostic pop
            }
        }];
    }
    return newObj;
}

- (void)encodeInteger:(NSInteger)value forKey:(NSString*)key{
    [dataDict setValue:@(value) forKey:key];
}

- (void)encodeBool:(BOOL)value forKey:(NSString*)key{
    [dataDict setValue:@(value) forKey:key];
}

- (void)encodeFloat:(float)value forKey:(NSString*)key{
    [dataDict setValue:@(value) forKey:key];
}

- (void)encodeDouble:(double)value forKey:(NSString*)key{
    [dataDict setValue:@(value) forKey:key];
}

- (void)encodeString:(NSString*)value forKey:(NSString*)key{
    [dataDict setValue:value forKey:key];
}

- (void)encodeByRefObject:(NSObject <NSCoding> *)obj forKey:(NSString*)key{
    if (obj == nil){
        return;
    }
    dataDict[key] = [NSMutableDictionary dictionary];
    dataDict[key][@"JDClassName_"] = NSStringFromClass([obj classForKeyedArchiver]);
    dataDict[key][@"JDMemory_"] = [NSString stringWithFormat:@"%p", obj];
}

- (id)decodeByRefObjectForKey:(NSString *)key{
    if (dataDict[key]) {
        NSString *memoryAddress = dataDict[key][@"JDMemory_"];
        if (decodedObjects[memoryAddress] == nil) {
            [NSException raise:@"JDDecodeError" format:@"Object Not decoded before decodeByRefObjectForKey:%@ is called", key];
        }
        return decodedObjects[memoryAddress][@"Object"];
    }
    else {
        return nil;
    }
}


- (void)encodeObject:(NSObject <JDCoding> *)obj forKey:(NSString*)key{
    if (obj == nil) {
        return;
    }
    if ([[obj className] isEqualToString:@"__NSCFNumber"]) {
        [self encodeDouble:[(NSNumber*)obj doubleValue] forKey:key];
    }
    else if ([[obj className] isEqualToString:@"__NSCFConstantString"]){
        [self encodeString:(NSString*)obj forKey:key];
    }
    else {
        NSMutableDictionary* current = dataDict;
        dataDict = [NSMutableDictionary dictionary];
        current[key] = dataDict;
        current[key][@"JDClassName_"] = NSStringFromClass([obj classForKeyedArchiver]);
        current[key][@"JDMemory_"] = obj.memoryAddress;
        if (obj != nil) {
            [obj encodeWithJDCoder:self];
        }
        dataDict = current;
    }
}

- (void)encodeFromObject:(NSObject *)obj withProperties:(NSArray*)properties{
    for (JDProperty *property in properties) {
        if ([property isReadonly]) {
            continue;
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
    return [dataDict[key] integerValue];
}

- (id)decodeObjectForKey:(NSString*)key{
    id value = dataDict[key];
    if ([value isMemberOfClass:[NSNumber class]] || [value isMemberOfClass:[NSString class]]) {
        return value;
    }
    else if ([[value className] isEqualToString:@"__NSCFConstantString"] || [value isKindOfClass:[NSString class]] || [[value className] isEqualToString:@"__NSCFNumber"] || [value isKindOfClass:[NSNumber class]]){
        return value;
    }
    else {
        NSMutableDictionary* current = dataDict;
        dataDict = current[key];
        NSString *className = dataDict[@"JDClassName_"];
        NSObject <JDCoding> *newObj;
        if ([className isEqualToString:@"__NSDictionaryM"]) {
            newObj = [[NSMutableDictionary alloc] initWithJDCoder:self];
        }
        else {
            newObj= [(NSObject <JDCoding>  *)[NSClassFromString(className) alloc] initWithJDCoder:self];
        }
        [decodedObjects setObject:@{@"Object":newObj, @"Dict":dataDict} forKey:dataDict[@"JDMemory_"]];
        dataDict = current;
        
        return newObj;
    }
}

- (float)decodeFloatForKey:(NSString*)key{
    return [dataDict[key] floatValue];
}

- (double)decodeDoubleForKey:(NSString*)key{
    return [dataDict[key] doubleValue];
}

- (NSString*)decodeStringForKey:(NSString*)key{
    return dataDict[key];
}

-(void) decodeToObject:(id)obj withProperties:(NSArray*)properties{
    for (JDProperty *property in properties) {
        if ([property isReadonly]) {
            continue;
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

- (BOOL)saveToURL:(NSURL *)url error:(NSError **)error{
    NSError *err;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&err];
    return [data writeToURL:url atomically:YES];
}

- (void)loadFromURL:(NSURL *)url error:(NSError **)error{
    NSData *data = [NSData dataWithContentsOfURL:url];
    dataDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
}

- (NSArray*)keysOfCurrentDecodingObject{
    return [dataDict allKeys];
}

@end