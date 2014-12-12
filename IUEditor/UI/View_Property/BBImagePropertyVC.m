//
//  BBImagePropertyVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 8..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBImagePropertyVC.h"
#import "IUImage.h"

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
    //content binding through imageArrayController in xib
    [self outlet:_imageComboBox bind:NSValueBinding property:@"imagePath"];
    [self outlet:_imageAltText bind:NSValueBinding property:@"altText"];
    
    //background Image
    //content binding through imageArrayController in xib
    [self outlet:_bgImageComboBox bind:NSValueBinding cascadingStyleStorageProperty:@"imageName"];
    [self outlet:_bgImageSizeSegmentedControl bind:NSSelectedIndexBinding cascadingStyleStorageProperty:@"imageSizeType"];
    [self outlet:_bgImageRepeatPopupButton bind:NSSelectedIndexBinding cascadingStyleStorageProperty:@"imageRepeat"];
    [self outlet:_bgImageFixedPopupButton bind:NSSelectedIndexBinding cascadingStyleStorageProperty:@"imageAttachment"];
    
    //bg image position
    [self outlet:_bgImageHPositionSegmentedControl bind:NSSelectedIndexBinding cascadingStyleStorageProperty:@"imageHPosition"];
    [self outlet:_bgImageVPositionSegmentedControl bind:NSSelectedIndexBinding cascadingStyleStorageProperty:@"imageVPosition"];
    
    [self outlet:_bgImageXPositionTextField bind:NSValueBinding cascadingStyleStorageProperty:@"imageX"];
    [self outlet:_bgImageYPositionTextField bind:NSValueBinding cascadingStyleStorageProperty:@"imageY"];
    
}

#pragma mark - button action

- (IBAction)clickEnableXYPositionButton:(id)sender {
    
    [self.cascadingStyleStorage beginTransaction:self];
    
    if([sender state] == NSOnState){
        //x,y position을 사용할 경우에는 string position사용하지 않음.(V/H position)
        self.cascadingStyleStorage.imageVPosition = nil;
        self.cascadingStyleStorage.imageHPosition = nil;
    }
    else{
        //x,y position을 사용하지 않을 경우에는 지금까지 사용했던 값을 nil로.
        self.cascadingStyleStorage.imageX = nil;
        self.cascadingStyleStorage.imageY = nil;
    }
    
    [self.cascadingStyleStorage commitTransaction:self];
}

- (NSSize)getImageSizeAtPath:(NSString *)path{
    NSString *frameJS = [NSString stringWithFormat:@"getImageSize('%@')", path];
    id currentValue = [self.jsManager evaluateWebScript:frameJS];
    NSSize imageSize = NSMakeSize([[currentValue valueForKey:@"width"] floatValue],
                                   [[currentValue valueForKey:@"height"] floatValue]
                                   );
    
    
    return imageSize;
}


- (IBAction)clickFitToImageButton:(id)sender {
    
    for(IUBox *box in self.iuController.selectedObjects){
        NSString *imagePath;
        if([box isKindOfClass:[IUImage class]]){
            imagePath = ((IUImage *)box).imagePath;
        }
        else{
            imagePath = box.cascadingStyleStorage.imageName;
        }
        NSSize currentImageSize = [self getImageSizeAtPath:imagePath];
        [self.cascadingStyleStorage beginTransaction:self];
    
        [self.cascadingStyleStorage setWidth:@(currentImageSize.width) unit:@(IUFrameUnitPixel)];
        [self.cascadingStyleStorage setHeight:@(currentImageSize.height) unit:@(IUFrameUnitPixel)];
    
        [self.cascadingStyleStorage commitTransaction:self];
    }
    
    
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
