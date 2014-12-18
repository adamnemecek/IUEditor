//
//  BBPageNavigationVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 4..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBPageNavigationVC.h"
#import "BBPagePreferenceWC.h"


@interface BBPageNavigationVC ()

@property (weak) IBOutlet NSOutlineView *pagesOutlineView;

@end

@implementation BBPageNavigationVC{
    BBPagePreferenceWC *_pagePreferenceWC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_pagesOutlineView bind:NSContentBinding toObject:self.pageController withKeyPath:@"arrangedObjects" options:IUBindingDictNotRaisesApplicable];
    [_pagesOutlineView bind:NSSelectionIndexPathsBinding toObject:self.pageController withKeyPath:@"selectionIndexPaths" options:IUBindingDictNotRaisesApplicable];

}


- (void)dealloc{
    JDSectionInfoLog(IULogDealloc, @"");
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

- (IBAction)clickNewPageButton:(id)sender {
}
- (IBAction)clickNewPageGroupButton:(id)sender {
    
    if(self.pageController.selectedObjects.count > 0){
        IUSheetGroup *newSheetGroup = [[IUSheetGroup alloc] init];
        newSheetGroup.name = @"Group";
        [self.pageController addObject:newSheetGroup];
    }
}
- (IBAction)clickPageSettingButtonForPage:(IUPage *)page{
    if(_pagePreferenceWC == nil){
        _pagePreferenceWC = [[BBPagePreferenceWC alloc] initWithWindowNibName:[BBPagePreferenceWC className]];
    }
    _pagePreferenceWC.currentPage = page;
//    [[NSApp mainWindow] beginSheet:_pagePreferenceWC.window completionHandler:^(NSModalResponse returnCode){}];
    [self.view.window beginSheet:_pagePreferenceWC.window completionHandler:^(NSModalResponse returnCode){}];
}


@end
