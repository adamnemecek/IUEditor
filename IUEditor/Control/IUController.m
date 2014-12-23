//
//  IUTreeController.m
//  IUEditor
//
//  Created by jd on 4/3/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUController.h"
#import "IUSheet.h"
#import "IUImport.h"
#import "IUProject.h"
#import "IUPage.h"

@implementation IUController{
    NSArray     *pasteboard;
    NSInteger   _pasteRepeatCount;
    IUBox       *_lastPastedIU;
}

- (id)init{
    self = [super init];
    if(self){
        [self setObjectClass:[IUBox class]];
        [self setChildrenKeyPath:@"children"];
        [self setLeafKeyPath:@"childrenLeafKey"];
    }
    return self;
}
- (void)dealloc{
    JDSectionInfoLog(IULogDealloc, @"");
}

- (IUProject *)project{
    IUSheet *document = [self.content firstObject];
    return document.project;
}

- (id)selection{
    if ([self.selectedObjects count] == 1) {
        return [[self selectedObjects] objectAtIndex:0];
    }
    return [super selection];
}


-(void)copySelectedIUToPasteboard:(id)sender{
    NSMutableArray *copied = [NSMutableArray array];
    for(IUBox *box in self.selectedObjects){
        if([box canCopy]){
            [copied addObject:box];
        }
    }
    pasteboard = copied;
}

-(void)pasteToSelectedIU:(id)sender{
    IUBox *pasteTarget;
    BOOL pasteTargetIsParent;
    
    if(pasteboard == nil || pasteboard.count ==0 || self.selectedObjects.count < 1){
        //FIXME: current selection이 선택이 없으면 리턴 (IUClass를 새로 만들었을 때 종종 발생함)
        return;
    }
    //copy할 때 현재 select가 된 object 를 저장했다가 paste에서도 똑같으면 parent에 copy
    if ([self.selectedObjects isEqualToArray:pasteboard] || _pasteRepeatCount) {
        //paste to parent
        if (_pasteRepeatCount == 0) {
            pasteTarget = [(IUBox*)[self.selectedObjects firstObject] parent];
        }
        else {
            pasteTarget = _lastPastedIU.parent;
        }
        pasteTargetIsParent = YES;
    }
    
    //copy할때와 paste할때 selection이 달라졌으면 selection 밑에 add
    else {
        //paste to selection
        pasteTarget = [self.selectedObjects firstObject];
        while (1) {
            if (pasteTarget == nil) {
                NSAssert(0, @"pasteTarget");
                return;
            }
            if ([pasteTarget canAddIUByUserInput]) {
                break;
            }
            pasteTarget = pasteTarget.parent;
        }
        pasteTargetIsParent = NO;
    }
    
    if([pasteTarget isMemberOfClass:[IUPage class]]){
        pasteTarget = (IUBox *)((IUPage *)pasteTarget).pageContent;
    }
    
    NSMutableArray *copiedArray = [NSMutableArray array];

    for (IUBox *box in pasteboard) {
        NSError *err;
        IUBox *newBox = [box copy];
        newBox.name = newBox.htmlID;
        
        for (NSNumber *width in newBox.positionManager.allViewPorts) {
            IUPositionStorage *positionStorage;
            if (_pasteRepeatCount){
                positionStorage = (IUPositionStorage *)[_lastPastedIU.positionManager storageForViewPort:[width integerValue]];
            }
            else {
                positionStorage = (IUPositionStorage *)[newBox.positionManager storageForViewPort:[width integerValue]];
            }
            NSNumber *x = positionStorage.x;
            
            if (newBox.canChangeXByUserInput) {
                if (x) {
                    if (pasteTargetIsParent) {
                        NSNumber *newX = [NSNumber numberWithInteger:([x integerValue] + 10)];
                        ((IUPositionStorage *)[newBox.positionManager storageForViewPort:[width integerValue]]).x = newX;
                    }
                    else {
                        ((IUPositionStorage *)[newBox.positionManager storageForViewPort:[width integerValue]]).x = @(10);
                    }
                }
            }
            
            if (newBox.canChangeYByUserInput) {
                NSNumber *y = positionStorage.y;
                if (y) {
                    if (pasteTargetIsParent) {
                        NSNumber *newY = [NSNumber numberWithInteger:([y integerValue] + 10)];
                        ((IUPositionStorage *)[newBox.positionManager storageForViewPort:[width integerValue]]).y = newY;
                    }
                    else {
                        ((IUPositionStorage *)[newBox.positionManager storageForViewPort:[width integerValue]]).y = @(10);
                    }
                }
            }
            
        }
        BOOL result = [pasteTarget addIU:newBox error:&err];
        _lastPastedIU = newBox;
        [copiedArray addObject:newBox];
        [self rearrangeObjects];
        NSAssert(result, @"Add");
        
    }
    [self setSelectedObjects:copiedArray];
    _pasteRepeatCount ++;
}


