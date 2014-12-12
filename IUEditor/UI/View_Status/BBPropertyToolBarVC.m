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
@property (weak) IBOutlet NSPopUpButton *fontWeightPopUpButton;
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
    [self outlet:_xTextField bind:NSValueBinding cascadingPositionStorageProperty:@"x"];
    [self outlet:_yTextField bind:NSValueBinding cascadingPositionStorageProperty:@"y"];
    [self outlet:_wTextField bind:NSValueBinding cascadingStyleStorageProperty:@"width"];
    [self outlet:_hTextField bind:NSValueBinding cascadingStyleStorageProperty:@"height"];
    
    [self outlet:_verticalCenterButton bind:NSValueBinding property:@"enableVCenter"];
    [self outlet:_horizontalCenterButton bind:NSValueBinding property:@"enableHCenter"];
    
    //bg color
    [self outlet:_bgColorWell bind:NSValueBinding cascadingStyleStorageProperty:@"bgColor"];
    
    //text binding
    [self outlet:_fontNameComboBox bind:NSValueBinding cascadingStyleStorageProperty:@"fontName"];
//    [self outlet:_fontWeightPopUpButton bind:NSValueBinding cascadingStyleStorageProperty:@"fontWeight"];

    [self outlet:_fontSizeComboBox bind:NSValueBinding cascadingStyleStorageProperty:@"fontSize"];
    [self outlet:_fontColorWell bind:NSValueBinding cascadingStyleStorageProperty:@"fontColor"];
    [self outlet:_fontAlignSegmentedControl bind:NSSelectedIndexBinding cascadingStyleStorageProperty:@"fontAlign"];
    
}

- (NSRect)percentFrameForIU:(IUBox *)iu{
    NSString *frameJS = [NSString stringWithFormat:@"$('#%@').iuPercentFrame()", iu.htmlID];
    id currentValue = [self.jsManager evaluateWebScript:frameJS];
    NSRect percentFrame = NSMakeRect([[currentValue valueForKey:@"left"] floatValue],
                                     [[currentValue valueForKey:@"top"] floatValue],
                                     [[currentValue valueForKey:@"width"] floatValue],
                                     [[currentValue valueForKey:@"height"] floatValue]
                                     );
    
    
    return percentFrame;
}

- (NSRect)pixelFrameForIU:(IUBox *)iu{
    NSString *frameJS = [NSString stringWithFormat:@"$('#%@').iuPosition()", iu.htmlID];
    id currentValue = [self.jsManager evaluateWebScript:frameJS];
    NSRect pixelFrame = NSMakeRect([[currentValue valueForKey:@"left"] floatValue],
                                   [[currentValue valueForKey:@"top"] floatValue],
                                   [[currentValue valueForKey:@"width"] floatValue],
                                   [[currentValue valueForKey:@"height"] floatValue]
                                   );
    
    
    return pixelFrame;
}

- (IBAction)clickUnitButton:(id)sender {
    NSButton *clickedUnitButton = sender;
    //change from pixel to percent
    if([clickedUnitButton state] == NSOnState){
        
        for(IUBox *box in self.iuController.selectedObjects){
            NSRect percentFrame = [self percentFrameForIU:box];
            [box.cascadingPositionStorage beginTransaction:self];
            [box.cascadingStyleStorage commitTransaction:self];


            if([sender isEqualTo:_xUnitButton]){
                [box.cascadingPositionStorage setX:@(percentFrame.origin.x) unit:@(IUFrameUnitPercent)];
            }
            else if([sender isEqualTo:_yUnitButton]){
                [box.cascadingPositionStorage setY:@(percentFrame.origin.y) unit:@(IUFrameUnitPercent)];
            }
            else if([sender isEqualTo:_wUnitButton]){
                [box.cascadingStyleStorage setWidth:@(percentFrame.size.width) unit:@(IUFrameUnitPercent)];
            }
            else if([sender isEqualTo:_hUnitButton]){
                [box.cascadingStyleStorage setHeight:@(percentFrame.size.height) unit:@(IUFrameUnitPercent)];
            }
            
            [box.cascadingStyleStorage commitTransaction:self];
            [box.cascadingPositionStorage commitTransaction:self];
        }
    }
    //change from percent to pixel
    else{
        for(IUBox *box in self.iuController.selectedObjects){
            NSRect pixelFrame = [self pixelFrameForIU:box];
            [box.cascadingPositionStorage beginTransaction:self];
            [box.cascadingStyleStorage commitTransaction:self];
            
            
            if([sender isEqualTo:_xUnitButton]){
                [box.cascadingPositionStorage setX:@(pixelFrame.origin.x) unit:@(IUFrameUnitPixel)];
            }
            else if([sender isEqualTo:_yUnitButton]){
                [box.cascadingPositionStorage setY:@(pixelFrame.origin.y) unit:@(IUFrameUnitPixel)];
            }
            else if([sender isEqualTo:_wUnitButton]){
                [box.cascadingStyleStorage setWidth:@(pixelFrame.size.width) unit:@(IUFrameUnitPixel)];
            }
            else if([sender isEqualTo:_hUnitButton]){
                [box.cascadingStyleStorage setHeight:@(pixelFrame.size.height) unit:@(IUFrameUnitPixel)];
            }
            
            [box.cascadingStyleStorage commitTransaction:self];
            [box.cascadingPositionStorage commitTransaction:self];
        }
    }
}

- (IBAction)clickNilBgColorButton:(id)sender {
    [self.cascadingStyleStorage beginTransaction:self];
    self.cascadingStyleStorage.bgColor = nil;
    [self.cascadingStyleStorage commitTransaction:self];
}

- (IBAction)clickFontNameComboBox:(id)sender {
    //TODO: update fontWeight
}

- (void)updateFontWeigtComboBox{
    
}


@end
