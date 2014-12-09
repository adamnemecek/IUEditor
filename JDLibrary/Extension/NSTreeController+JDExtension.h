//
//  NSTreeController+JDExtension.h
//  IUEditor
//
//  Created by JD on 3/29/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSTreeController (JDExtension)

- (NSIndexPath*)firstIndexPathOfObject:(id)anObject;
- (NSArray*)indexPathsOfObject:(id)anObject;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

- (void)setSelectedObject:(id)object;
- (void)setSelectedObjects:(NSArray*)objects;

@end
