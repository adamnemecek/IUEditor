//
//  BBPageStructureVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 4..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBPageStructureVC.h"

#import "IUBoxes.h"

@interface BBPageStructureVC ()

@property (weak) IBOutlet NSOutlineView *iuOutlineView;

@end

@implementation BBPageStructureVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_iuOutlineView bind:NSContentBinding toObject:self.iuController withKeyPath:@"arrangedObjects" options:IUBindingDictNotRaisesApplicable];
    [_iuOutlineView bind:NSSelectionIndexPathsBinding toObject:self.iuController withKeyPath:@"selectionIndexPaths" options:IUBindingDictNotRaisesApplicable];
    
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

@end
