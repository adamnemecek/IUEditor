//
//  IUSheetController.h
//  IUEditor
//
//  Created by JD on 3/17/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUSheetController.h"

@implementation IUSheetController

- (id)initWithSheetGroup:(IUSheetGroup *)sheetGroup{
    self = [super init];
    if(self){
        [self setChildrenKeyPath:@"childrenFileItems"];
        [self setLeafKeyPath:@"isLeaf"];
        [self setContent:sheetGroup];
        [self setObjectClass:[NSObject class]];
        
    }
    return self;
}

- (BOOL)canAddChild{
    return NO;
}

- (BOOL)canInsertChild{
    return NO;
}

-(IUProject*)project{
    return ((IUSheetGroup *)[self.content firstObject]).project;
}

- (IUSheet *)firstSheet{
    return (IUSheet *)[((IUSheetGroup *)[self.content firstObject]).childrenFileItems firstObject];
}

-(void)setContent:(id)content{
    [super setContent:content];
    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationSheetStructureDidChange object:nil];
}


- (BOOL)setSelectionIndexPaths:(NSArray *)indexPaths{
    
    BOOL result = YES;
    [self.undoManager beginUndoGrouping];
    
    for(NSIndexPath *aIndexPath in indexPaths){
        BOOL partialResult  = [self setSelectionIndexPath:aIndexPath];
        if(partialResult == NO){
            result = NO;
        }
    }
    
    [self.undoManager endUndoGrouping];
    return result;
}

- (BOOL)setSelectionIndexPath:(NSIndexPath *)indexPath{
    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationSheetSelectionWillChange object:self userInfo:@{@"selectedObject": [self.selectedObjects firstObject]}];
    
    NSIndexPath *currentIndexPath = [self selectionIndexPath];
    if(currentIndexPath){
        [(IUSheetController *)[self.undoManager prepareWithInvocationTarget:self] setSelectionIndexPath:currentIndexPath];
    }
    BOOL result = [super setSelectionIndexPaths:@[indexPath]];

    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationSheetSelectionDidChange object:self userInfo:@{@"selectedObject": [self.selectedObjects firstObject]}];

    return result;
}


#pragma mark - Undo Manager
- (NSUndoManager *)undoManager{
    return [[[[NSApp mainWindow] windowController] document] undoManager];
}



@end
