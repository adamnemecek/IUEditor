//
//  LMFontPreferenceVC.m
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 5. 28..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMPreferenceFontVC.h"
#import "IUFontController.h"

@interface LMPreferenceFontVC ()

@property IUFontController *fontController;
@property (strong) IBOutlet NSDictionaryController *fontListDC;

@end

@implementation LMPreferenceFontVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib{
    _fontController = [IUFontController sharedFontController];
    [_fontListDC bind:NSContentDictionaryBinding toObject:_fontController withKeyPath:@"fontDict" options:nil];
}


@end
