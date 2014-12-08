//
//  BBImagePropertyVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 8..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBImagePropertyVC.h"

@interface BBImagePropertyVC ()

/* children view */
@property (strong) IBOutlet NSView *imageView;
@property (strong) IBOutlet NSView *bgImageView;
@property (strong) IBOutlet NSView *bgPositionView;

/* image/IUImage */
@property (weak) IBOutlet NSComboBox *imageComboBox;
@property (weak) IBOutlet NSTextField *imageAltText;

/* background image */
@property (weak) IBOutlet NSComboBox *bgImageComboBox;
@property (weak) IBOutlet NSSegmentedControl *bgImageSizeSegmentedControl;
@property (weak) IBOutlet NSPopUpButton *bgImageRepeatPopupButton;
@property (weak) IBOutlet NSPopUpButton *bgImageFixedPopupButton;

/* background image position */
@property (weak) IBOutlet NSSegmentedControl *bgImageHPositionSegmentedControl;
@property (weak) IBOutlet NSSegmentedControl *bgImageVPositionSegmentedControl;
@property (weak) IBOutlet NSTextField *bgImageXPositionTextField;
@property (weak) IBOutlet NSTextField *bgImageYPositionTextField;

@end

@implementation BBImagePropertyVC{
    NSArray *_childrenViewArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _childrenViewArray = @[_imageView, _bgImageView, _bgPositionView];
    
    //binding
    //image
    [_imageComboBox bind:NSContentBinding toObject:self withKeyPath:@"resourceRootItem.imageResourceItems" options:IUBindingDictNotRaisesApplicableAndContinuousUpdate];
    [self outlet:_imageComboBox bind:NSValueBinding property:@"imagePath"];
    [self outlet:_imageAltText bind:NSValueBinding property:@"altText"];
    
    //background Image
    [_bgImageComboBox bind:NSContentBinding toObject:self withKeyPath:@"resourceRootItem.imageResourceItems" options:IUBindingDictNotRaisesApplicableAndContinuousUpdate];
    [self outlet:_bgImageComboBox bind:NSValueBinding liveStyleStorageProperty:@"imageName"];
    [self outlet:_bgImageSizeSegmentedControl bind:NSSelectedIndexBinding liveStyleStorageProperty:@"imageSizeType"];
    [self outlet:_bgImageRepeatPopupButton bind:NSSelectedIndexBinding liveStyleStorageProperty:@"imageRepeat"];
    [self outlet:_bgImageFixedPopupButton bind:NSSelectedIndexBinding liveStyleStorageProperty:@"imageAttachment"];
    
    //bg image position
    [self outlet:_bgImageHPositionSegmentedControl bind:NSSelectedIndexBinding liveStyleStorageProperty:@"imageHPosition"];
    [self outlet:_bgImageVPositionSegmentedControl bind:NSSelectedIndexBinding liveStyleStorageProperty:@"imageVPosition"];
    
    [self outlet:_bgImageXPositionTextField bind:NSValueBinding liveStyleStorageProperty:@"imageX"];
    [self outlet:_bgImageYPositionTextField bind:NSValueBinding liveStyleStorageProperty:@"imageY"];
    
}

#pragma mark - button action

- (IBAction)clickEnableXYPositionButton:(id)sender {
    
    [self.liveStyleStorage beginTransaction:self];
    
    if([sender state] == NSOnState){
        //x,y position을 사용할 경우에는 string position사용하지 않음.(V/H position)
        self.liveStyleStorage.imageVPosition = nil;
        self.liveStyleStorage.imageHPosition = nil;
    }
    else{
        //x,y position을 사용하지 않을 경우에는 지금까지 사용했던 값을 nil로.
        self.liveStyleStorage.imageX = nil;
        self.liveStyleStorage.imageY = nil;
    }
    
    [self.liveStyleStorage commitTransaction:self];
}

- (IBAction)clickFitToImageButton:(id)sender {
    
    //FIXME : connect to js manager
    NSSize currentImageSize = NSZeroSize;
    [self.liveStyleStorage beginTransaction:self];
    
    [self.liveStyleStorage setWidth:@(currentImageSize.width) unit:@(IUFrameUnitPixel)];
    [self.liveStyleStorage setHeight:@(currentImageSize.height) unit:@(IUFrameUnitPixel)];
    
    [self.liveStyleStorage commitTransaction:self];
    
    
}


#pragma mark - table view

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [_childrenViewArray count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    return [_childrenViewArray objectAtIndex:row];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    NSView *currentView = [_childrenViewArray objectAtIndex:row];
    return currentView.frame.size.height;
}


@end