-(NSArray*)selectedPedigree{
    if ([self.selectedObjects count]==0) {
        return nil;
    }
    
    IUBox *firstObj = [self.selectedObjects objectAtIndex:0];
    NSMutableArray *firstPedigrees = [[[firstObj class] classPedigreeTo:[IUBox class]] mutableCopy];
    NSMutableArray *retArray = [firstPedigrees mutableCopy];
    
    for (NSString *aPedigree in firstPedigrees) {
        for (IUBox *obj in self.selectedObjects) {
            Class class = NSClassFromString(aPedigree);
            if ([obj isKindOfClass:class] == NO) {
                [retArray removeObject:aPedigree];
            }
        }
    }
    
    return retArray;
}

#pragma mark set By LMCanvasVC

- (BOOL)setSelectionIndexPaths:(NSArray *)indexPaths{
    //paste repeat count zero
    _pasteRepeatCount = 0;
    NSDictionary *userInfoDictionary;
    if(self.selectionClassName){
        userInfoDictionary = @{@"selectedObjects": self.selectedObjects, @"selectionClassName":self.selectionClassName};
    }
    else{
        userInfoDictionary = @{@"selectedObjects": self.selectedObjects};
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationSelectionWillChange object:self.project userInfo:userInfoDictionary];


    BOOL result = [super setSelectionIndexPaths:indexPaths];
    
    if(self.selectionClassName){
        userInfoDictionary = @{@"selectedObjects": self.selectedObjects, @"selectionClassName":self.selectionClassName};
    }
    else{
        userInfoDictionary = @{@"selectedObjects": self.selectedObjects};
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationSelectionDidChange object:self.project userInfo:userInfoDictionary];

    return result;
}

- (BOOL)setSelectionIndexPath:(NSIndexPath *)indexPath{
    //paste repeat count zero
    _pasteRepeatCount = 0;
    
    NSDictionary *userInfoDictionary;
    if(self.selectionClassName){
        userInfoDictionary = @{@"selectedObjects": self.selectedObjects, @"selectionClassName":self.selectionClassName};
    }
    else{
        userInfoDictionary = @{@"selectedObjects": self.selectedObjects};
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationSelectionWillChange object:self.project userInfo:userInfoDictionary];
    
    BOOL result = [super setSelectionIndexPath:indexPath];

    
    
    if(self.selectionClassName){
        userInfoDictionary = @{@"selectedObjects": self.selectedObjects, @"selectionClassName":self.selectionClassName};
    }
    else{
        userInfoDictionary = @{@"selectedObjects": self.selectedObjects};
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IUNotificationSelectionDidChange object:self.project userInfo:userInfoDictionary];
    return result;
}


