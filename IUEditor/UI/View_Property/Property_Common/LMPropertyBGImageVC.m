
//
//  LMPropertyBGImageVC.m
//  IUEditor
//
//  Created by JD on 4/5/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "LMPropertyBGImageVC.h"
#import "IUImage.h"

@interface LMPropertyBGImageVC ()

@property (weak) IBOutlet NSComboBox *imageNameComboBox;
@property (weak) IBOutlet NSTextField *xPositionTF;
@property (weak) IBOutlet NSTextField *yPositionTF;

@property (weak) IBOutlet NSSegmentedControl *sizeSegementControl;

@property (weak) IBOutlet NSButton *repeatBtn;
@property (weak) IBOutlet NSButton *fitButton;
@property (weak) IBOutlet NSSegmentedControl *positionHSegmentedControl;
@property (weak) IBOutlet NSSegmentedControl *positionVSegmentedControl;
@property (weak) IBOutlet NSButton *digitPositionBtn;


@property BOOL fullSize;

@end

@implementation LMPropertyBGImageVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self loadView];
    }
    return self;
}


- (void)setController:(IUController *)controller{
    [super setController:controller];
    NSDictionary *bgEnableBindingOption = [NSDictionary
                                           dictionaryWithObjects:@[NSIsNotNilTransformerName]
                                           forKeys:@[NSValueTransformerNameBindingOption]];

    NSDictionary *noRepeatBindingOption = [NSDictionary
                                           dictionaryWithObjects:@[[NSNumber numberWithBool:NO], NSNegateBooleanTransformerName]
                                           forKeys:@[NSRaisesForNotApplicableKeysBindingOption, NSValueTransformerNameBindingOption]];
    
    
#pragma mark - image
    _imageNameComboBox.delegate = self;
    
    [_imageNameComboBox bind:NSContentBinding toObject:self withKeyPath:@"resourceManager.imageFiles" options:IUBindingDictNotRaisesApplicable];
    [self outlet:_imageNameComboBox bind:NSValueBinding property:@"imageName"];
    [self outlet:_imageNameComboBox bind:NSEnabledBinding cssTag:IUCSSTagBGGradient options:IUBindingNegationAndNotRaise];

    
    [self outlet:_fitButton bind:NSEnabledBinding cssTag:IUCSSTagWidthUnitIsPercent options:IUBindingNegationAndNotRaise];
    [self outlet:_fitButton bind:@"enabled2" cssTag:IUCSSTagHeightUnitIsPercent options:IUBindingNegationAndNotRaise];
    [self outlet:_fitButton bind:@"enabled3" property:@"shouldCompileWidth"];
    [self outlet:_fitButton bind:@"enabled4" property:@"shouldCompileHeight"];
    [self outlet:_fitButton bind:@"enabled5" cssTag:IUCSSTagBGGradient options:IUBindingNegationAndNotRaise];
    
#pragma mark - size, repeat

    [self outlet:_sizeSegementControl bind:NSSelectedIndexBinding cssTag:IUCSSTagBGSize];
    [self outlet:_sizeSegementControl bind:NSEnabledBinding property:@"imageName" options:bgEnableBindingOption];
    [self outlet:_sizeSegementControl bind:@"enabled2" cssTag:IUCSSTagBGGradient options:IUBindingNegationAndNotRaise];
    [self outlet:_sizeSegementControl bind:@"enabled3" property:@"shouldCompileImagePositionInfo"];
    
    
    [self outlet:_repeatBtn bind:NSValueBinding cssTag:IUCSSTagBGRepeat options:noRepeatBindingOption];
    [self outlet:_repeatBtn bind:NSEnabledBinding property:@"imageName" options:bgEnableBindingOption];
    [_repeatBtn bind:@"enabled2" toObject:self withKeyPath:@"fullSize" options:IUBindingNegationAndNotRaise];
    [self outlet:_repeatBtn bind:@"enabled3" cssTag:IUCSSTagBGGradient options:IUBindingNegationAndNotRaise];
    [self outlet:_repeatBtn bind:@"enabled4" property:@"shouldCompileImagePositionInfo"];


    [self addObserverForCSSTag:IUCSSTagBGSize options:0 context:@"size"];
    

    
#pragma mark - position
    
    
    [self outlet:_positionHSegmentedControl bind:NSSelectedIndexBinding cssTag:IUCSSTagBGHPosition];
    [self outlet:_positionVSegmentedControl bind:NSSelectedIndexBinding cssTag:IUCSSTagBGVPosition];

    [self outlet:_digitPositionBtn bind:NSValueBinding cssTag:IUCSSTagEnableBGCustomPosition];
    [self outlet:_digitPositionBtn bind:NSEnabledBinding property:@"imageName" options:bgEnableBindingOption];

    
    [_digitPositionBtn bind:@"enabled2" toObject:self withKeyPath:@"fullSize" options:IUBindingNegationAndNotRaise];
    [self outlet:_digitPositionBtn bind:@"enabled3" cssTag:IUCSSTagBGGradient options:IUBindingNegationAndNotRaise];
    [self outlet:_digitPositionBtn bind:@"enabled4" property:@"shouldCompileImagePositionInfo"];

    [self outlet:_xPositionTF bind:NSValueBinding cssTag:IUCSSTagBGXPosition];
    [self outlet:_yPositionTF bind:NSValueBinding cssTag:IUCSSTagBGYPosition];
    
    
#pragma mark - enable position
    //position Segement 1
    [self outlet:_positionHSegmentedControl bind:NSEnabledBinding property:@"imageName" options:bgEnableBindingOption];
    [self outlet:_positionVSegmentedControl bind:NSEnabledBinding property:@"imageName" options:bgEnableBindingOption];

    [self outlet:_positionHSegmentedControl bind:@"enabled2" cssTag:IUCSSTagEnableBGCustomPosition options:IUBindingNegationAndNotRaise];
    [self outlet:_positionVSegmentedControl bind:@"enabled2" cssTag:IUCSSTagEnableBGCustomPosition options:IUBindingNegationAndNotRaise];
    
    [_positionHSegmentedControl bind:@"enabled3" toObject:self withKeyPath:@"fullSize" options:IUBindingNegationAndNotRaise];
    [_positionVSegmentedControl bind:@"enabled3" toObject:self withKeyPath:@"fullSize" options:IUBindingNegationAndNotRaise];
    
    
    [self outlet:_positionHSegmentedControl bind:@"enabled4" cssTag:IUCSSTagBGGradient options:IUBindingNegationAndNotRaise];
    [self outlet:_positionVSegmentedControl bind:@"enabled4" cssTag:IUCSSTagBGGradient options:IUBindingNegationAndNotRaise];

    //position TF
    
    [self outlet:_xPositionTF bind:NSEnabledBinding property:@"imageName" options:bgEnableBindingOption];
    [self outlet:_yPositionTF bind:NSEnabledBinding property:@"imageName" options:bgEnableBindingOption];

    [self outlet:_xPositionTF bind:@"enabled2" cssTag:IUCSSTagEnableBGCustomPosition];
    [self outlet:_yPositionTF bind:@"enabled2" cssTag:IUCSSTagEnableBGCustomPosition];

    [_xPositionTF bind:@"enabled3" toObject:self withKeyPath:@"fullSize" options:IUBindingNegationAndNotRaise];
    [_yPositionTF bind:@"enabled3" toObject:self withKeyPath:@"fullSize" options:IUBindingNegationAndNotRaise];

    
    [self outlet:_xPositionTF bind:@"enabled4" cssTag:IUCSSTagBGGradient options:IUBindingNegationAndNotRaise];
    [self outlet:_yPositionTF bind:@"enabled4" cssTag:IUCSSTagBGGradient options:IUBindingNegationAndNotRaise];

    [self outlet:_xPositionTF bind:@"enabled5" property:@"shouldCompileImagePositionInfo"];
    [self outlet:_yPositionTF bind:@"enabled5" property:@"shouldCompileImagePositionInfo"];
    
    
}
- (void)prepareDealloc{
    [_imageNameComboBox unbind:NSContentBinding];
}

