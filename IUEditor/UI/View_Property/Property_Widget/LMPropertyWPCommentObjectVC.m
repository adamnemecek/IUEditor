//
//  LMPropertyWPCommentObjectVC.m
//  IUEditor
//
//  Created by jd on 9/3/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "LMPropertyWPCommentObjectVC.h"

@interface LMPropertyWPCommentObjectVC ()
@property (weak) IBOutlet NSPopUpButton *typeB;

@end

@implementation LMPropertyWPCommentObjectVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib{
    [self outlet:_typeB bind:NSSelectedIndexBinding property:@"objType"];
}

@end
