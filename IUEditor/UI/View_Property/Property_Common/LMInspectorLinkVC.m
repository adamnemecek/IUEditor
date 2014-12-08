//
//  LMPropertyIUBoxVC.m
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 4. 18..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMInspectorLinkVC.h"
#import "IUSheetGroup.h"
#import "IUSheet.h"
#import "IUPage.h"
#import "IUProject.h"

@interface LMInspectorLinkVC ()
@property (weak) IBOutlet NSPopUpButton *pageLinkPopupButton;
@property (weak) IBOutlet NSPopUpButton *divLinkPB; //not use for alpha 0.2 version
@property (weak) IBOutlet NSButton *urlCheckButton;
@property (weak) IBOutlet NSTextField *urlTF;
@property (weak) IBOutlet NSButton *targetCheckButton;

@end

@implementation LMInspectorLinkVC{
    IUProject *_project;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        [self loadView];

    }
    return self;
}

- (void)awakeFromNib{
    _urlTF.delegate = self;
    [_divLinkPB setEnabled:NO];
}

- (void)dealloc{
    [JDLogUtil log:IULogDealloc string:@"LMInspectorLinkVC"];
    [self removeObserver:self forKeyPath:[self pathForProperty:@"link"]];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (void)setProject:(IUProject*)project{
    _project = project;
    
    [self updateLinkPopupButtonItems];
    [self outlet:_targetCheckButton bind:NSValueBinding property:@"linkTarget"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(structureChanged:) name:IUNotificationStructureDidChange object:project];
}


- (CalledByNoti)structureChanged:(NSNotification*)noti{
    NSDictionary *userInfo = noti.userInfo;
    if ([userInfo[IUNotificationStructureChangedIU] isKindOfClass:[IUPage class]]) {
        [self updateLinkPopupButtonItems];
    }
}
- (void)updateLinkPopupButtonItems{
    [_pageLinkPopupButton removeAllItems];
    [_pageLinkPopupButton addItemWithTitle:@"None"];
    [_pageLinkPopupButton addItemWithTitle:@"Self"];
    for (IUPage *page in _project.pageGroup.childrenFileItems) {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:page.name action:nil keyEquivalent:@""];
        item.representedObject = page;
        [[_pageLinkPopupButton menu] addItem:item];
    }

}

- (void)setController:(IUController *)controller{
    [super setController:controller];
    [self addObserverForProperty:@"link" options:0 context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    if([keyPath isEqualToString:@"selection"]
       || [[keyPath pathExtension] isEqualToString:@"link"]){
        
        [_divLinkPB setEnabled:NO];
        [_urlCheckButton setState:0];
#pragma mark - set link
        id value = [self valueForProperty:@"link"];
        
        if (value == NSNoSelectionMarker || value == nil) {
            [_pageLinkPopupButton selectItemWithTitle:@"None"];
            [_urlTF setStringValue:@""];
            [_targetCheckButton setEnabled:NO];
        }
        else if (value == NSMultipleValuesMarker) {
            [_pageLinkPopupButton selectItemWithTitle:@"None"];
            [_urlTF setStringValue:@"multiple"];
            [_targetCheckButton setEnabled:YES];
        }
        else {
            [_targetCheckButton setEnabled:YES];
            if([value isKindOfClass:[IUBox class]]){
                [_pageLinkPopupButton selectItemWithTitle:((IUBox *)value).name];
                [_urlCheckButton setState:0];
                [_urlTF setStringValue:@""];
                [self updateDivLink:value isClassLink:NO];
            }
            else if ([value isKindOfClass:[NSString class]] && [value isEqualToString:@"Self"]){
                [_pageLinkPopupButton selectItemWithTitle:@"Self"];
                [_urlTF setStringValue:@""];
                [_targetCheckButton setEnabled:NO];
                [self updateDivLink:[self.controller.content firstObject] isClassLink:YES];
            }
            else{
                [_urlCheckButton setState:1];
                [_urlTF setStringValue:value];
                [_pageLinkPopupButton selectItemWithTitle:@"None"];
            }
        }
        [self updateLinkEnableState];
#pragma mark - set div link
        value = [self valueForProperty:@"divLink"];

        if([value isKindOfClass:[IUBox class]]){
            [_divLinkPB selectItemWithTitle:((IUBox *)value).name];
        }
        else{
            [_divLinkPB selectItemAtIndex:0];
        }
    }
}

- (void)updateLinkEnableState{
    if([_urlCheckButton state] == 0){
        [_pageLinkPopupButton setEnabled:YES];
        [_urlTF setEnabled:NO];
    }
    else{
        [_pageLinkPopupButton setEnabled:NO];
        [_urlTF setEnabled:YES];
    }
}

#pragma mark - IBAction

- (IBAction)clickEnableURLCheckButton:(id)sender {
    [self updateLinkEnableState];
    if([_urlCheckButton state] == 0){
        [self setValue:nil forIUProperty:@"link"];
    }
}

- (IBAction)clickLinkPopupButton:(id)sender {
    NSString *link = [[_pageLinkPopupButton selectedItem] title];
    if([link isEqualToString:@"None"]){
        [self setValue:nil forIUProperty:@"link"];
        return;
    }
    else if([link isEqualToString:@"Self"]){
        [self setValue:@"Self" forIUProperty:@"link"];
        [self updateDivLink:[self.controller.content firstObject] isClassLink:YES];
        return;
    }
    if(_project){
        /* FIXME:
        IUBox *box = [_project.identifierManager IUWithIdentifier:link];
        if(box){
            [self setValue:box forIUProperty:@"link"];
            [self updateDivLink:(IUPage *)box isClassLink:NO];
        }
         */
        
    }
    
}


- (void)controlTextDidChange:(NSNotification *)obj{
    NSTextField *textField = obj.object;
    if([textField isEqualTo:_urlTF]){
        NSString *link = [_urlTF stringValue];
        if(link && link.length > 0){
            [self setValue:link forIUProperty:@"link"];
        }
        else if(link.length == 0){
            [self setValue:nil forIUProperty:@"link"];
        }
    }
}

#pragma mark - div link

- (void)updateDivLink:(IUPage *)page isClassLink:(BOOL)isClassLink{
    NSAssert([page isKindOfClass:[IUPage class]], @"");
    [_divLinkPB setEnabled:YES];
    [_divLinkPB removeAllItems];
    [_divLinkPB addItemWithTitle:@"None"];
    if(isClassLink){
        for(IUBox *box in page.allChildren){
            if([box isKindOfClass:[IUImport class]]){
                for(IUBox *classBox in box.allChildren){
                    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:classBox.name action:nil keyEquivalent:@""];
                    item.representedObject = classBox;
                    [[_divLinkPB menu] addItem:item];
 
                }
            }

        }
    }
    else{
        for(IUBox *box in page.allChildren){
            NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:box.name action:nil keyEquivalent:@""];
            item.representedObject = box;
            [[_divLinkPB menu] addItem:item];
        }
    }
    
}


- (IBAction)clickDivLinkPopupBtn:(id)sender {
    
    if([[_divLinkPB selectedItem] isEqualTo:[_divLinkPB itemAtIndex:0]]){
        [self setValue:nil forIUProperty:@"divLink"];
        return;
    }
    if(_project){
        IUBox *box = [sender selectedItem].representedObject;
        if(box){
            [self setValue:box forIUProperty:@"divLink"];
        }
    }
 
}

@end
