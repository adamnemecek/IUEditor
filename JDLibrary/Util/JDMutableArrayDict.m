//
//  JDArrayDict.m
//  Mango
//
//  Created by JD on 13. 3. 20..
/// Copyright (c) 2004-2013, JDLab  / Yang Joodong
/// All rights reserved. Licensed under the GPL.
/// See the GNU General Public License for more details. (/LICENSE)

//

#import "JDMutableArrayDict.h"

@implementation JDMutableArrayDict {
    NSArray *allKey_cache; // cache of allKeys
}

@synthesize dict;
@synthesize array;

- (id)init{
	if (self=[super init]) {
		dict=[[NSMutableDictionary alloc]init];
		array=[[NSMutableArray	alloc]init];
	}
	return self;
}


//NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)aCoder{
	[aCoder encodeObject:dict forKey:@"dict"];
	[aCoder encodeObject:array forKey:@"array"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
	if (self=[super init]) {
		self.dict=[[aDecoder decodeObjectForKey:@"dict"] mutableCopy];
		self.array=[[aDecoder decodeObjectForKey:@"array"] mutableCopy];
	}
	return self;
}

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    //encode array
    [aCoder encodeObject:array forKey:@"array"];
    
    //encode key for each array object
    NSMutableArray *arr = [NSMutableArray array];
    for (id obj in array) {
        id key = [[dict allKeysForObject:obj] firstObject];
        [arr addObject:key];
    }

    [aCoder encodeObject:arr forKey:@"keys"];
}

- (id)initWithJDCoder:(JDCoder *)decoder{
    self = [super init];
    if (self) {
        //encode array
        self.array = [decoder decodeObjectForKey:@"array"];
        dict = [NSMutableDictionary dictionary];
        NSArray *keys = [decoder decodeObjectForKey:@"keys"];
        
        for (NSInteger i=0; i<array.count; i++) {
            [dict setObject:self.array[i] forKey:keys[i]];
        }
    }
    return self;
}


- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len{
	return [array countByEnumeratingWithState:state objects:buffer count:len];
}

- (id)objectAtIndex:(NSUInteger)index{
	return [array objectAtIndex:index];
}

- (id)objectForKey:(id)aKey{
	return [dict objectForKey:aKey];
}

- (void)setObject:(id)obj forKey:(id)key{
    [self willChangeValueForKey:@"dict"];
    [self willChangeValueForKey:@"array"];
	[dict setObject:obj forKey:key];
//    [[self mutableArrayValueForKey:@"array"] addObject:obj];
	[array addObject:obj];
    allKey_cache = nil;
    [self didChangeValueForKey:@"dict"];
    [self didChangeValueForKey:@"array"];
}

- (void)insertObject:(id)anObject forKey:(id)key atIndex:(NSUInteger)index{
    [self willChangeValueForKey:@"dict"];
    [self willChangeValueForKey:@"array"];
	[dict setObject:anObject forKey:key];
	[array insertObject:anObject atIndex:index];
    allKey_cache = nil;
    [self didChangeValueForKey:@"dict"];
    [self didChangeValueForKey:@"array"];
}

- (NSArray*)allKeys {
    if (allKey_cache) {
        return allKey_cache;
    }
    NSMutableArray *retArr = [NSMutableArray array];
    for (id item in self.array) {
        id key = [[self.dict allKeysForObject:item] firstObject];
        [retArr addObject:key];
    }
    allKey_cache = [retArr copy];
    return allKey_cache;
}


- (NSUInteger)indexOfObject:(id)anObject{
	return [array indexOfObject:anObject];
}

- (NSUInteger)count{
	return [array count];
}

- (id)firstKeyForObject:(id)object{
    return [[dict allKeysForObject:object] firstObject];
}


- (void)removeObjectForKey:(id)key{
    id obj = [dict objectForKey:key];
    [self willChangeValueForKey:@"dict"];
    [self willChangeValueForKey:@"array"];
    [dict removeObjectForKey:key];
    [array removeObject:obj];
    [self didChangeValueForKey:@"dict"];
    [self didChangeValueForKey:@"array"];
}

-(void)removeAllObjects{
    [self willChangeValueForKey:@"dict"];
    [self willChangeValueForKey:@"array"];
    [dict removeAllObjects];
    [array removeAllObjects];
    [self didChangeValueForKey:@"dict"];
    [self didChangeValueForKey:@"array"];
}

- (void)sortArrayWithDictKey{
    //sort all array with dictionary key
    NSArray *keys = [dict allKeys];
    NSArray *sortedKeys = [keys sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *arr = [NSMutableArray array];
    for (id key in sortedKeys) {
        [arr addObject:[dict objectForKey:key]];
    }
    self.array = arr;
}

- (void)reverseSortArrayWithDictKey{
    //sort all array with dictionary key
    NSArray *keys = [dict allKeys];
    NSArray *sortedKeys = [[keys sortedArrayUsingSelector:@selector(compare:)] reversedArray];
    NSMutableArray *arr = [NSMutableArray array];
    for (id key in sortedKeys) {
        [arr addObject:[dict objectForKey:key]];
    }
    self.array = arr;
}


@end