-(void)trySetSelectedObjectsByIdentifiers:(NSArray *)identifiers{
    [JDLogUtil log:IULogAction key:@"canvas selected objects" string:[identifiers description]];
    
    [[self.undoManager prepareWithInvocationTarget:self] trySetSelectedObjectsByIdentifiers:[self selectedIdentifiers]];
    
    IUSheet *document = [self.content firstObject];
    
    NSString *firstIdentifier = [identifiers firstObject];
    if ([firstIdentifier containsString:kIUImportEditorPrefix]) { // it's imported!
        /*
         if one is imported, but other is not, just return
         */

        for (NSString *identifier in identifiers) {
            if ([identifier containsString:kIUImportEditorPrefix] == NO) {
                return;
            }
        }
        
        NSArray *IUChain = [firstIdentifier componentsSeparatedByString:@"_"];
        NSAssert(IUChain.count == 3, @"import in import");
        
        //get import class
        NSString *importIdentifier = [IUChain objectAtIndex:1];
        IUImport *import = [self IUBoxByIdentifier:importIdentifier];
        
        //get all selected IUs
        NSMutableArray *objIdentifiers = [NSMutableArray array];
        for (NSString *identifier in identifiers) {
            [objIdentifiers addObject:[[identifier componentsSeparatedByString:@"_"] objectAtIndex:2]];
        }
        
        NSSet *selectedIUs = [self IUBoxesByIdentifiers:objIdentifiers];
        
        
        //get all index paths of each selected iu

        NSMutableArray *indexPaths = [NSMutableArray array];
        for (IUBox *selectedIU in selectedIUs) {
            [indexPaths addObjectsFromArray:[self indexPathsOfObject:selectedIU]];
        }
        
        NSIndexPath *importPath = [self firstIndexPathOfObject:import];
        NSPredicate *selectIndexPathPredicate = [NSPredicate predicateWithBlock:^BOOL(NSIndexPath *path, NSDictionary *bindings) {
            if ([path containsIndexPath:importPath]) {
                return YES;
            }
            return NO;
        }];
        

        NSArray *selectedPaths = [indexPaths filteredArrayUsingPredicate:selectIndexPathPredicate];
        
        [self setSelectionIndexPaths:selectedPaths];
        
    }
    else {
        NSArray *allChildren = [[document allChildren] arrayByAddingObject:document];
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(IUBox *iu, NSDictionary *bindings) {
            if ([identifiers containsObject:iu.htmlID]) {
                return YES;
            }
            return NO;
        }];
        NSArray *selectedChildren = [allChildren filteredArrayUsingPredicate:predicate];

        //check all selected children share parent;
        //FIXME: is needed?? chidlren 이 다를 때 select이 안됨 why?
        /*
        IUBox *firstSelectedChild = [selectedChildren firstObject];
        for (IUBox *box in selectedChildren) {
            if (box.parent != firstSelectedChild.parent) {
                return; // fail to select
            }
        }
         */
        [self setSelectedObjects:selectedChildren];
    }
}


-(void)setSelectedObjectsByIdentifiers:(NSArray *)identifiers{
    [JDLogUtil log:IULogAction key:@"canvas selected objects" string:[identifiers description]];
    
    [[self.undoManager prepareWithInvocationTarget:self] trySetSelectedObjectsByIdentifiers:[self selectedIdentifiers]];

    
    IUSheet *document = [self.content firstObject];
    NSArray *allChildren = [[document allChildren] arrayByAddingObject:document];
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(IUBox *iu, NSDictionary *bindings) {
        if ([identifiers containsObject:iu.htmlID]) {
            return YES;
        }
        return NO;
    }];
    NSArray *selectedChildren = [allChildren filteredArrayUsingPredicate:predicate];
    [self setSelectedObjects:selectedChildren];
}

-(NSArray*)selectedIdentifiers{
    return [self.selectedObjects valueForKey:@"htmlID"];
}

-(NSArray*)selectedIdentifiersWithImportIdentifier{
    //indexpath chain 중에 iuimport 가 있는지 검사
    IUImport *import = self.importIUInSelectionChain;
    if (import) {
        NSMutableArray *retArray = [NSMutableArray array];
        for(IUBox *iu in self.selectedObjects){
            NSString *currentID = [import modifieldHtmlIDOfChild:iu];
            if(currentID){
                [retArray addObject:currentID];
            }
        }
        return retArray;
    }
    else {
        return [self.selectedObjects valueForKey:@"htmlID"];
    }
}

-(id)IUBoxByIdentifier:(NSString *)identifier inParentIU:(IUBox *)parentIU{
    NSSet *findIUs = [self IUBoxesByIdentifiers:[NSArray arrayWithObject:identifier] inParentIU:parentIU];
    if(findIUs.count == 0){
        JDInfoLog(@"there is no IUID");
        return nil;
    }
    return [findIUs anyObject];

}

-(id)IUBoxByIdentifier:(NSString *)identifier{
    NSSet *findIUs = [self IUBoxesByIdentifiers:[NSArray arrayWithObject:identifier]];
    if(findIUs.count == 0){
        JDInfoLog(@"there is no IUID");
        return nil;
    }
    return [findIUs anyObject];
}

-(id)tryIUBoxByIdentifier:(NSString *)identifier{
    id findIUs = [self IUBoxByIdentifier:identifier];
    if(findIUs){
        return findIUs;
    }
    else if(findIUs == nil && [identifier containsString:kIUImportEditorPrefix]) {
        NSString *importIdentifer = [[identifier componentsSeparatedByString:@"_"] objectAtIndex:1];
        NSString *childIdentifier = [[identifier componentsSeparatedByString:@"_"] objectAtIndex:2];
        id importIU = [self IUBoxByIdentifier:importIdentifer];
        if(importIU){
            id currentIU = [self IUBoxByIdentifier:childIdentifier inParentIU:importIU];
            return currentIU;
        }
    }
    return nil;
}

