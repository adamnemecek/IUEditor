//
//  BBPageNavigationVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 4..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBPageNavigationVC.h"

@interface BBPageNavigationVC ()

@property (weak) IBOutlet NSOutlineView *pagesOutlineView;

@end

@implementation BBPageNavigationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_pagesOutlineView bind:NSContentBinding toObject:self.pageController withKeyPath:@"arrangedObjects" options:IUBindingDictNotRaisesApplicable];
    [_pagesOutlineView bind:NSSelectionIndexPathsBinding toObject:self.pageController withKeyPath:@"selectionIndexPaths" options:IUBindingDictNotRaisesApplicable];

}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(NSTreeNode*)item {
    NSString *cellIentifier;
    if([item.representedObject performSelector:@selector(isLeaf)]){
        cellIentifier = @"pageLeaf";
    }
    else{
        cellIentifier = @"pageGroup";
    }
    id cellView = [outlineView makeViewWithIdentifier:cellIentifier owner:self];
    return cellView;
}

@end
