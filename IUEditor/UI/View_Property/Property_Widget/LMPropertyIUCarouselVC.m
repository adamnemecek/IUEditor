//
//  LMPropertyIUcarousel.m
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 4. 18..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMPropertyIUCarouselVC.h"
#import "JDOutlineCellView.h"

@interface LMPropertyIUCarouselVC ()

//for outlineView
@property (strong) IBOutlet JDOutlineCellView *carouselMainView;
@property (strong) IBOutlet JDOutlineCellView *arrowView;
@property (strong) IBOutlet JDOutlineCellView *controlView;

//set attributes
@property (weak) IBOutlet NSTextField *countTF;
@property (weak) IBOutlet NSStepper *countStepper;

//timer
@property (weak) IBOutlet NSMatrix *autoplayMatrix;
@property (weak) IBOutlet NSTextField *timeTF;
@property (weak) IBOutlet NSStepper *timeStpper;

//prev, next
@property (weak) IBOutlet NSMatrix *arrowControlMatrix;
@property (weak) IBOutlet NSComboBox *leftImageComboBox;
@property (weak) IBOutlet NSComboBox *rightImageComboBox;
@property (weak) IBOutlet NSTextField *leftImageXTF;
@property (weak) IBOutlet NSTextField *leftImageYTF;
@property (weak) IBOutlet NSStepper *leftImageXStpper;
@property (weak) IBOutlet NSStepper *leftImageYStepper;
@property (weak) IBOutlet NSTextField *rightImageXTF;
@property (weak) IBOutlet NSStepper *rightImageXStpper;
@property (weak) IBOutlet NSTextField *rightImageYTF;
@property (weak) IBOutlet NSStepper *rightImageYStpper;

//pager
@property (weak) IBOutlet NSSegmentedControl *controllerSegmentedControl;
@property (weak) IBOutlet NSColorWell *selectColor;
@property (weak) IBOutlet NSColorWell *deselectColor;
@property (weak) IBOutlet NSSlider *pagerPositionSlidr;


@end

@implementation LMPropertyIUCarouselVC{
    BOOL awaked;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}


-(void)awakeFromNib{
    //children
    NSDictionary *numberBindingOption = @{NSRaisesForNotApplicableKeysBindingOption:@(NO),NSValueTransformerNameBindingOption:@"JDNilToZeroTransformer"};
    
    [self outlet:_countStepper bind:NSValueBinding property:@"count" options:numberBindingOption];
    [self outlet:_countTF bind:NSValueBinding property:@"count" options:numberBindingOption];
    

    //auto setting
    [self outlet:_autoplayMatrix bind:NSSelectedIndexBinding property:@"autoplay"];
    [self outlet:_timeTF bind:NSValueBinding property:@"timer" options:numberBindingOption];
    [self outlet:_timeStpper bind:NSValueBinding property:@"timer" options:numberBindingOption];
    
    //prev, next
    [self outlet:_arrowControlMatrix bind:NSSelectedIndexBinding cssTag:IUCSSTagCarouselArrowDisable];

    //image
    [_leftImageComboBox bind:NSContentBinding toObject:self withKeyPath:@"resourceRootItem.imageResourceItems" options:IUBindingDictNotRaisesApplicable];
    [_rightImageComboBox bind:NSContentBinding toObject:self withKeyPath:@"resourceRootItem.imageResourceItems" options:IUBindingDictNotRaisesApplicable];
    [self outlet:_leftImageComboBox bind:NSValueBinding property:@"leftArrowImage"];
    [self outlet:_rightImageComboBox bind:NSValueBinding property:@"rightArrowImage"];
   
    //position-left
    [self outlet:_leftImageXStpper bind:NSValueBinding property:@"leftX" options:numberBindingOption];
    [self outlet:_leftImageXTF bind:NSValueBinding property:@"leftX" options:numberBindingOption];
    [self outlet:_leftImageYStepper bind:NSValueBinding property:@"leftY" options:numberBindingOption];
    [self outlet:_leftImageYTF bind:NSValueBinding property:@"leftY" options:numberBindingOption];
    
    //position-right
    [self outlet:_rightImageXStpper bind:NSValueBinding property:@"rightX" options:numberBindingOption];
    [self outlet:_rightImageXTF bind:NSValueBinding property:@"rightX" options:numberBindingOption];
    [self outlet:_rightImageYStpper bind:NSValueBinding property:@"rightY" options:numberBindingOption];
    [self outlet:_rightImageYTF bind:NSValueBinding property:@"rightY" options:numberBindingOption];
    
    //pager
    [self outlet:_controllerSegmentedControl bind:NSSelectedIndexBinding property:@"controlType"];
    [self outlet:_selectColor bind:NSValueBinding property:@"selectColor"];
    [self outlet:_deselectColor bind:NSValueBinding property:@"deselectColor"];
    [self outlet:_pagerPositionSlidr bind:NSValueBinding property:@"pagerPosition"];
    
}

- (void)prepareDealloc{
    [_leftImageComboBox unbind:NSContentBinding];
    [_rightImageComboBox unbind:NSContentBinding];
}


#pragma mark outlineview



- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item{
    if(item == nil){
        return 3;
    }
    else{
        if([[item identifier] isEqualToString:@"title"]){
            return 1;
        }
        return 0;
    }
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item{
    if(item == nil){
        switch (index) {
            case 0:
                return _carouselMainView;
            case 1:
                return _arrowView.titleV;
            case 2:
                return _controlView.titleV;
            default:
                return nil;
        }
    }
    else{
        if([item isEqualTo:_arrowView.titleV]){
            return _arrowView.contentV;
        }
        else if([item isEqualTo:_controlView.titleV]){
            return _controlView.contentV;
        }
        else{
            return nil;
        }
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item{
    //root or title V
    if(item == nil || [[item identifier] isEqualToString:@"title"]){
        return YES;
    }
    
    return NO;
}


- (id)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item{
    return item;
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(NSView *)item{
    NSAssert(item != nil, @"");
    CGFloat height = item.frame.size.height;
    if(height <=0){
        height = 0.1;
    }
    return height;
    
}

- (IBAction)outlineViewClicked:(NSOutlineView *)sender{
    id clickItem = [sender itemAtRow:[sender clickedRow]];
    
    [sender isItemExpanded:clickItem] ?
    [sender.animator collapseItem:clickItem] : [sender.animator expandItem:clickItem];
}


- (IBAction)timeStepper:(id)sender {
}
@end
