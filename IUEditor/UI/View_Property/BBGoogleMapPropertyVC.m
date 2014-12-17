//
//  BBGoogleMapPropertyVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 17..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBGoogleMapPropertyVC.h"

@interface BBGoogleMapPropertyVC ()
@property (weak) IBOutlet NSTextField *latitudeTextField;
@property (weak) IBOutlet NSTextField *longitudeTextField;
@property (weak) IBOutlet NSTextField *zoomLevelTextField;
@property (weak) IBOutlet NSStepper *zoomLevelStepper;
@property (weak) IBOutlet NSButton *panControlButton;
@property (weak) IBOutlet NSButton *zoomControlButton;
@property (weak) IBOutlet NSPopUpButton *colorThemePopUpbutton;
@property (weak) IBOutlet NSButton *enableMarkerButton;
@property (weak) IBOutlet NSTextField *markerTitleTextField;
@property (weak) IBOutlet NSComboBox *markerIconComboBox;

@end

@implementation BBGoogleMapPropertyVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self outlet:_latitudeTextField bind:NSValueBinding property:@"latitude"];
    [self outlet:_longitudeTextField bind:NSValueBinding property:@"longitude"];
    [self outlet:_zoomLevelTextField bind:NSValueBinding property:@"zoomLevel"];
    [self outlet:_zoomLevelStepper bind:NSValueBinding property:@"zoomLevel"];
    
    [self outlet:_panControlButton bind:NSValueBinding property:@"panControl"];
    [self outlet:_zoomControlButton bind:NSValueBinding property:@"zoomControl"];
    
    [self outlet:_colorThemePopUpbutton bind:NSValueBinding property:@"themeType"];

    [self outlet:_enableMarkerButton bind:NSValueBinding property:@"enableMarkerIcon"];
    [self outlet:_markerTitleTextField bind:NSValueBinding property:@"markerTitle"];
    [self outlet:_markerIconComboBox bind:NSValueBinding property:@"markerIconName"];
}

@end
