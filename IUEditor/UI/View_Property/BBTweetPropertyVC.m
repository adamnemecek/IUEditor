//
//  BBTweetPropertyVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 17..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBTweetPropertyVC.h"

@interface BBTweetPropertyVC ()

@property (weak) IBOutlet NSTextField *urlTextField;
@property (unsafe_unretained) IBOutlet NSTextView *tweetTextTextView;
@property (weak) IBOutlet NSMatrix *sizeTypeMatrix;
@property (weak) IBOutlet NSPopUpButton *countTypePopUpButton;

@end

@implementation BBTweetPropertyVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self outlet:_urlTextField bind:NSValueBinding property:@"urlToTweet"];
    [self outlet:_tweetTextTextView bind:NSValueBinding property:@"tweetText"];
    [self outlet:_sizeTypeMatrix bind:NSSelectedIndexBinding property:@"sizeType"];
    [self outlet:_countTypePopUpButton bind:NSSelectedIndexBinding property:@"countType"];
}

@end
