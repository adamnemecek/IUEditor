//
//  BBActionPropertyVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 8..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBActionPropertyVC.h"

#import "IUPage.h"

@interface BBActionPropertyVC ()

/* children views of table view */
@property (strong) IBOutlet NSView *linkView;
@property (strong) IBOutlet NSView *mouseOverView;

/* link view outlet*/
@property (weak) IBOutlet NSPopUpButton *linkPagePopupButton;
@property (weak) IBOutlet NSPopUpButton *linkDivPopupButton;

@property (weak) IBOutlet NSTextField *linkURLTextField;

@property (weak) IBOutlet NSButton *linkURLButton;
@property (weak) IBOutlet NSMatrix *linkOpenTypeMatrix;

/* mouse over view outlet */
/* this property cannot be changed */
@property (weak) IBOutlet NSColorWell *selectedBgColorWell;
@property (weak) IBOutlet NSColorWell *selectedTextColorWell;

@property (weak) IBOutlet NSColorWell *hoverBGColorWell;
@property (weak) IBOutlet NSTextField *hoverTimeTextField;
@property (weak) IBOutlet NSColorWell *hoverTextColorWell;
@property (weak) IBOutlet NSTextField *hoverBGXpositionTextField;
@property (weak) IBOutlet NSTextField *hoverBGYPositionTextField;

@end

@implementation BBActionPropertyVC{
    NSArray *_childrenViewArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _childrenViewArray = @[_linkView, _mouseOverView];
    
    //binding
    /* mouse hover */
    [self outlet:_selectedBgColorWell bind:NSValueBinding cascadingStyleStorageProperty:@"bgColor"];
    [self outlet:_selectedTextColorWell bind:NSValueBinding cascadingStyleStorageProperty:@"fontColor"];
    
    [self resetLinkPagePopupButton];
    [self resetLinkDivPopupButton];

}
- (void)setProject:(IUProject *)project{
    _project  = project;
    
    //add observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sheetStructureChange:) name:IUNotificationSheetStructureDidChange object:self.project];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iuSelectionChange:) name:IUNotificationSelectionDidChange object:self.project];
    
    [self resetLinkPagePopupButton];
    [self resetLinkDivPopupButton];
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    JDSectionInfoLog(IULogDealloc, @"");
}

#pragma mark - link
- (void)sheetStructureChange:(NSNotification *)notification{
    [self resetLinkPagePopupButton];
}
- (void)resetLinkPagePopupButton{
    [_linkPagePopupButton removeAllItems];
    [_linkPagePopupButton addItemWithTitle:@"None"];
    for(IUPage *page in self.project.pageGroup.allLeafChildrenFileItems){
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:page.name action:nil keyEquivalent:@""];
        item.representedObject = page;
        [[_linkPagePopupButton menu] addItem:item];
    }
    
}

- (IBAction)clickLinkPagePopUpButton:(id)sender {
    IUPage *page = [[sender selectedItem] representedObject];
    [self.iuController.selection setValue:page forKey:@"link"];
    [self.iuController.selection setValue:nil forKey:@"divLink"];
    [self resetLinkDivPopupButton];
}

- (void)resetLinkDivPopupButton{
    IUPage *page = [[_linkPagePopupButton selectedItem] representedObject];
    [_linkDivPopupButton removeAllItems];
    [_linkDivPopupButton addItemWithTitle:@"None"];
    if(page){
        for(IUBox *box in page.allChildren){
            NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:box.name action:nil keyEquivalent:@""];
            item.representedObject = box;
            [[_linkDivPopupButton menu] addItem:item];
        }
    }

}

- (IBAction)clickLinkDivPopUpButton:(id)sender{
    IUBox *box = [[sender selectedItem] representedObject];
    [self.iuController.selection setValue:box forKey:@"divLink"];

}

/* update link information */
- (void)iuSelectionChange:(NSNotification *)notification{
    BOOL isUseURL;
    id link = [self valueForProperty:@"link"];
    if([link isKindOfClass:[NSString class]]){
        isUseURL = YES;
        [_linkURLTextField setValue:link];
    }
    else{
        isUseURL = NO;
        
        id divLink;
        
        if([link isKindOfClass:[IUBox class]]){
            IUBox *box = link;
            [_linkPagePopupButton selectItemWithTitle:box.name];
            
            //update div link menu item
            [self resetLinkDivPopupButton];
            divLink = [self valueForProperty:@"divLink"];
            if([divLink isKindOfClass:[IUBox class]]){
                [_linkDivPopupButton selectItemWithTitle:((IUBox *)divLink).name];
            }
            else{
                [_linkDivPopupButton selectItemWithTitle:@"None"];
            }

        }
        else{
            [_linkPagePopupButton selectItemWithTitle:@"None"];
            
            //update div link menu item
            [self resetLinkDivPopupButton];
            [_linkDivPopupButton selectItemWithTitle:@"None"];
        }

    }
    
    [_linkURLButton setState:isUseURL];
    [self resetLinkOutletStatus];
}

- (IBAction)clickLinkUrlButton:(id)sender {
    [self resetLinkOutletStatus];
    [self.iuController.selection setValue:nil forKey:@"link"];
    [self.iuController.selection setValue:nil forKey:@"divLink"];

}

- (void)resetLinkOutletStatus{
    /* change status of textfield, popupbuttons */
    BOOL isUseURL = [_linkURLButton state];
    [_linkURLTextField setEnabled:isUseURL];
    
    [_linkPagePopupButton setEnabled:!isUseURL];
    [_linkDivPopupButton setEnabled:!isUseURL];
}
#pragma mark - table view

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [_childrenViewArray count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    return [_childrenViewArray objectAtIndex:row];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    NSView *currentView = [_childrenViewArray objectAtIndex:row];
    return currentView.frame.size.height;
}


@end
