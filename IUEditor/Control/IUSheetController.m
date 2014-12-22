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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sheetSelectionChange:) name:IUNotificationSheetSelectionWillChange object:self.project];
    }
    return self;
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    JDSectionInfoLog(IULogDealloc, @"");

}

- (void)sheetSelectionChange:(NSNotification *)notification{
    id controller = notification.object;
    if([self isNotEqualTo:controller]){
        [self setSelectedObject:[[self content] firstObject]];
    }
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
    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationSheetStructureDidChange object:self.project];
}

- (void)addObject:(id <IUFileItemProtocol>)object{
    id <IUFileItemProtocol> currentSelection = [self.selectedObjects firstObject];
    if([currentSelection isKindOfClass:[IUSheetGroup class]]){
        [currentSelection addFileItem:object];
    }
    else{
        [currentSelection.parentFileItem addFileItem:object];
    }
}

- (void)removeSelectedObjects{
    NSMutableArray *alternatedSelection = [NSMutableArray array];
    NSArray *removeSheets = [self selectedObjects];
    
    for(id <IUFileItemProtocol>sheet in removeSheets){
        //selected objects can contain removed object
        if([alternatedSelection containsObject:sheet]){
            [alternatedSelection removeObject:sheet];
        }
        
        //add parent to alternated selection
        [alternatedSelection addObject:sheet.parentFileItem];
        [sheet.parentFileItem removeFileItem:sheet];

    }
    [self setSelectedObjects:[alternatedSelection copy]];
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
    BOOL isSendNotification = NO;
    if([[self objectAtIndexPath:indexPath] isKindOfClass:[IUSheet class]]){
        isSendNotification = YES;
    }
    if(isSendNotification){
        [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationSheetSelectionWillChange object:self.project userInfo:@{kIUNotificationSheetSelection: [self.selectedObjects firstObject]}];
    }
    
    NSIndexPath *currentIndexPath = [self selectionIndexPath];
    if(currentIndexPath){
        [(IUSheetController *)[self.undoManager prepareWithInvocationTarget:self] setSelectionIndexPath:currentIndexPath];
    }
    BOOL result = [super setSelectionIndexPaths:@[indexPath]];

    if(isSendNotification){
        [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationSheetSelectionDidChange object:self.project userInfo:@{kIUNotificationSheetSelection: [self.selectedObjects firstObject]}];
    }

    return result;
}


#pragma mark - Undo Manager
- (NSUndoManager *)undoManager{
    return [[[[NSApp mainWindow] windowController] document] undoManager];
}



@end
