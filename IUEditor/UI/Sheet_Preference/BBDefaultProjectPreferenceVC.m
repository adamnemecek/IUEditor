//
//  BBDefaultProjectPreferenceVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 18..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBDefaultProjectPreferenceVC.h"

@interface BBDefaultProjectPreferenceVC ()

@property (weak) IBOutlet NSTextField *authorTextField;
@property (weak) IBOutlet NSComboBox *faviconComboBox;
@property (weak) IBOutlet NSTextField *buildPathTextField;
@property (weak) IBOutlet NSTextField *buildResourcePathTextField;
@property (weak) IBOutlet NSButton *enableMinWidthButton;

@property (weak) IBOutlet NSButton *buildPathButton;
@property (weak) IBOutlet NSButton *buildResourceButton;

@end

@implementation BBDefaultProjectPreferenceVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [_authorTextField bind:NSValueBinding toObject:self withKeyPath:@"project.author" options:IUBindingDictNotRaisesApplicable];
    [_faviconComboBox bind:NSValueBinding toObject:self withKeyPath:@"project.favicon" options:IUBindingDictNotRaisesApplicable];
    
    [_buildPathTextField bind:NSValueBinding toObject:self withKeyPath:@"project.buildPath" options:IUBindingDictNotRaisesApplicable];
    [_buildResourcePathTextField bind:NSValueBinding toObject:self withKeyPath:@"project.buildResourcePath" options:IUBindingDictNotRaisesApplicable];
    
    [_enableMinWidthButton bind:NSValueBinding toObject:self withKeyPath:@"project.enableMinWidth" options:IUBindingDictNotRaisesApplicableAndContinuousUpdate];
}


- (IBAction)clickOpenBrowserButton:(id)sender {
    
    if([sender isEqualTo:_buildPathButton]){
        NSURL *url = [[JDFileUtil util] openDirectoryByNSOpenPanelWithTitle:@"Select Build Folder"];
        _project.buildPath = [url path];
    }
    else if([sender isEqualTo:_buildResourceButton]){
        NSURL *url = [[JDFileUtil util] openDirectoryByNSOpenPanelWithTitle:@"Select Build Resource Folder"];
        _project.buildResourcePath = [url path];
    }
    
}

- (IBAction)clickResetPaths:(id)sender {
    [_project resetBuildPath];
}

@end
