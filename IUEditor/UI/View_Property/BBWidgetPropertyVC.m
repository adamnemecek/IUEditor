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
#import "BBVideoPropertyVC.h"
#import "BBTweetPropertyVC.h"
#import "BBGoogleMapPropertyVC.h"
#import "BBWebVideoPropertyVC.h"
#import "BBFBLikePropertyVC.h"
#import "BBTransitionPropertyVC.h"
#import "BBCarouselPropertyVC.h"
#import "BBImportPropertyVC.h"

//pg group
#import "BBPGSubmitPropertyVC.h"
#import "BBPGFormPropertyVC.h"
#import "BBPGTextFieldPropertyVC.h"
#import "BBPGTextAreaPropertyVC.h"

@interface BBWidgetPropertyVC ()

@property (weak) IBOutlet NSTableView *widgetPropertyTableView;

@end

@implementation BBWidgetPropertyVC{
    NSMutableArray *_childrenVCArray;
    
    //properties VC
    //default group
    BBFramePropertyVC *_framePropertyVC;
    BBFontPropertyVC *_fontPropertyVC;
    BBVideoPropertyVC *_videoPropertyVC;
    BBTweetPropertyVC *_tweetPropertyVC;
    BBGoogleMapPropertyVC *_googleMapPropertyVC;
    BBWebVideoPropertyVC *_webVideoPropertyVC;
    BBFBLikePropertyVC *_fbLikePropertyVC;
    BBTransitionPropertyVC *_transitionPropertyVC;
    BBCarouselPropertyVC *_carouselPropertyVC;
    BBImportPropertyVC *_importPropertyVC;
    
    //pg group
    BBPGSubmitPropertyVC *_pgSubmitPropertyVC;
    BBPGFormPropertyVC *_pgFormPropertyVC;
    BBPGTextFieldPropertyVC *_pgTextFieldPropertyVC;
    BBPGTextAreaPropertyVC *_pgTextAreaPropertyVC;
    
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        //default
        _framePropertyVC = [[BBFramePropertyVC alloc] initWithNibName:[BBFramePropertyVC className] bundle:nil];
        
        //default group
        _fontPropertyVC = [[BBFontPropertyVC alloc] initWithNibName:[BBFontPropertyVC className] bundle:nil];
        _videoPropertyVC = [[BBVideoPropertyVC alloc] initWithNibName:[BBVideoPropertyVC className] bundle:nil];
        _tweetPropertyVC = [[BBTweetPropertyVC alloc] initWithNibName:[BBTweetPropertyVC className] bundle:nil];
        _googleMapPropertyVC = [[BBGoogleMapPropertyVC alloc] initWithNibName:[BBGoogleMapPropertyVC className] bundle:nil];
        _webVideoPropertyVC = [[BBWebVideoPropertyVC alloc] initWithNibName:[BBWebVideoPropertyVC className] bundle:nil];
        _fbLikePropertyVC = [[BBFBLikePropertyVC alloc] initWithNibName:[BBFBLikePropertyVC className] bundle:nil];
        _transitionPropertyVC = [[BBTransitionPropertyVC alloc] initWithNibName:[BBTransitionPropertyVC className] bundle:nil];
        _carouselPropertyVC = [[BBCarouselPropertyVC alloc] initWithNibName:[BBCarouselPropertyVC className] bundle:nil];
        _importPropertyVC = [[BBImportPropertyVC alloc] initWithNibName:[BBImportPropertyVC className] bundle:nil];
        
        //pg group
        _pgSubmitPropertyVC = [[BBPGSubmitPropertyVC alloc] initWithNibName:[BBPGSubmitPropertyVC className] bundle:nil];
        _pgFormPropertyVC = [[BBPGFormPropertyVC alloc] initWithNibName:[BBPGFormPropertyVC className] bundle:nil];
        _pgTextFieldPropertyVC = [[BBPGTextFieldPropertyVC alloc] initWithNibName:[BBPGTextFieldPropertyVC className] bundle:nil];
        _pgTextAreaPropertyVC = [[BBPGTextAreaPropertyVC alloc] initWithNibName:[BBPGTextAreaPropertyVC className] bundle:nil];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _childrenVCArray = [NSMutableArray array];
    
    //add observer to iuselection 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeIUSelection:) name:IUNotificationSelectionDidChange object:self.project];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    JDSectionInfoLog(IULogDealloc, @"");

}

