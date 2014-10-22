//
//  LMPropertyIUWebMovieVC.m
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 4. 18..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMPropertyIUWebMovieVC.h"

@interface LMPropertyIUWebMovieVC ()

@property (weak) IBOutlet NSTextField *webMovieSourceTF;
@property (weak) IBOutlet NSMatrix *autoplayMatrix;
@property (weak) IBOutlet NSButton *loopButton;

@end

@implementation LMPropertyIUWebMovieVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib{
    
    [self outlet:_webMovieSourceTF bind:NSValueBinding property:@"movieLink"];
    [self outlet:_autoplayMatrix bind:NSSelectedIndexBinding property:@"playType"];
    [self outlet:_loopButton bind:NSValueBinding property:@"enableLoop"];

}


@end
