//
//  BBTopToolBarVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 3..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBTopToolBarVC.h"
#import "BBCommandVC.h"

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
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        _commandVC = [[BBCommandVC alloc] initWithNibName:[BBCommandVC class].className bundle:nil];
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    [_commandView addSubviewFullFrame:_commandVC.view];
}

- (void)setSourceManager:(id)sourceManager{
    [_commandVC setSourceManager:sourceManager];
}

@end
