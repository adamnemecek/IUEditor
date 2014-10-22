//
//  LMPropertyIUGoogleMapVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 8. 7..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMPropertyIUGoogleMapVC.h"
#import "IUGoogleMap.h"

@interface LMPropertyIUGoogleMapVC ()


//default setting
@property (weak) IBOutlet NSTextField *longTF;
@property (weak) IBOutlet NSTextField *latTF;
@property (weak) IBOutlet NSTextField *zoomLevelTF;
@property (weak) IBOutlet NSStepper *zoomLevelStepper;
@property (weak) IBOutlet NSButton *mapControlBtn;
@property (weak) IBOutlet NSButton *PanControlBtn;
@property (weak) IBOutlet NSButton *zoomControlBtn;

//marker
@property (weak) IBOutlet NSButton *enableMarkerBtn;
@property (weak) IBOutlet NSComboBox *markerIconComboBox;
@property (weak) IBOutlet NSTextField *markTitleTF;

//style
@property (weak) IBOutlet NSPopUpButton *themeTypePopupButton;


@end

@implementation LMPropertyIUGoogleMapVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib{
    
    //location
    [self outlet:_longTF bind:NSValueBinding property:@"longitude"];
    [self outlet:_latTF bind:NSValueBinding property:@"latitude"];
    
    [self outlet:_zoomLevelTF bind:NSValueBinding property:@"zoomLevel" options:IUBindingDictNumberAndNotRaisesApplicable];
    [self outlet:_zoomLevelStepper bind:NSValueBinding property:@"zoomLevel" options:IUBindingDictNumberAndNotRaisesApplicable];
    
    //control
    [self outlet:_mapControlBtn bind:NSValueBinding property:@"mapControl"];
    [self outlet:_PanControlBtn bind:NSValueBinding property:@"panControl"];
    [self outlet:_zoomControlBtn bind:NSValueBinding property:@"zoomControl"];
    
    //marker Icon
    [self outlet:_enableMarkerBtn bind:NSValueBinding property:@"enableMarkerIcon"];
    
    [self outlet:_markerIconComboBox bind:NSValueBinding property:@"enableMarkerIcon"];
    [self outlet:_markTitleTF bind:NSValueBinding property:@"markerTitle"];
    [_markerIconComboBox bind:NSContentBinding toObject:self withKeyPath:@"resourceManager.imageFiles" options:IUBindingDictNotRaisesApplicable];
    [self outlet:_markerIconComboBox bind:NSValueBinding property:@"markerIconName"];
    
    //style
    [self outlet:_themeTypePopupButton bind:NSSelectedIndexBinding property:@"themeType"];
    
}
- (void)prepareDealloc{
    [_markerIconComboBox unbind:NSContentBinding];
}
#pragma mark - combobox

- (void)controlTextDidChange:(NSNotification *)obj{
    for (IUGoogleMap *map in self.controller.selectedObjects) {
        id value = [_markerIconComboBox stringValue];
        [map setMarkerIconName:value];
    }
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification{
    for (IUGoogleMap *map in self.controller.selectedObjects) {
        id value = [_markerIconComboBox objectValueOfSelectedItem];
        [map setMarkerIconName:value];
    }
}

@end
