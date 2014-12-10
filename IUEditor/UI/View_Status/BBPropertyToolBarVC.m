//
//  BBPropertyToolBarVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 5..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBPropertyToolBarVC.h"
#import "LMFontController.h"

@interface BBPropertyToolBarVC ()

//iubox frame property
@property (weak) IBOutlet NSTextField *xTextField;
@property (weak) IBOutlet NSTextField *yTextField;
@property (weak) IBOutlet NSTextField *wTextField;
@property (weak) IBOutlet NSTextField *hTextField;

@property (weak) IBOutlet NSButton *xUnitButton;
@property (weak) IBOutlet NSButton *yUnitButton;
@property (weak) IBOutlet NSButton *wUnitButton;
@property (weak) IBOutlet NSButton *hUnitButton;

//iubox center
@property (weak) IBOutlet NSButton *verticalCenterButton;
@property (weak) IBOutlet NSButton *horizontalCenterButton;

//iubox bg
@property (weak) IBOutlet NSColorWell *bgColorWell;

//iutext property
@property (weak) IBOutlet NSComboBox *fontNameComboBox;
@property (weak) IBOutlet NSComboBox *fontWeightComboBox;
@property (weak) IBOutlet NSComboBox *fontSizeComboBox;
@property (weak) IBOutlet NSColorWell *fontColorWell;
@property (weak) IBOutlet NSSegmentedControl *fontAlignSegmentedControl;

//font controller
@property (weak) LMFontController *fontController;


@end

@implementation BBPropertyToolBarVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        _fontController = [LMFontController sharedFontController];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //default binding
    //frame
    [self outlet:_xTextField bind:NSValueBinding livePositionStorageProperty:@"x"];
    [self outlet:_yTextField bind:NSValueBinding livePositionStorageProperty:@"y"];
    [self outlet:_wTextField bind:NSValueBinding liveStyleStorageProperty:@"w"];
    [self outlet:_hTextField bind:NSValueBinding liveStyleStorageProperty:@"h"];
    
    [self outlet:_verticalCenterButton bind:NSValueBinding property:@"enableVCenter"];
    [self outlet:_horizontalCenterButton bind:NSValueBinding property:@"enableHCenter"];
    
    //bg color
    [self outlet:_bgColorWell bind:NSValueBinding liveStyleStorageProperty:@"bgColor"];
    
    //text binding
    [self outlet:_fontNameComboBox bind:NSValueBinding liveStyleStorageProperty:@"fontName"];
    [self outlet:_fontWeightComboBox bind:NSValueBinding liveStyleStorageProperty:@"fontWeight"];
    [self outlet:_fontSizeComboBox bind:NSValueBinding liveStyleStorageProperty:@"fontSize"];
    [self outlet:_fontColorWell bind:NSValueBinding liveStyleStorageProperty:@"fontColor"];
    [self outlet:_fontAlignSegmentedControl bind:NSSelectedIndexBinding liveStyleStorageProperty:@"fontAlign"];
    
}

- (IBAction)clickUnitButton:(id)sender {
    NSButton *clickedUnitButton = sender;
    //change from pixel to percent
    if([clickedUnitButton state] == NSOnState){
        //FIXME
        //connect to JSManager and get percent frame
    }
    //change from percent to pixel
    else{
        
    }
}

- (IBAction)clickNilBgColorButton:(id)sender {
    [self.liveStyleStorage beginTransaction:self];
    self.liveStyleStorage.bgColor = nil;
    [self.liveStyleStorage commitTransaction:self];
}



@end
