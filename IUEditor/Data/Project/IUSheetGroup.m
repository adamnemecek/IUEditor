//
//  IUSheetGroup.m
//  IUEditor
//
//  Created by JD on 3/26/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUSheetGroup.h"
#import "IUSheet.h"
#import "IUProject.h"

@implementation IUSheetGroup{
    NSMutableArray *_children;
}

- (id)init{
    self = [super init];
    _children = [NSMutableArray array];
    return self;
}

- (BOOL)isLeaf{
    return NO;
}

- (id)copyWithZone:(NSZone *)zone{
    IUSheetGroup *group = [[IUSheetGroup allocWithZone:zone] init];
    for (IUSheet *sheet in self.childrenFileItems) {
        [group addFileItem:sheet];
    }
    group.name = self.name;
    return group;
}

-(id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [super initWithJDCoder:aDecoder];
    if(self){
        [self.undoManager disableUndoRegistration];
        [aDecoder decodeToObject:self withProperties:[IUSheetGroup properties]];
        _children = [[aDecoder decodeObjectForKey:@"_children"] mutableCopy];
        
        [self.undoManager enableUndoRegistration];
    }
    return self;
}


-(void)encodeWithJDCoder:(JDCoder *)aCoder{
    [super encodeWithJDCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[IUSheetGroup properties]];
    [aCoder encodeObject:_children forKey:@"_children"];
}

#pragma mark - Undo Manager

- (NSUndoManager *)undoManagers{
    if (_undoManager == nil) {
        return [[[[NSApp mainWindow] windowController] document] undoManager];
    }
    return _undoManager;
}

#pragma mark - manage sheet

- (void)setChildren:(NSArray*)children{
    _children = [children mutableCopy];
}

- (NSArray*)childrenFileItems{
    return _children;
}

- (NSArray*)allChildrenFileItems{
    NSMutableArray *childrenFileItems = [NSMutableArray array];
    [childrenFileItems addObjectsFromArray:_children];
    for(id<IUFileItemProtocol> child in _children){
        if(child.isLeaf == NO){
            [childrenFileItems addObjectsFromArray:[child childrenFileItems]];
        }
    }
    return [childrenFileItems copy];
}

- (void)addFileItem:(id<IUFileItemProtocol>)fileItem{
    fileItem.parentFileItem = self;
    [_children addObject:fileItem];
}

- (void)removeFileItem:(id<IUFileItemProtocol>)fileItem{
    NSAssert([_children containsObject:fileItem], @"");
    fileItem.parentFileItem = nil;
    [_children removeObject:fileItem];
}

- (void)changeIndex:(IUSheet *)sheet toIndex:(NSUInteger)newIndex{
    [_children removeObject:sheet];
    [_children insertObject:sheet atIndex:newIndex];
}

- (id)sheetWithHtmlID:(NSString *)identifier{
    for(IUBox *child in _children){
        if([child.htmlID isEqualToString:identifier]){
            return child;
        }
    }
    return nil;
}
@end
