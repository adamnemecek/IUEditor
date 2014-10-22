//
//  LMPropertyIUPageVC.m
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 5. 12..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMPropertyIUPageVC.h"
#import "IUPage.h"

@interface LMPropertyIUPageVC ()

@property (weak) IBOutlet NSTextField *metaImageTF;

@property (weak) IBOutlet NSTextField *titleTF;
@property (weak) IBOutlet NSTextField *keywordsTF;
@property (unsafe_unretained) IBOutlet NSTextView *descriptionTV;
@property (unsafe_unretained) IBOutlet NSTextView *extraCodeTF;

@end

@implementation LMPropertyIUPageVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self loadView];
    }
    return self;
}


-(void)setController:(IUController *)controller{
    [super setController:controller];
    

    [self outlet:_titleTF bind:NSValueBinding property:@"title"];
    [self outlet:_keywordsTF bind:NSValueBinding property:@"keywords"];
    [self outlet:_extraCodeTF bind:NSValueBinding property:@"extraCode"];
    [self outlet:_metaImageTF bind:NSValueBinding property:@"metaImage"];
    [self outlet:_descriptionTV bind:NSValueBinding property:@"desc"];
    
}

@end
