//
//  BBWidgetPropertyVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 8..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBWidgetPropertyVC.h"

#import "IUBoxes.h"

//iubox's properties VC
#import "BBFramePropertyVC.h"
#import "BBFontPropertyVC.h"

@interface BBWidgetPropertyVC ()

@property (weak) IBOutlet NSTableView *widgetPropertyTableView;

@end

@implementation BBWidgetPropertyVC{
    NSMutableArray *_childrenVCArray;
    
    //properties VC
    BBFramePropertyVC *_framePropertyVC;
    BBFontPropertyVC *_fontPropertyVC;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        _framePropertyVC = [[BBFramePropertyVC alloc] initWithNibName:[BBFramePropertyVC className] bundle:nil];
        _fontPropertyVC = [[BBFontPropertyVC alloc] initWithNibName:[BBFontPropertyVC className] bundle:nil];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _childrenVCArray = [NSMutableArray array];
    
    //add observer to iuselection 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeIUSelection:) name:IUNotificationSelectionDidChange object:nil];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    JDSectionInfoLog(IULogDealloc, @"");

}

- (void)setIuController:(IUController *)iuController{
    [super setIuController:iuController];
    [_framePropertyVC setIuController:iuController];
    [_fontPropertyVC setIuController:iuController];
}

- (void)setResourceRootItem:(IUResourceRootItem *)resourceRootItem{
    [super setResourceRootItem:resourceRootItem];
    [_framePropertyVC setResourceRootItem:resourceRootItem];
    [_fontPropertyVC setResourceRootItem:resourceRootItem];
}


#pragma mark - notification
- (void)changeIUSelection:(NSNotification *)notification{
    [_childrenVCArray removeAllObjects];
    //default
    [_childrenVCArray addObject:_framePropertyVC];
    
    //select VC from className
    NSString *selectedClassName = [notification.userInfo objectForKey:@"selectionClassName"];
    if([selectedClassName isEqualToString:[IUBox className]]){

    }
    else if([selectedClassName isEqualToString:[IUText className]]){
        [_childrenVCArray addObject:_fontPropertyVC];
    }
    
    [_widgetPropertyTableView reloadData];

}

#pragma mark - table view

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [_childrenVCArray count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    return [[_childrenVCArray objectAtIndex:row] view];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    NSView *currentView = [[_childrenVCArray objectAtIndex:row] view];
    return currentView.frame.size.height;
}

@end
