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

- (BOOL)isFileItemGroup{
    return YES;
}

- (id)copyWithZone:(NSZone *)zone{
    IUSheetGroup *group = [[IUSheetGroup allocWithZone:zone] init];
    for (IUSheet *sheet in self.childrenFiles) {
        [group addFileItem:sheet];
    }
    group.name = self.name;
    return group;
}


-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [self init];
    
    [aDecoder decodeToObject:self withProperties:[IUSheetGroup properties]];
    //TODO: load project
    
    return self;
}

-(id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [self init];
    
    [aDecoder decodeToObject:self withProperties:[IUSheetGroup strongProperties]];
    //TODO: load project
    
    return self;
}

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder{
    self = [super awakeAfterUsingCoder:aDecoder];
    _children = [[aDecoder decodeObjectForKey:@"_children"] mutableCopy];    
    return self;
}


-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeFromObject:self withProperties:[IUSheetGroup properties]];
    [aCoder encodeObject:_children forKey:@"_children"];
}

-(void)encodeWithJDCoder:(JDCoder *)aCoder{
    [self encodeWithCoder:(NSCoder*)aCoder];
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

- (NSArray*)childrenFiles{
    return _children;
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
