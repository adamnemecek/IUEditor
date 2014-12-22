//
//  BBBottomToolBarVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 19..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBBottomToolBarVC.h"

#import "IUPage.h"
#import "IUClass.h"

@interface BBBottomToolBarVC ()

@property (weak) IBOutlet NSComboBox *zoomComboBox;
@property (strong) IBOutlet NSArrayController *openedSheetController;
@property (weak) IBOutlet NSCollectionView *fileItemCollectionView;
@property (weak) IBOutlet NSPopUpButton *showFilesButton;

@end

static NSString *const kIUFileTabItem = @"kIUFileTabItem";

@implementation BBBottomToolBarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_fileItemCollectionView registerForDraggedTypes:@[kIUFileTabItem]];
    
    [_zoomComboBox addItemsWithObjectValues:@[@(200), @(180), @(150), @(120), @(100), @(80), @(60), @(40)]];
    [_zoomComboBox bind:NSValueBinding toObject:[NSUserDefaults standardUserDefaults] withKeyPath:@"zoom" options:IUBindingDictNotRaisesApplicableAndContinuousUpdate];
    
    
    //add observing
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sheetChanged:) name:IUNotificationSheetSelectionDidChange object:self.view.window];
    [self.openedSheetController addObserver:self forKeyPath:@"selectedObjects" options:NSKeyValueObservingOptionNew context:@"sheetControllerChange"];
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.openedSheetController removeObserver:self forKeyPath:@"selectedObjects"];
}

- (BOOL)control:(NSControl *)control didFailToFormatString:(NSString *)string errorDescription:(NSString *)error{
    
    if([control isEqualTo:_zoomComboBox]){
        NSString *digit = [string stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
        if(digit){
            [control setStringValue:digit];
        }
    }
    
    return YES;
}
- (void)sheetControllerChangeContextDidChange:(NSDictionary *)change{
    IUSheet *sheet = [[self.openedSheetController selectedObjects] firstObject];
    if([sheet isKindOfClass:[IUPage class]]){
        [self.pageController setSelectedObject:sheet];
    }
    else if([sheet isKindOfClass:[IUClass class]]){
        [self.classController setSelectedObject:sheet];
    }
}

- (void)sheetChanged:(NSNotification *)notification{
    id <IUFileItemProtocol>selectedObject = [notification.userInfo objectForKey:@"selectedObject"];
    if([selectedObject isKindOfClass:[IUSheet class]]){
        if([[self.openedSheetController arrangedObjects] containsObject:selectedObject] == NO){
            [self.openedSheetController addObject:selectedObject];
        }
    }
    
}
- (IBAction)clickShowFilesButton:(id)sender{
    
    //find and select file
    NSString *fileName = [[sender selectedCell] title];
    IUSheet *sheet = [[IUIdentifierManager managerForMainWindow] objectForIdentifier:fileName];
    [self.openedSheetController setSelectedObjects:@[sheet]];
    
    //move scroll to selected file
    NSRect selectionRect = [self.fileItemCollectionView frameForItemAtIndex:[[self.fileItemCollectionView selectionIndexes] firstIndex]];
    [self.fileItemCollectionView scrollRectToVisible:selectionRect];
}


- (IBAction)clickCloseButtonForOpenFileItem:(id <IUFileItemProtocol>)fileItem{
    //opened file이 하나 일때는 닫지 않는다.
    if([[self.openedSheetController arrangedObjects] count]<= 1){
        return;
    }
    
    [self.openedSheetController removeObject:fileItem];
    
}

#pragma mark - collection view drag

- (BOOL)collectionView:(NSCollectionView *)collectionView writeItemsAtIndexes:(NSIndexSet *)indexes toPasteboard:(NSPasteboard *)pasteboard{
    id <IUFileItemProtocol>selectedObject = [[collectionView itemAtIndex:[indexes firstIndex]] representedObject];
    [pasteboard setString:selectedObject.name forType:kIUFileTabItem];
    return YES;
}

- (BOOL)collectionView:(NSCollectionView *)collectionView canDragItemsAtIndexes:(NSIndexSet *)indexes withEvent:(NSEvent *)event{
    return YES;
}


- (BOOL)collectionView:(NSCollectionView *)collectionView acceptDrop:(id <NSDraggingInfo>)draggingInfo index:(NSInteger)index dropOperation:(NSCollectionViewDropOperation)dropOperation{
    NSPasteboard *pBoard = draggingInfo.draggingPasteboard;
    if([[pBoard types] containsObject:kIUFileTabItem]){
        NSString *fileName = [pBoard stringForType:kIUFileTabItem];
        IUSheet *sheet = [[IUIdentifierManager managerForMainWindow] objectForIdentifier:fileName];
        if(sheet){
            [_openedSheetController removeObject:sheet];
            if(index > [_openedSheetController.arrangedObjects count]){
                [_openedSheetController addObject:sheet];
            }
            else{
                [_openedSheetController insertObject:sheet atArrangedObjectIndex:index];
            }
            
            return YES;
        }
    }
    return NO;
}

- (NSDragOperation)collectionView:(NSCollectionView *)collectionView validateDrop:(id<NSDraggingInfo>)draggingInfo proposedIndex:(NSInteger *)proposedDropIndex dropOperation:(NSCollectionViewDropOperation *)proposedDropOperation{
    
    NSPasteboard *pBoard = draggingInfo.draggingPasteboard;
    if([[pBoard types] containsObject:kIUFileTabItem]){

        return NSDragOperationMove;
    }
    return NSDragOperationNone;
}

@end
