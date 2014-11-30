//
//  LMIUInspectorVC.m
//  IUEditor
//
//  Created by jd on 4/11/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "LMIUPropertyVC.h"

#import "JDOutlineCellView.h"

#import "LMInspectorLinkVC.h"
#import "LMPropertyIUHTMLVC.h"
#import "LMPropertyIUFBLikeVC.h"
#import "LMPropertyIUCarouselVC.h"
#import "LMPropertyIUMovieVC.h"
#import "LMPropertyIUTransitionVC.h"
#import "LMPropertyIUWebMovieVC.h"
#import "LMPropertyIUImportVC.h"
#import "LMPropertyIUTextFieldVC.h"
#import "LMPropertyIUCollectionVC.h"
#import "LMPropertyIUTextViewVC.h"
#import "LMPropertyIUPageLinkSetVC.h"
#import "LMPropertyIUPageVC.h"
#import "LMPropertyAnalyticsVC.h"
#import "LMPropertyPGFormVC.h"
#import "PGSubmitButtonVC.h"
#import "LMInspectorAltTextVC.h"
#import "LMPropertyIUSection.h"
#import "LMPropertyIUCollectionViewVC.h"

#import "LMPropertyWPArticleVC.h"
#import "LMPropertyWPMenuVC.h"
#import "LMPropertyIUMenuBarVC.h"
#import "LMPropertyIUMenuItemVC.h"
#import "LMPropertyIUTweetButtonVC.h"
#import "LMPropertyIUGoogleMapVC.h"
#import "LMPropertySampleTextVC.h"
#import "LMPropertyWPPageLinksVC.h"
#import "LMPropertyWPCommentObjectVC.h"

#import "LMPropertyTextVC.h"

#import "LMPropertyProgrammingType1VC.h"
#import "LMPropertyProgrammingType2VC.h"
#import "LMPropertyWebProgrammingVC.h"
#import "IUProject.h"



@interface LMIUPropertyVC (){
    IUProject   *_project;
    
    //default property
    LMInspectorLinkVC   *inspectorLinkVC;
    LMInspectorAltTextVC *inspectorAltTextVC;
    
    //iubox property
    LMPropertyIUHTMLVC  *propertyIUHTMLVC;
    LMPropertyIUMovieVC *propertyIUMovieVC;
    LMPropertyIUFBLikeVC *propertyIUFBLikeVC;
    LMPropertyIUCarouselVC *propertyIUCarouselVC;
    
    LMPropertyIUTransitionVC *propertyIUTransitionVC;
    LMPropertyIUWebMovieVC  *propertyIUWebMovieVC;
    LMPropertyIUImportVC    *propertyIUImportVC;
    
    LMPropertyIUTextViewVC *propertyPGTextViewVC;
    LMPropertyIUPageLinkSetVC *propertyPGPageLinkSetVC;
    LMPropertyIUPageVC * propertyIUPageVC;
    LMPropertyAnalyticsVC *propertyAnalyticsVC;
    
    LMPropertyIUMenuBarVC *propertyIUMenuBarVC;
    LMPropertyIUMenuItemVC *propertyIUMenuItemVC;
    LMPropertyIUTweetButtonVC *propertyIUTweetButtonVC;
    
    LMPropertyIUGoogleMapVC *propertyIUGoogleMapVC;
    LMPropertyIUSection *propertyIUSectionVC;
    
    //pg property
    LMPropertyIUTextFieldVC *propertyPGTextFieldVC;
    LMPropertyIUCollectionVC  *propertyIUCollectionVC;
    LMPropertyIUCollectionViewVC *propertyIUCollectionViewVC;
    
    LMPropertyPGFormVC *propertyPGFormVC;
    PGSubmitButtonVC *propertyPGSubmitButtonVC;
    
    LMPropertyProgrammingType1VC *propertyPGType1VC;
    LMPropertyProgrammingType2VC *propertyPGType2VC;
    LMPropertyWebProgrammingVC *propertyWebProgramming;

    
    //wp property
    LMPropertyWPArticleVC *propertyWPArticleVC;
    LMPropertyWPMenuVC *propertyWPMenuVC;
    LMPropertyWPPageLinksVC *propertyWPPageLinksVC;
    LMPropertyWPCommentObjectVC *pCommentObjectVC;
    
