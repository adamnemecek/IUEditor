//
//  BBNewPageLayoutWC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 19..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBNewPageLayoutWC.h"
#import "IUPage.h"
#import "IUIdentifierManager.h"

@interface BBNewPageLayoutWC ()

@property (strong) IBOutlet NSArrayController *layoutArrayController;
@property (weak) IBOutlet NSTextField *pageNameTextField;

@end

@implementation BBNewPageLayoutWC

- (void)windowDidLoad {
    [super windowDidLoad];

    //load layout
    NSString *layoutPath = [[NSBundle mainBundle] pathForResource:@"pageLayout" ofType:@"plist"];
    NSArray *layoutArray = [NSArray arrayWithContentsOfFile:layoutPath];
    [_layoutArrayController setContent:layoutArray];

}

- (IBAction)clickChooseLayoutButton:(id)sender {
    NSDictionary *layoutDictionary = [[_layoutArrayController selectedObjects] firstObject];
    
    //aloc new IUPage
    IUPageLayout layoutCode = [[layoutDictionary objectForKey:@"id"] intValue];
    IUPage *newPage = [[IUPage alloc] initWithPresetWithLayout:layoutCode header:nil footer:nil sidebar:nil];
    
    //alloc new name
    NSString *pageName = [_pageNameTextField stringValue];
    if(pageName && pageName.length > 0){
        IUIdentifierManager *manager = [IUIdentifierManager managerForMainWindow];
        BOOL isSuccess = [manager replaceIdentifier:newPage.htmlID withIdentifier:pageName];
        if(isSuccess){
            newPage.htmlID = pageName;
            newPage.name = pageName;
        }
    }
    //add new page to parent through page controller
    [self.pageController addObject:newPage];

    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
}
- (IBAction)clickCancelButton:(id)sender{
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseCancel];
    
}

@end