- (void)setIuController:(IUController *)iuController{
    [super setIuController:iuController];
    [_framePropertyVC setIuController:iuController];
    
    //default group
    [_fontPropertyVC setIuController:iuController];
    [_videoPropertyVC setIuController:iuController];
    [_tweetPropertyVC setIuController:iuController];
    [_googleMapPropertyVC setIuController:iuController];
    [_webVideoPropertyVC setIuController:iuController];
    [_fbLikePropertyVC setIuController:iuController];
    [_transitionPropertyVC setIuController:iuController];
    [_carouselPropertyVC setIuController:iuController];
    [_importPropertyVC setIuController:iuController];
    
    //pg group
    [_pgSubmitPropertyVC setIuController:iuController];
    [_pgFormPropertyVC setIuController:iuController];
    [_pgTextFieldPropertyVC setIuController:iuController];
    [_pgTextAreaPropertyVC setIuController:iuController];
}

- (void)setResourceRootItem:(IUResourceRootItem *)resourceRootItem{
    [super setResourceRootItem:resourceRootItem];
    [_framePropertyVC setResourceRootItem:resourceRootItem];
    
    //default group
    [_fontPropertyVC setResourceRootItem:resourceRootItem];
    [_videoPropertyVC setResourceRootItem:resourceRootItem];
    [_tweetPropertyVC setResourceRootItem:resourceRootItem];
    [_googleMapPropertyVC setResourceRootItem:resourceRootItem];
    [_webVideoPropertyVC setResourceRootItem:resourceRootItem];
    [_fbLikePropertyVC setResourceRootItem:resourceRootItem];
    [_transitionPropertyVC setResourceRootItem:resourceRootItem];
    [_carouselPropertyVC setResourceRootItem:resourceRootItem];
    [_importPropertyVC setResourceRootItem:resourceRootItem];
    
    //pg group
    [_pgSubmitPropertyVC setResourceRootItem:resourceRootItem];
    [_pgFormPropertyVC setResourceRootItem:resourceRootItem];
    [_pgTextFieldPropertyVC setResourceRootItem:resourceRootItem];
    [_pgTextAreaPropertyVC setResourceRootItem:resourceRootItem];
}

- (void)setProject:(IUProject *)project{
    _project = project;
    [_importPropertyVC setProject:project];
}


#pragma mark - notification
- (void)changeIUSelection:(NSNotification *)notification{
    [_childrenVCArray removeAllObjects];
    
    //select VC from className
    NSString *selectedClassName = [notification.userInfo objectForKey:@"selectionClassName"];
    if ([selectedClassName isEqualToString:[IUBox className]]){

    }
    else if ([selectedClassName isEqualToString:[IUText className]]){
        [_childrenVCArray addObject:_fontPropertyVC];
    }
    else if ([selectedClassName isEqualToString:[IUMovie className]]){
        [_childrenVCArray addObject:_videoPropertyVC];
    }
    else if ([selectedClassName isEqualToString:[IUTweetButton className]]){
        [_childrenVCArray addObject:_tweetPropertyVC];
    }
    else if ([selectedClassName isEqualToString:[IUGoogleMap className]]){
        [_childrenVCArray addObject:_googleMapPropertyVC];
    }
    else if ([selectedClassName isEqualToString:[IUWebMovie className]]){
        [_childrenVCArray addObject:_webVideoPropertyVC];
    }
    else if ([selectedClassName isEqualToString:[IUFBLike className]]){
        [_childrenVCArray addObject:_fbLikePropertyVC];
    }
    else if ([selectedClassName isEqualToString:[IUTransition className]]){
        [_childrenVCArray addObject:_transitionPropertyVC];
    }
    else if ([selectedClassName isEqualToString:[IUCarousel className]]){
        [_childrenVCArray addObject:_carouselPropertyVC];
    }
    else if ([selectedClassName isEqualToString:[IUImport className]]){
        [_childrenVCArray addObject:_importPropertyVC];
    }
    //pg group
    else if ([selectedClassName isEqualToString:[PGSubmitButton className]]){
        [_childrenVCArray addObject:_pgSubmitPropertyVC];
    }
    else if ([selectedClassName isEqualToString:[PGForm className]]){
        [_childrenVCArray addObject:_pgFormPropertyVC];
    }
    else if ([selectedClassName isEqualToString:[PGTextField className]]){
        [_childrenVCArray addObject:_pgTextFieldPropertyVC];
    }
    else if ([selectedClassName isEqualToString:[PGTextView className]]){
        [_childrenVCArray addObject:_pgTextAreaPropertyVC];
    }
    
    
    //default
    [_childrenVCArray addObject:_framePropertyVC];
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
