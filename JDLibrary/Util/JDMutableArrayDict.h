//
//  JDArrayDict.h
//  Mango
//
/// Copyright (c) 2004-2012, JDLab  / Yang Joodong
/// All rights reserved. Licensed under the GPL.
/// See the GNU General Public License for more details. (/LICENSE)


#import <Foundation/Foundation.h>
#import "JDCoder.h"

/**
 JDMutableArrayDict
 Associative array for Objective-C
 
 @note: Each item can be inserted at only once.
    Duplicated key for one item is not allowed.
 
 */

@interface JDMutableArrayDict : NSObject <NSCoding, JDCoding>{
	NSMutableDictionary* dict;
	NSMutableArray* array;
}


@property (nonatomic, retain) NSDictionary* dict;
@property (nonatomic, retain) NSArray* array;


- (id)objectAtIndex:(NSUInteger)index;
- (id)objectForKey:(id)aKey;
- (id)firstKeyForObject:(id)object;

- (void)setObject:(id)obj forKey:(id)key;
- (void)insertObject:(id)anObject forKey:(id)key atIndex:(NSUInteger)index;

- (void)removeObjectForKey:(id)key;
- (void)removeAllObjects;
- (NSUInteger)indexOfObject:(id)anObject;

- (NSUInteger)count;

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len;

- (void)sortArrayWithDictKey;
- (void)reverseSortArrayWithDictKey;

@end
