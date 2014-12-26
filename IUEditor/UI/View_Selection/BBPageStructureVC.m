//
//  BBPageStructureVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 4..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBPageStructureVC.h"

#import "IUDocumentProtocol.h"

#import "IUBoxes.h"
#import "IUIdentifierManager.h"


/**
 BBSectionPopover manage section property
 */
@interface BBSectionPopover : NSPopover

@property (weak) IUSection *currentSection;
@property (weak) IBOutlet NSButton *fullscreenButton;

@end

@implementation BBSectionPopover

- (id)init{
    self = [super init];
    if(self){
        [_fullscreenButton bind:NSValueBinding toObject:self withKeyPath:@"currentSection.heightAsWindowHeight" options:IUBindingDictNotRaisesApplicable];

    }
    return self;
}

@end

/**
 BBButtonTableCellView is subclass of NSTableCellView.
 BBButtonTableCellView knows its clickButton
 */
@interface BBButtonTableCellView : NSTableCellView
@property (weak) IBOutlet NSButton *clickButton;
@end

@implementation BBButtonTableCellView

@end

/* outline view key */
NSString *const kIUPageStrucutureMoveKey = @"kIUPageStrucutureMoveKey";

@interface BBPageStructureVC ()

@property (weak) IBOutlet NSOutlineView *iuOutlineView;
@property (weak) IBOutlet NSButton *sectionButton;
@property (strong) IBOutlet BBSectionPopover *sectionPopover;

@end

@implementation BBPageStructureVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_iuOutlineView registerForDraggedTypes:@[kUTTypeIUData]];
    
    [_iuOutlineView bind:NSContentBinding toObject:self.iuController withKeyPath:@"arrangedObjects" options:IUBindingDictNotRaisesApplicable];
    [_iuOutlineView bind:NSSelectionIndexPathsBinding toObject:self.iuController withKeyPath:@"selectionIndexPaths" options:IUBindingDictNotRaisesApplicable];
    //add observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSheetSelection:) name:IUNotificationSheetSelectionDidChange object:self.iuController.project];

    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    JDSectionInfoLog(IULogDealloc, @"");
}


#pragma mark - outline view delegate

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(NSTreeNode*)item {
    NSString *cellIentifier;
    if([item.representedObject isKindOfClass:[IUSection class]]){
        cellIentifier = @"settingIUCell";
    }
    else{
        cellIentifier = @"defaultIUCell";
    }
    id cellView = [outlineView makeViewWithIdentifier:cellIentifier owner:self];
    return cellView;
}

#pragma mark - view setting

/**
 sectionButton should be enabled by IUPage class
 */
- (void)changeSheetSelection:(NSNotification *)notification{
    
    id selectedObject = [notification.userInfo objectForKey:kIUNotificationSheetSelection];
    if ([selectedObject isKindOfClass:[IUClass class]] ){
        [_sectionButton setEnabled:NO];
    }
    else{
        [_sectionButton setEnabled:YES];
    }
    
}

- (IBAction)clickAddSectionButton:(id)sender {
    if([[_iuController.content firstObject] isKindOfClass:[IUPage class]]){
        //allocation new section
        IUSection *newSection = [[IUSection alloc] initWithPreset];
        
        //add section to pageContent
        IUPage *currentPage = [_iuController.content firstObject];
        [currentPage.pageContent addIU:newSection error:nil];
        
        //reload controller
        [self.iuController setSelectedObject:newSection];
    }
}

- (IBAction)clickSectionSettingButton:(id)sender forSection:(IUSection *)section{
    //현재 selection과 같으면 popover를 닫고 return
    if([_sectionPopover isShown] ){
        [_sectionPopover close];
        if([section isEqualTo:_sectionPopover.currentSection]){
            return;
        }
    }
    
    _sectionPopover.currentSection = section;
    [_sectionPopover showRelativeToRect:[sender frame] ofView:sender preferredEdge:NSMinYEdge];
    
}
- (IBAction)clickSectionPopoverCloseButton:(id)sender {
    [_sectionPopover close];
}

- (IBAction)clickTrashButton:(id)sender{
    [self.iuController removeSelectedObjects];
}

#pragma mark - drag & drop 

- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard{
    
    NSMutableArray *copyBoxes = [NSMutableArray array];
    
    for (NSTreeNode *node in items){
        IUBox *iu = [node representedObject];
        if([iu canMoveToOtherParent]){
            [copyBoxes addObject:iu];
        }
    }
    if(copyBoxes.count > 0){
        [pasteboard writeObjects:[copyBoxes copy]];
        return YES;
    }
    else{
        return NO;
    }
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id<NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index{
    IUBox *parent = [item representedObject];
    if([parent canAddIUByUserInput]){
        return NSDragOperationMove;
    }
    
    return NSDragOperationNone;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id<NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index{
    NSPasteboard *pBoard = [info draggingPasteboard];
    BOOL isReadable = [pBoard canReadObjectForClasses:@[[IUBox class]] options:nil];
    if(isReadable){
        NSMutableArray *movedArray = [NSMutableArray array];
        IUBox *parent = [item representedObject];
        //자신의 window내에서 움직임.
        if([outlineView isEqualTo:[info draggingSource]]){
            //identifier를 가져와 현재 select된 iu를 찾는다.
            NSArray *identifierArray = [pBoard readObjectsForClasses:@[[NSString class]] options:nil];
            for(NSString *identifier in identifierArray){
                IUBox *iu = [self.iuController IUBoxByIdentifier:identifier];
                if([iu.allChildren containsObject:parent] == NO){
                    [iu.parent removeIU:iu];
                    [movedArray addObject:iu];
                }
            }
        }
        //다른 윈도우에서 넘어옴.
        else{
            NSArray *copiedArray = [pBoard readObjectsForClasses:@[[IUBox class]] options:nil];
            for(IUBox *iu in copiedArray){
                if([iu.allChildren containsObject:iu] == NO){
                    [movedArray addObject:iu];
                }
            }
        }
        
        //옮겨진 윈도우를 새로 옮김
        for(IUBox *iu in movedArray){
            if(index > parent.children.count){
                [parent addIU:iu error:nil];
            }
            else{
                [parent insertIU:iu atIndex:index error:nil];
            }
        }
        
        return YES;

    }

    return NO;
}

@end
