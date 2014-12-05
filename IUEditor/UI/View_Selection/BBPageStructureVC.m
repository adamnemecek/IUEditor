//
//  BBPageStructureVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 4..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBPageStructureVC.h"

#import "IUBoxes.h"
#import "IUIdentifierManager.h"

@interface BBPageStructureVC ()

@property (weak) IBOutlet NSOutlineView *iuOutlineView;
@property (weak) IBOutlet NSButton *sectionButton;

@end

@implementation BBPageStructureVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_iuOutlineView bind:NSContentBinding toObject:self.iuController withKeyPath:@"arrangedObjects" options:IUBindingDictNotRaisesApplicable];
    [_iuOutlineView bind:NSSelectionIndexPathsBinding toObject:self.iuController withKeyPath:@"selectionIndexPaths" options:IUBindingDictNotRaisesApplicable];
    
    //add observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSheetSelection:) name:IUNotificationSheetSelectionDidChange object:nil];

    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    id selectedObject = [notification.userInfo objectForKey:@"selectedObject"];
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
        newSection.htmlID = [self.identifierManager createIdentifierWithPrefix:newSection.className];
        newSection.name = newSection.htmlID;
        [self.identifierManager addObject:newSection];
        
        //add section to pageContent
        IUPage *currentPage = [_iuController.content firstObject];
        [currentPage.pageContent addIU:newSection error:nil];
        
        //reload controller
        [self.iuController rearrangeObjects];
        [self.iuController setSelectedObject:newSection];
    }
}

- (IUIdentifierManager *)identifierManager{
    return [[[[NSApp mainWindow] windowController] document] performSelector:@selector(identifierManager)];
}

@end
