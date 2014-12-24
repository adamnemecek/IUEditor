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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sheetStructureChange:) name:IUNotificationSheetStructureDidChange object:self.project];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iuSelectionChange:) name:IUNotificationSelectionDidChange object:self.project];
    
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
    
    for(IUClass *class in self.project.classGroup.allLeafChildrenFileItems){
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:class.name action:nil keyEquivalent:@""];
        item.representedObject = class;
        [[_compositionPopUpButton menu] addItem:item];
    }

}
- (IBAction)clickCompositionPopUpButton:(id)sender {
    IUClass *class = [[sender selectedItem] representedObject];
    [self.iuController.selection setValue:class forKey:@"prototypeClass"];
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
