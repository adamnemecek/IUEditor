//
//  LMPropertyIUFBLikeVC.m
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 4. 18..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMPropertyIUFBLikeVC.h"

@interface LMPropertyIUFBLikeVC ()

@property (weak) IBOutlet NSTextField *likePageTF;
@property (weak) IBOutlet NSButton *friendFaceBtn;
@property (weak) IBOutlet NSPopUpButton *colorschemePopupBtn;

@end

@implementation LMPropertyIUFBLikeVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib{
    
    [self outlet:_likePageTF bind:NSValueBinding property:@"likePage"];
    [self outlet:_friendFaceBtn bind:NSValueBinding property:@"showFriendsFace"];
    [self outlet:_colorschemePopupBtn bind:NSSelectedIndexBinding property:@"colorscheme"];

    //enable
    NSDictionary *enableBindingOption = [NSDictionary
                                         dictionaryWithObjects:@[[NSNumber numberWithBool:NO], NSIsNotNilTransformerName]
                                           forKeys:@[NSRaisesForNotApplicableKeysBindingOption, NSValueTransformerNameBindingOption]];

    [self outlet:_friendFaceBtn bind:NSEnabledBinding property:@"likePage" options:enableBindingOption];

}

@end