- (void)dealloc{
    [self removeObserverForCSSTag:IUCSSTagBGSize];
    [JDLogUtil log:IULogDealloc string:@"LMPropertyBGImage"];
}


-(void)sizeContextDidChange:(NSDictionary *)dictionary{
    IUBGSizeType selectedtype = (IUBGSizeType)[_sizeSegementControl selectedSegment];
    if(selectedtype == IUBGSizeTypeFull){
        [self setValue:@(1) forCSSTag:IUCSSTagBGVPosition];
        [self setValue:@(1) forCSSTag:IUCSSTagBGHPosition];
        self.fullSize = YES;
    }
    else{
        self.fullSize = NO;
    }
}

#pragma mark - combobox

- (void)controlTextDidChange:(NSNotification *)obj{
    for (IUImage *image in self.controller.selectedObjects) {
        if ([image isKindOfClass:[IUImage class]]) {
            id value = [_imageNameComboBox stringValue];
            [image setImageName:value];
        }
    }
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification{
    for (IUImage *image in self.controller.selectedObjects) {
        if ([image isKindOfClass:[IUImage class]]) {
            id value = [_imageNameComboBox objectValueOfSelectedItem];
            [image setImageName:value];
        }
    }
}

#pragma mark - IBAction


- (IBAction)performFitToImage:(id)sender { // Fit to Image button function
    NSAssert(_resourceManager, @"");

    //image filename
    NSString *filename = _imageNameComboBox.stringValue;
    if(filename == nil || filename.length == 0){
        return;
    }

    NSInteger   height= 0;
    NSInteger   width = 0;
    
    //get image size
    // when file is empty, image fit doesn't make any difference.
    if([filename isHTTPURL]){
        //setting size to IU
        NSArray *selectedObjects = self.controller.selectedObjects;
        for (IUBox *box in selectedObjects) {
            width =  [[box.delegate callWebScriptMethod:@"getImageWidth" withArguments:@[filename]] integerValue];
            height =  [[box.delegate callWebScriptMethod:@"getImageHeight" withArguments:@[filename]] integerValue];
        }
    }
    else if(filename != nil){
    //getting path
        IUResourceFile *file = [_resourceManager resourceFileWithName:filename];
        NSString *path = file.absolutePath;

        if (file == nil) {
            
            path = [[NSBundle mainBundle] pathForImageResource:[filename lastPathComponent]];
        }
        
        NSArray * imageReps = [NSBitmapImageRep imageRepsWithContentsOfFile:path];
        
        width = 0;
        height = 0;
        
        for (NSImageRep * imageRep in imageReps) {
            if ([imageRep pixelsWide] > width){
                width = [imageRep pixelsWide];
            }
            if ([imageRep pixelsHigh] > height){
                height = [imageRep pixelsHigh];
            }
        }
    }
    
    
    //setting size to IU
    NSArray *selectedObjects = self.controller.selectedObjects;
    
    for (IUBox *box in selectedObjects) {
        [box startFrameMoveWithUndoManager];
        [box.css setValue:@(width) forTag:IUCSSTagPixelWidth];
        [box.css setValue:@(height) forTag:IUCSSTagPixelHeight];
        [box endFrameMoveWithUndoManager];
        [box updateCSS];
    }
}

@end
