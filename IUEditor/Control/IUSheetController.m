//
//  IUSheetController.h
//  IUEditor
//
//  Created by JD on 3/17/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUSheetController.h"

@implementation IUSheetController

-(id)initWithSheet:(IUSheet*)sheet{
    NSAssert(sheet!=nil, @"document is nil");
    self = [super init];
    if (self) {
        [self setChildrenKeyPath:@"children"];
        [self setObjectClass:[IUBox class]];
        [self setContent:sheet];
    }
    return self;
}

-(IUSheet*)sheet{
    NSAssert(self.content != nil, @"content is nil");
    return [self.content objectAtIndex:0];
}

-(IUProject*)project{
    return [self.content firstObject];
}


-(void)setContent:(id)content{
    [self willChangeValueForKey:@"sheet"];
    [self willChangeValueForKey:@"project"];
    [super setContent:content];
    [self didChangeValueForKey:@"project"];
    [self didChangeValueForKey:@"sheet"];
}

- (void)dealloc{
    [JDLogUtil log:IULogDealloc string:@"IUSheetController"];
    for (IUSheet *sheet in self.project.allSheets) {
        [sheet disconnectWithEditor];
    }
}
- (BOOL)setSelectionIndexPaths:(NSArray *)indexPaths{
    
    return [self setUndoSelectionIndexPath:indexPaths[0]];
}

- (BOOL)setUndoSelectionIndexPath:(NSIndexPath *)indexPath{
    NSIndexPath *currentIndexPath = [self selectionIndexPath];
    if(currentIndexPath){
        [[self.undoManager prepareWithInvocationTarget:self] setUndoSelectionIndexPath:currentIndexPath];
    }
    return [super setSelectionIndexPaths:@[indexPath]];
}

#pragma mark - Undo Manager
- (NSUndoManager *)undoManager{
    return [[[[NSApp mainWindow] windowController] document] undoManager];
}



@end
