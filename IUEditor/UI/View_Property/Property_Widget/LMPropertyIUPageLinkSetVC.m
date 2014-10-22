//
//  IUPageLinkSetVC.m
//  IUEditor
//
//  Created by jd on 5/8/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "LMPropertyIUPageLinkSetVC.h"

@interface LMPropertyIUPageLinkSetVC ()
@property (weak) IBOutlet NSTextField *pageCountTF;
@property (weak) IBOutlet NSTextField *marginTF;
@property (weak) IBOutlet NSColorWell *defaultColorWell;
@property (weak) IBOutlet NSColorWell *selectedColorWell;
@property (weak) IBOutlet NSSegmentedControl *alignSC;

@end

@implementation LMPropertyIUPageLinkSetVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib{
    [self outlet:_pageCountTF bind:NSValueBinding property:@"pageCountVariable"];
    [self outlet:_marginTF bind:NSValueBinding property:@"buttonMargin"];
    [self outlet:_defaultColorWell bind:NSValueBinding property:@"defaultButtonBGColor"];
    [self outlet:_selectedColorWell bind:NSValueBinding property:@"selectedButtonBGColor"];
    [self outlet:_alignSC bind:NSSelectedIndexBinding property:@"pageLinkAlign"];
    
}

- (IBAction)clearDefaultColorPressed:(id)sender {
    [self setValue:nil forIUProperty:@"defaultButtonBGColor"];
}
- (IBAction)clearSelectedColorPressed:(id)sender {
    [self setValue:nil forIUProperty:@"selectedButtonBGColor"];
}
@end
