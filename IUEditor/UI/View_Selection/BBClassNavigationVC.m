//
//  BBClassNavigationVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 4..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBClassNavigationVC.h"

#import "IUDocumentProtocol.h"
#import "IUIdentifierManager.h"
#import "IUClass.h"

@interface BBClassNavigationVC ()

@property (weak) IBOutlet NSOutlineView *classOutlineView;

@end

@implementation BBClassNavigationVC


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_classOutlineView bind:NSContentBinding toObject:self.classController withKeyPath:@"arrangedObjects" options:IUBindingDictNotRaisesApplicable];
    [_classOutlineView bind:NSSelectionIndexPathsBinding toObject:self.classController withKeyPath:@"selectionIndexPaths" options:IUBindingDictNotRaisesApplicable];
    
}

- (void)dealloc{
    JDSectionInfoLog(IULogDealloc, @"");
}


#pragma mark - outline view delegate

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(NSTreeNode*)item {
    NSString *cellIentifier;
    if([item.representedObject performSelector:@selector(isLeaf)]){
        cellIentifier = @"classLeaf";
    }
    else{
        cellIentifier = @"classGroup";
    }
    id cellView = [outlineView makeViewWithIdentifier:cellIentifier owner:self];
    return cellView;
}

#pragma mark - manage buttons

- (IBAction)clickNewCompositionButton:(id)sender {
    if(self.classController.selectedObjects.count > 0){
        IUClass *newClass = [[IUClass alloc] initWithPreset];
        [self.classController addObject:newClass];

    }
}
- (IBAction)clickNewCompositionGroupButton:(id)sender {
    
    if(self.classController.selectedObjects.count > 0){
        IUSheetGroup *newSheetGroup = [[IUSheetGroup alloc] init];
        newSheetGroup.name = @"Group";
        
        [self.classController addObject:newSheetGroup];
        
    }
}

- (IBAction)clickTrashButton:(id)sender{
    [self.classController removeSelectedObjects];
}

@end
