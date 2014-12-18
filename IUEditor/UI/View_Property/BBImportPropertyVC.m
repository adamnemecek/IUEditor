//
//  BBImportPropertyVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 17..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBImportPropertyVC.h"
#import "IUImport.h"

@interface BBImportPropertyVC ()

@property (weak) IBOutlet NSPopUpButton *compositionPopUpButton;

@end

@implementation BBImportPropertyVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sheetStructureChange:) name:IUNotificationSheetStructureDidChange object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iuSelectionChange:) name:IUNotificationSelectionDidChange object:self.view.window];
    
    [self resetCompositionPopUpButton];

}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - manage popup button
- (void)setProject:(IUProject *)project{
    _project = project;
    [self resetCompositionPopUpButton];
}

- (void)sheetStructureChange:(NSNotification *)notification{
    [self resetCompositionPopUpButton];
}

- (void)resetCompositionPopUpButton{
    [_compositionPopUpButton removeAllItems];
    [_compositionPopUpButton addItemWithTitle:@"None"];
    [_compositionPopUpButton addItemsWithTitles:[[_project classGroup].allLeafChildrenFileItems valueForKey:@"name"]];

}
- (IBAction)clickCompositionPopUpButton:(id)sender {
    if([[sender title] isEqualToString:@"None"]){
        for(IUImport *iu in self.iuController.selectedObjects){
            iu.prototypeClass = nil;
        }
    }
    else{
        IUClass *class = [_project.classGroup.allLeafChildrenFileItems objectWithKey:@"name" value:_compositionPopUpButton.selectedItem.title];
        for(IUImport *iu in self.iuController.selectedObjects){
            iu.prototypeClass = class;
        }
    }
}

- (void)iuSelectionChange:(NSNotification *)notification{
    id protoType = [self valueForProperty:@"prototypeClass"];
    
    if(protoType == nil || protoType == NSNoSelectionMarker
       || protoType == NSMultipleValuesMarker || protoType == NSNotApplicableMarker){
        [_compositionPopUpButton selectItemWithTitle:@"None"];
    }
    else if(protoType){
        [_compositionPopUpButton selectItemWithTitle:((IUClass *)protoType).name];
    }
}


@end
