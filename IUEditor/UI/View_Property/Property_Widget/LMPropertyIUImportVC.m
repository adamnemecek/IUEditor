//
//  LMPropertyIURenderVC.m
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 4. 18..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMPropertyIUImportVC.h"
#import "IUSheetGroup.h"
#import "IUClass.h"
#import "IUImport.h"
#import "IUProject.h"

@interface LMPropertyIUImportVC ()
@property (weak) IBOutlet NSPopUpButton *prototypeB;
@end

@implementation LMPropertyIUImportVC {
    IUProject *_project;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self loadView];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)structureChanged:(NSNotification*)noti{
    [_prototypeB removeAllItems];
    [_prototypeB addItemWithTitle:@"None"];
    [_prototypeB addItemsWithTitles:[[_project classGroup].childrenFileItems valueForKey:@"name"]];
}



- (void)setProject:(IUProject*)project{
    _project = project;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(structureChanged:) name:IUNotificationStructureDidChange object:project];
    [self structureChanged:nil];
}


- (IBAction)performPrototypeChange:(NSPopUpButton *)sender {
    
    if([[sender title] isEqualToString:@"None"]){
        [self setValue:nil forIUProperty:@"prototypeClass"];
    }
    else{
        IUClass *class = [_project.classGroup.childrenFileItems objectWithKey:@"name" value:sender.selectedItem.title];
        [self setValue:class forIUProperty:@"prototypeClass"];
    }
}

- (void)selectionDidChange:(NSDictionary *)change{
    id protoType = [self valueForProperty:@"prototypeClass"];
    
    if(protoType == nil || protoType == NSNoSelectionMarker
       || protoType == NSMultipleValuesMarker || protoType == NSNotApplicableMarker){
        [_prototypeB selectItemWithTitle:@"None"];
    }
    else if(protoType){
        [_prototypeB selectItemWithTitle:((IUClass *)protoType).name];
    }
}



@end