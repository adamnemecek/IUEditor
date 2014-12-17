//
//  BBFBLikePropertyVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 17..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBFBLikePropertyVC.h"

@interface BBFBLikePropertyVC ()
@property (weak) IBOutlet NSTextField *urlTextField;
@property (weak) IBOutlet NSPopUpButton *colorSchemePopupButton;
@property (weak) IBOutlet NSButton *showFriendsFace;

@end

@implementation BBFBLikePropertyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self outlet:_urlTextField bind:NSValueBinding property:@"likePage"];
    [self outlet:_colorSchemePopupButton bind:NSSelectedIndexBinding property:@"colorscheme"];
    [self outlet:_showFriendsFace bind:NSValueBinding property:@"showFriendsFace"];
}

@end
