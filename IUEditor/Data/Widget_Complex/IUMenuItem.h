//
//  IUMenuBarItem.h
//  IUEditor
//
//  Created by seungmi on 2014. 7. 31..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUItem.h"

@interface IUMenuItem : IUItem

@property (nonatomic) NSColor *bgActive, *fontActive;

- (NSInteger)count;
- (void)setCount:(NSInteger)count;

- (NSInteger)depth;
- (BOOL)hasItemChildren;

- (NSString *)itemIdentifier;
- (NSString *)hoverItemIdentifier;
- (NSString *)activeItemIdentifier;
- (NSString *)editorDisplayIdentifier;

//editor mode- display
@property BOOL isOpened;
@property (nonatomic) NSString *text;


@end
