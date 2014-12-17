//
//  BBCarouselPropertyVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 17..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBCarouselPropertyVC.h"

@interface BBCarouselPropertyVC ()
@property (weak) IBOutlet NSTextField *countTextField;
@property (weak) IBOutlet NSStepper *countStepper;

@property (weak) IBOutlet NSMatrix *enableArrowMatrix;
@property (weak) IBOutlet NSTextField *arrowXTextField;
@property (weak) IBOutlet NSStepper *arrowXStepper;
@property (weak) IBOutlet NSSlider *arrowXSlider;
@property (weak) IBOutlet NSTextField *arrowYTextField;
@property (weak) IBOutlet NSStepper *arrowYStepper;
@property (weak) IBOutlet NSSlider *arrowYSlider;

@property (weak) IBOutlet NSComboBox *leftArrowImageComboBox;
@property (weak) IBOutlet NSComboBox *rightArrowImageComboBox;

@property (weak) IBOutlet NSSegmentedControl *controlTypeSegmentedControl;
@property (weak) IBOutlet NSColorWell *selectColorWell;
@property (weak) IBOutlet NSColorWell *deselectColorWell;
@property (weak) IBOutlet NSSlider *pagerPositionSlider;

@property (weak) IBOutlet NSMatrix *autoplayMatrix;
@property (weak) IBOutlet NSTextField *durationTextField;
@property (weak) IBOutlet NSStepper *durationStepper;

@end

@implementation BBCarouselPropertyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

@end