-(NSSet *)IUBoxesByIdentifiers:(NSArray *)identifiers inParentIU:(IUBox *)parentIU{
    NSArray *allChildren = [[parentIU allChildren] arrayByAddingObject:parentIU];
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(IUBox *iu, NSDictionary *bindings) {
        if ([identifiers containsString:iu.htmlID]) {
            return YES;
        }
        return NO;
    }];
    
    NSArray *filteredChildren = [allChildren filteredArrayUsingPredicate:predicate];
    return [NSSet setWithArray:filteredChildren];
}

-(NSSet *)IUBoxesByIdentifiers:(NSArray *)identifiers{
    IUSheet *document = [self.content firstObject];
    NSArray *allChildren = [[document allChildren] arrayByAddingObject:document];
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(IUBox *iu, NSDictionary *bindings) {
        if ([identifiers containsString:iu.htmlID]) {
            return YES;
        }
        return NO;
    }];

    NSArray *filteredChildren = [allChildren filteredArrayUsingPredicate:predicate];
    return [NSSet setWithArray:filteredChildren];
}


-(IUImport*)importIUInSelectionChain{
    NSIndexPath *firstPath = [[self.selectionIndexPaths firstObject] indexPathByRemovingLastIndex];
    if(firstPath){
        NSArray *chain = [self IUChainOfIndexPath:firstPath];
        
        for (IUBox *box in chain) {
            if ([box isKindOfClass:[IUImport class]]) {
                return (IUImport *)box;
            }
        }
    }
    return nil;
}


-(NSArray*)IUChainOfIndexPath:(NSIndexPath*)path{
    NSMutableArray *retArray = [NSMutableArray array];
    IUBox *currentObj = [[self content] firstObject];
    [retArray addObject:currentObj];
    for (NSUInteger i=1; i<path.length ; i++) {
        NSInteger index = [path indexAtPosition:i];
        currentObj = [currentObj.children objectAtIndex:index];
        [retArray addObject:currentObj];
    }
    return retArray;
}

-(IUBox*)firstDeepestBox{
    IUBox *box = [[self content] firstObject];
    while ([box.children count] > 0) {
        box = [box.children objectAtIndex:0];
    }
    return box;
}

- (BOOL)isSelectionSameClass{
    NSString *className = [[[self selectedObjects] firstObject] className];
    for(IUBox *iu in [self selectedObjects]){
        if([className isEqualToString:[iu className]] ==NO){
            return NO;
        }
    }
    return YES;
}
/**
 @return selection className
 if selected objects are differen class, return iubox
 */
- (NSString *)selectionClassName{

    NSString *className = [[[self selectedObjects] firstObject] className];
    if([self.selectedObjects count] == 1){
        return className;
    }
    else{
        for(IUBox *iu in [self selectedObjects]){
            if([className isEqualToString:[iu className]] ==NO){
                return [IUBox className];
            }
        }
        
        return className;
    }
}

- (NSArray *)allHTMLIDsWithIU:(IUBox *)IU {
    NSMutableArray *retArray = [NSMutableArray array];
    NSArray *indexPaths = [self indexPathsOfObject:IU];
    IUBox *box = [self objectAtIndexPath:[NSIndexPath indexPathWithIndex:0]];
    for (NSIndexPath *path in indexPaths) {
        [retArray addObject:[self htmlIDForIU:box withIndexPath:path]];
    }
    return retArray;
}

- (NSString *)htmlIDForIU:(IUBox *)box withIndexPath:(NSIndexPath *)path {
    NSMutableString *str;
    for (int i=0; i<path.length; i++) {
        NSUInteger index = [path indexAtPosition:i];
        box = [[box children] objectAtIndex:index];
        if ([box isKindOfClass:[IUImport class]]) {
            [str appendString:[box.htmlID stringByAppendingString:@"_I_"]];
        }
    }
    return str;
    
}

- (void)removeSelectedObjects{
    NSMutableArray *alternatedSelection = [NSMutableArray array];
    NSArray *removeIUs = [self selectedObjects];
    
    for(IUBox *box in removeIUs){
        //selected objects can contain removed object
        if([alternatedSelection containsObject:box.htmlID]){
            [alternatedSelection removeObject:box.htmlID];
        }
        
        //add parent or not to be removed objects add to alternated selection
        if([box canRemoveIUByUserInput]){
            [alternatedSelection addObject:box.parent.htmlID];
            [box.parent removeIU:box];
        }
        else{
            [alternatedSelection addObject:box.htmlID];
        }
    }
    
    [self setSelectedObjectsByIdentifiers:alternatedSelection];
}
@end
