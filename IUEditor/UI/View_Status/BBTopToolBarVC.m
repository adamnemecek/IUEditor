//
//  BBTopToolBarVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 3..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBTopToolBarVC.h"

#import "BBCommandVC.h"
#import "BBQuickWidgetVC.h"
#import "BBMediaQueryVC.h"

#import "BBWC.h"

@interface BBTopToolBarVC ()

@property (weak) IBOutlet NSView *commandView;
@property (weak) IBOutlet NSView *quickWidgetView;
@property (weak) IBOutlet NSView *mediaQueryView;


@property (weak) IBOutlet NSPopUpButton *uploadPopUpButton;
@property (weak) IBOutlet NSButton *refreshButton;
@property (weak) IBOutlet NSPopUpButton *iueditorPopUpButton;

@end

@implementation BBTopToolBarVC{
    BBCommandVC *_commandVC;
    BBQuickWidgetVC *_quickWidgetVC;
    BBMediaQueryVC *_mediaQueryVC;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        _commandVC = [[BBCommandVC alloc] initWithNibName:[BBCommandVC className] bundle:nil];
        _quickWidgetVC = [[BBQuickWidgetVC alloc] initWithNibName:[BBQuickWidgetVC className] bundle:nil];
        _mediaQueryVC = [[BBMediaQueryVC alloc] initWithNibName:[BBMediaQueryVC className] bundle:nil];
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    [_commandView addSubviewFullFrame:_commandVC.view];
    [_quickWidgetView addSubviewFullFrame:_quickWidgetVC.view];
    [_mediaQueryView addSubviewFullFrame:_mediaQueryVC.view];
}

- (void)setSourceManager:(id)sourceManager{
    [_commandVC setSourceManager:sourceManager];
}
- (void)setProject:(id)project{
    [_mediaQueryVC setProject:project];
}

#pragma mark - IBAction
- (IBAction)clickReloadSheetButton:(id)sender {
    [(BBWC *)[[NSApp mainWindow] windowController] reloadCurrentSheet:self];
}
@end
