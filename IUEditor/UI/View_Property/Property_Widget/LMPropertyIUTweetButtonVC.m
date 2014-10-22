//
//  LMPropertyIUTweetButtonVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 8. 5..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMPropertyIUTweetButtonVC.h"

@interface LMPropertyIUTweetButtonVC ()

@property (weak) IBOutlet NSTextField *urlTF;
@property (weak) IBOutlet NSPopUpButton *countTypePopupButton;
@property (weak) IBOutlet NSMatrix *sizeMatrix;
@property (weak) IBOutlet NSTextField *tweetTextTF;
@property (weak) IBOutlet NSMenuItem *verticalMenuItem;

@end

@implementation LMPropertyIUTweetButtonVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib{
    [self outlet:_urlTF bind:NSValueBinding property:@"urlToTweet"];
    [self outlet:_sizeMatrix bind:NSSelectedIndexBinding property:@"sizeType"];
    [self outlet:_tweetTextTF bind:NSValueBinding property:@"tweetText"];
    
    [self outlet:_countTypePopupButton bind:NSSelectedIndexBinding property:@"countType"];
    [self outlet:_verticalMenuItem bind:NSEnabledBinding property:@"enableLargeVertical"];
}




@end
