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


@interface BBPageStructureVC ()

@property (weak) IBOutlet NSOutlineView *iuOutlineView;
@property (weak) IBOutlet NSButton *sectionButton;
@property (strong) IBOutlet BBSectionPopover *sectionPopover;

@end

@implementation BBPageStructureVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
#if DEBUG
        [self testaddIu:newSection];
#endif
        
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

/* debug function */
#if DEBUG
- (void)testaddIu:(IUBox *)iu{
    
    IUBox *parent = iu;
    for(int i=0; i< 10; i++){
        IUBox *newIU = [[IUBox alloc] initWithPreset];
        [parent addIU:newIU error:nil];
        parent = newIU;
    }
    
    
}
#endif

@end
