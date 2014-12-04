//
//  BBProjectStructureVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 4..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBProjectStructureVC.h"

#import "BBPageNavigationVC.h"
#import "BBClassNavigationVC.h"

@interface BBProjectStructureVC ()

@property (weak) IBOutlet NSView *pageStuructureView;
@property (weak) IBOutlet NSView *pagesNavigationView;
@property (weak) IBOutlet NSView *compositionsNavigationView;

@property (weak) IBOutlet NSSearchField *strucutreSearchField;

@end

@implementation BBProjectStructureVC{
    //VCs
    BBPageNavigationVC *_pageNavigationVC;
    BBClassNavigationVC *_classNavigationVC;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        _pageNavigationVC = [[BBPageNavigationVC alloc] initWithNibName:[BBPageNavigationVC class].className bundle:nil];
        _classNavigationVC = [[BBClassNavigationVC alloc] initWithNibName:[BBClassNavigationVC class].className bundle:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //add views
    [_pagesNavigationView addSubviewFullFrame:_pageNavigationVC.view];
    [_compositionsNavigationView addSubviewFullFrame:_classNavigationVC.view];
}

- (void)setPageController:(IUSheetController *)pageController{
    _pageController = pageController;
    [_pageNavigationVC setPageController:pageController];
}

- (void)setClassController:(IUSheetController *)classController{
    _classController = classController;
    [_classNavigationVC setClassController:classController];
}



@end