//
//  LMNewPageWC.m
//  IUEditor
//
//  Created by seungmi on 2014. 9. 16..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMNewPageWC.h"


@interface LMNewPageWC ()

@property (strong) IBOutlet NSArrayController *layoutArrayController;
@property (weak) IBOutlet NSCollectionView *layoutCollectionView;

@end

@implementation LMNewPageWC


- (instancetype)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    NSString *layoutPath = [[NSBundle mainBundle] pathForResource:@"pageLayout" ofType:@"plist"];
    NSArray *layoutArray = [NSArray arrayWithContentsOfFile:layoutPath];
    [_layoutArrayController addObjects:layoutArray];

}

- (IBAction)chooseLayout:(id)sender {
    NSDictionary *dict = [[_layoutArrayController selectedObjects] firstObject];
    int returnCode = [[dict objectForKey:@"id"] intValue]+NSModalResponseOK;
    [self.window.sheetParent endSheet:self.window returnCode:returnCode];
}
- (void)cancelOperation:(id)sender{
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseCancel];

}

@end