    LMPropertyTextVC *propertyTextVC;
    
    LMPropertySampleTextVC *pSampleTextVC;


    NSViewController <IUPropertyDoubleClickReceiver> *doubleClickFocusVC;
    NSView *_noInspectorV;
    __weak NSTableView *_tableV;
    NSString *currentSelectedClass;
}

@property     NSArray *propertyVArray;


@property (strong) IBOutlet NSBox *defaultTitleV;
@property (strong) IBOutlet NSBox *advancedTitleV;
@property (strong) IBOutlet NSView *advancedContentV;

@property (weak) IBOutlet NSOutlineView *outlineV;
@property (weak) IBOutlet NSTextField *advancedTF;

@property (weak) IBOutlet NSTableView *tableV;
@property (strong) IBOutlet NSView *noInspectorV;
@end

@implementation LMIUPropertyVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //default
        inspectorLinkVC = [[LMInspectorLinkVC alloc] initWithNibName:[LMInspectorLinkVC class].className bundle:nil];
        inspectorAltTextVC = [[LMInspectorAltTextVC alloc] initWithNibName:[LMInspectorAltTextVC class].className bundle:nil];
        
        propertyIUHTMLVC = [[LMPropertyIUHTMLVC alloc] initWithNibName:[LMPropertyIUHTMLVC class].className bundle:nil];
        
        propertyIUMovieVC = [[LMPropertyIUMovieVC alloc] initWithNibName:[LMPropertyIUMovieVC class].className bundle:nil];
        propertyIUFBLikeVC = [[LMPropertyIUFBLikeVC alloc] initWithNibName:[LMPropertyIUFBLikeVC class].className bundle:nil];
        propertyIUCarouselVC = [[LMPropertyIUCarouselVC alloc] initWithNibName:[LMPropertyIUCarouselVC class].className bundle:nil];
        
        propertyIUTransitionVC = [[LMPropertyIUTransitionVC alloc] initWithNibName:[LMPropertyIUTransitionVC class].className bundle:nil];
        propertyIUWebMovieVC = [[LMPropertyIUWebMovieVC alloc] initWithNibName:[LMPropertyIUWebMovieVC class].className bundle:nil];
        propertyIUImportVC = [[LMPropertyIUImportVC alloc] initWithNibName:[LMPropertyIUImportVC class].className bundle:nil];
        
        
        propertyIUMenuBarVC = [[LMPropertyIUMenuBarVC alloc] initWithNibName:[LMPropertyIUMenuBarVC class].className bundle:nil];
        propertyIUMenuItemVC = [[LMPropertyIUMenuItemVC alloc] initWithNibName:[LMPropertyIUMenuItemVC class].className bundle:nil];
        
        propertyIUTweetButtonVC = [[LMPropertyIUTweetButtonVC alloc] initWithNibName:[LMPropertyIUTweetButtonVC class].className bundle:nil];
        propertyIUGoogleMapVC = [[LMPropertyIUGoogleMapVC alloc] initWithNibName:[LMPropertyIUGoogleMapVC class].className bundle:nil];
        propertyIUSectionVC = [[LMPropertyIUSection alloc] initWithNibName:[LMPropertyIUSection class].className bundle:nil];
        

        //pg
        propertyPGTextFieldVC = [[LMPropertyIUTextFieldVC alloc] initWithNibName:[LMPropertyIUTextFieldVC class].className bundle:nil];
        propertyIUCollectionVC = [[LMPropertyIUCollectionVC alloc] initWithNibName:[LMPropertyIUCollectionVC class].className bundle:nil];
        propertyIUCollectionViewVC = [[LMPropertyIUCollectionViewVC alloc] initWithNibName:[LMPropertyIUCollectionViewVC class].className bundle:nil];
        
        propertyPGTextViewVC = [[LMPropertyIUTextViewVC alloc] initWithNibName:[LMPropertyIUTextViewVC class].className bundle:nil];
        
        propertyPGPageLinkSetVC = [[LMPropertyIUPageLinkSetVC alloc] initWithNibName:[LMPropertyIUPageLinkSetVC class].className bundle:nil];
        propertyIUPageVC = [[LMPropertyIUPageVC alloc] initWithNibName:[LMPropertyIUPageVC class].className bundle:nil];
        propertyAnalyticsVC = [[LMPropertyAnalyticsVC alloc] initWithNibName:[LMPropertyAnalyticsVC class].className bundle:nil];
        propertyPGFormVC = [[LMPropertyPGFormVC alloc] initWithNibName:[LMPropertyPGFormVC class].className bundle:nil];
        
        propertyPGSubmitButtonVC = [[PGSubmitButtonVC alloc] initWithNibName:[PGSubmitButtonVC class].className bundle:nil];
        
        
        propertyPGType1VC = [[LMPropertyProgrammingType1VC alloc] initWithNibName:[LMPropertyProgrammingType1VC class].className bundle:nil];
        propertyPGType2VC = [[LMPropertyProgrammingType2VC alloc] initWithNibName:[LMPropertyProgrammingType2VC class].className bundle:nil];
        propertyTextVC = [[LMPropertyTextVC alloc] initWithNibName:[LMPropertyTextVC class].className bundle:nil];
        propertyWebProgramming = [[LMPropertyWebProgrammingVC alloc] initWithNibName:[LMPropertyWebProgrammingVC class].className bundle:nil];
        

