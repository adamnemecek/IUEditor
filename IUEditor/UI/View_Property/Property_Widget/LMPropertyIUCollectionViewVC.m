//
//  LMPropertyIUCollectionViewVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 9. 11..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMPropertyIUCollectionViewVC.h"
#import "IUProject.h"
#import "IUCollection.h"
#import "IUSheet.h"
#import "IUBox.h"

@interface LMPropertyIUCollectionViewVC ()
@property (weak) IBOutlet NSPopUpButton *collectionPopupButton;

@end

@implementation LMPropertyIUCollectionViewVC{
    IUProject *_project;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib{
    [self structureChanged:nil];
}

- (void)setProject:(IUProject*)project{
    _project = project;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(structureChanged:) name:IUNotificationStructureDidChange object:project];
}

- (void)structureChanged:(NSNotification*)noti{
    [_collectionPopupButton removeAllItems];
    [_collectionPopupButton addItemWithTitle:@"None"];
    
    if(self.controller.selectedObjects.count > 0){
        IUBox *iu = self.controller.selectedObjects[0];
        IUSheet *sheet = iu.sheet;
        for(IUBox *child in sheet.allChildren){
            if([child isKindOfClass:[IUCollection class]]){
                NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:child.name action:nil keyEquivalent:@""];
                item.representedObject = item;
                [[_collectionPopupButton menu] addItem:item];
            }
        }
    }
}


- (IBAction)performCollectionChange:(id)sender{
    NSString *selectedItem = [[_collectionPopupButton selectedItem] title];
    if([selectedItem isEqualToString:@"None"]){
        [self setValue:nil forIUProperty:@"collection"];
        return;
    }
    if(_project){
        /*
         FIXME
        IUBox *box = [_project.identifierManager IUWithIdentifier:selectedItem];
        if(box){
            [self setValue:box forIUProperty:@"collection"];
        }
         */
        
    }
}

- (void)selectionDidChange:(NSDictionary *)change{
    id collection = [self valueForProperty:@"collection"];
    
    if(collection == nil || collection == NSNoSelectionMarker
       || collection == NSMultipleValuesMarker || collection == NSNotApplicableMarker){
        [_collectionPopupButton selectItemWithTitle:@"None"];
    }
    else if(collection){
        [_collectionPopupButton selectItemWithTitle:((IUCollection *)collection).name];
    }
}

@end