#pragma mark - WP
        propertyWPArticleVC = [[LMPropertyWPArticleVC alloc] initWithNibName:[LMPropertyWPArticleVC class].className bundle:nil];
        propertyWPMenuVC = [[LMPropertyWPMenuVC alloc] initWithNibName:[LMPropertyWPMenuVC class].className bundle:nil];
        propertyWPPageLinksVC = [[LMPropertyWPPageLinksVC alloc] initWithNibName:[LMPropertyWPPageLinksVC class].className bundle:nil];
        
        pSampleTextVC = [[LMPropertySampleTextVC alloc] initWithNibName:[LMPropertySampleTextVC class].className bundle:nil];
        
        pCommentObjectVC = [[LMPropertyWPCommentObjectVC alloc] initWithNibName:[LMPropertyWPCommentObjectVC class].className bundle:nil];
        
        [self loadView];
    }
    return self;
}


-(void)setProject:(IUProject *)project{
    _project = project;
    [inspectorLinkVC setProject:project];
    [propertyIUImportVC setProject:project];
    [propertyIUCollectionViewVC setProject:project];
    [propertyPGFormVC setProject:project];
}

- (void)setFocusForDoubleClickAction{
    if (doubleClickFocusVC) {
        NSAssert([doubleClickFocusVC respondsToSelector:@selector(performFocus:)], @"");
    }
    [doubleClickFocusVC performFocus:nil];
}


-(void)setController:(IUController *)controller{
    _controller = controller;
    [_controller addObserver:self forKeyPath:@"selectedObjects" options:0 context:nil];
    
    inspectorLinkVC.controller = controller;
    inspectorAltTextVC.controller = controller;
    propertyIUHTMLVC.controller = controller;
    
    propertyIUMovieVC.controller = controller;
    propertyIUFBLikeVC.controller = controller;
    propertyIUCarouselVC.controller = controller;
    
    propertyIUTransitionVC.controller = controller;
    propertyIUWebMovieVC.controller = controller;
    propertyIUImportVC.controller = controller;
    
    propertyIUCollectionVC.controller = controller;
    propertyIUPageVC.controller = controller;
    
    propertyAnalyticsVC.controller = controller;
    propertyIUSectionVC.controller = controller;

    propertyIUMenuBarVC.controller = controller;
    propertyIUMenuItemVC.controller = controller;
    propertyIUTweetButtonVC.controller = controller;
    
    propertyIUTweetButtonVC.controller = controller;
    propertyIUGoogleMapVC.controller = controller;
    
    propertyPGTextViewVC.controller = controller;
    propertyPGPageLinkSetVC.controller = controller;
    propertyPGTextFieldVC.controller = controller;
    
    propertyIUCollectionViewVC.controller = controller;
    
    propertyPGFormVC.controller = controller;
    propertyPGSubmitButtonVC.controller = controller;
    propertyPGType1VC.controller = controller;
    propertyPGType2VC.controller = controller;
    propertyWebProgramming.controller = controller;
    
    propertyWPArticleVC.controller = controller;
    propertyWPMenuVC.controller = controller;
    propertyWPPageLinksVC.controller = controller;
    pCommentObjectVC.controller = controller;
    
    pSampleTextVC.controller = controller;
    
    propertyTextVC.controller = controller;
}

-(void)dealloc{
    [JDLogUtil log:IULogDealloc string:@"LMIUPropertyVC"];
    [_controller removeObserver:self forKeyPath:@"selectedObjects"];
}
- (void)prepareDealloc{
    [propertyIUCarouselVC prepareDealloc];
    [propertyIUMovieVC prepareDealloc];
    [propertyIUGoogleMapVC prepareDealloc];
}

- (void)setResourceManager:(IUResourceManager *)resourceManager{
    _resourceManager = resourceManager;
    propertyIUGoogleMapVC.resourceManager = resourceManager;
}

-(void)selectedObjectsDidChange:(NSDictionary *)change{
    //FIXME: FIX FOR MANY SELECTION that has different kinds of types
    if ([_controller isSelectionSameClass] == NO) {
        self.propertyVArray = [NSMutableArray arrayWithArray:@[self.noInspectorV]];
        doubleClickFocusVC = nil;
        [_tableV reloadData];

        return;
    }
    
    
    doubleClickFocusVC = nil;

    
    NSString *classString = [[self.controller selectedPedigree] firstObject];
    
    
    if([currentSelectedClass isEqualToString:classString]){
        //same class일때 table view 변하지 않음.
        return;
    }
    
    
    if ([classString isEqualToString:@"IUCarousel"]) {
        self.propertyVArray = nil;
        [_tableV setHidden:YES];
        [self.view addSubviewFullFrame:propertyIUCarouselVC.view];
    }
    else{
        [propertyIUCarouselVC.view removeFromSuperview];
        [_tableV setHidden:NO];
    }
    
#pragma mark PG
    if ([classString isEqualToString:@"WPArticleBody"]) {
        self.propertyVArray = @[pSampleTextVC.view];
    }

    
#pragma mark PG
    else if ([classString isEqualToString:@"PGForm"]) {
        self.propertyVArray = @[propertyPGFormVC.view];
    }
    else if ([classString isEqualToString:@"PGTextView"]) {
        self.propertyVArray = @[propertyPGTextViewVC.view, propertyPGType2VC.view, propertyWebProgramming.view];
        doubleClickFocusVC = propertyPGTextViewVC;
    }
    else if ([classString isEqualToString:@"PGTextField"]) {
        self.propertyVArray = @[propertyPGTextFieldVC.view, propertyPGType2VC.view, propertyWebProgramming.view];
        doubleClickFocusVC = propertyPGTextFieldVC;
    }
    else if ([classString isEqualToString:@"PGSubmitButton"]){
        self.propertyVArray = @[propertyPGSubmitButtonVC.view];
        doubleClickFocusVC = propertyPGSubmitButtonVC;
    }
    else if ([classString isEqualToString:@"PGPageLinkSet"]) {
        self.propertyVArray = @[propertyPGPageLinkSetVC.view, inspectorLinkVC.view];
    }
#pragma mark IU - Complex
    else if ([classString isEqualToString:@"IUWebMovie"]) {
        self.propertyVArray = @[propertyIUWebMovieVC.view];
    }
    else if ([classString isEqualToString:@"IUHeader"]
             || [classString isEqualToString:@"IUHeader"]
             || [classString isEqualToString:@"IUFooter"]
             || [classString isEqualToString:@"IUSidebar"]
             ) {
       self.propertyVArray = @[propertyIUImportVC.view];
    }
    else if ([classString isEqualToString:@"IUImport"]) {
        self.propertyVArray = @[propertyIUImportVC.view, propertyPGType2VC.view];
    }
    else if([classString isEqualToString:@"IUCollectionView"]){
        self.propertyVArray = @[propertyIUImportVC.view, propertyIUCollectionViewVC.view];
    }
    else if ([classString isEqualToString:@"IUTransition"]) {
        self.propertyVArray = @[propertyIUTransitionVC.view];
    }
    else if ([classString isEqualToString:@"IUFBLike"]) {
        self.propertyVArray = @[propertyIUFBLikeVC.view];
    }
    else if ([classString isEqualToString:@"IUCollection"]){
        self.propertyVArray = @[propertyIUCollectionVC.view, propertyIUImportVC.view];
    }
    else if([classString isEqualToString:@"IUMenuBar"]){
        self.propertyVArray = @[propertyIUMenuBarVC.view, inspectorLinkVC.view];
    }
    else if ([classString isEqualToString:@"IUMenuItem"]){
        self.propertyVArray = @[propertyIUMenuItemVC.view, inspectorLinkVC.view];
    }
    else if ([classString isEqualToString:@"IUTweetButton"]){
        self.propertyVArray = @[propertyIUTweetButtonVC.view];
    }
    else if([classString isEqualToString:@"IUGoogleMap"]) {
        self.propertyVArray = @[propertyIUGoogleMapVC.view];
    }
#pragma mark IU-Simple
    else if ([classString isEqualToString:@"IUMovie"]) {
        self.propertyVArray = @[propertyIUMovieVC.view];
    }
    else if ([classString isEqualToString:@"IUImage"]){
        self.propertyVArray = [NSMutableArray arrayWithArray:@[inspectorAltTextVC.view, inspectorLinkVC.view, propertyPGType2VC.view]];
    }
    else if ([classString isEqualToString:@"IUPage"]){
       self.propertyVArray = [NSMutableArray arrayWithArray:@[propertyIUPageVC.view, propertyAnalyticsVC.view]];
    }
    else if ([classString isEqualToString:@"IUBox"] || [classString isEqualTo:@"IUCenterBox"]){
        self.propertyVArray = [NSMutableArray arrayWithArray:@[propertyTextVC.view, inspectorLinkVC.view, propertyPGType2VC.view]];
        doubleClickFocusVC = propertyTextVC;
    }
    else if([classString isEqualToString:@"IUSection"]){
        self.propertyVArray = @[propertyIUSectionVC.view];
    }

#pragma mark WP
    else if ([classString isEqualToString:@"WPArticle"]){
        self.propertyVArray = @[propertyWPArticleVC.view];
    }
    else if ([classString isEqualToString:@"WPMenu"]){
        self.propertyVArray = @[propertyWPMenuVC.view];
    }
    else if ([classString isEqualToString:@"WPPageLinks"]){
        self.propertyVArray = @[propertyWPPageLinksVC.view];
    }
    else if ([classString isEqualToString:@"WPCommentObject"]){
        self.propertyVArray = @[pCommentObjectVC.view];
    }
    
    else if ([classString isEqualToString:@"IUHTML"]){
        self.propertyVArray = [NSMutableArray arrayWithArray:@[propertyIUHTMLVC.view]];
        doubleClickFocusVC = propertyIUHTMLVC;
    }
    else if ([classString isEqualToString:@"IUItem"]){
        self.propertyVArray = [NSMutableArray arrayWithArray:@[propertyTextVC.view, inspectorLinkVC.view]];
    }
    else {
        self.propertyVArray = [NSMutableArray arrayWithArray:@[self.noInspectorV]];
        doubleClickFocusVC = nil;
    }
    currentSelectedClass = classString;
    
    [_tableV reloadData];
}


#pragma mark -
#pragma mark tableView

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    id v = [self.propertyVArray objectAtIndex:row];
    if ([v isKindOfClass:[NSViewController class]]) {
        return [(NSViewController*)v view];
    }
    return v;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView{
    return [self.propertyVArray count];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    if([self.propertyVArray count] == 0){
        return 0.1;
    }
    return [(NSView*)[self.propertyVArray objectAtIndex:row] frame].size.height;
}


@end
