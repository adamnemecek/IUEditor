//
//  BBQuickWidgetVC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 5..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBQuickWidgetVC.h"
#import "BBNewPageLayoutWC.h"

#import "IUBoxes.h"

@interface BBQuickWidgetVC ()

@property (weak) IBOutlet NSButton *firstWidgetButton;
@property (weak) IBOutlet NSButton *secondWidgetButton;
@property (weak) IBOutlet NSButton *thirdWidgetButton;
@property (weak) IBOutlet NSButton *forthWidgetButton;
@property (weak) IBOutlet NSButton *fifthWidgetButton;

@end

@implementation BBQuickWidgetVC{
    BBNewPageLayoutWC *_pageLayoutWC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)dealloc{
    JDSectionInfoLog(IULogDealloc, @"");
}

- (IBAction)clickNewIUBoxButton:(id)sender {
}

- (IBAction)clickNewSectionButton:(id)sender {
    if([[_iuController.content firstObject] isKindOfClass:[IUPage class]]){
        //allocation new section
        IUSection *newSection = [[IUSection alloc] initWithPreset];

        //add section to pageContent
        IUPage *currentPage = [_iuController.content firstObject];
        [currentPage.pageContent addIU:newSection error:nil];
        
        //reload controller
        [self.iuController setSelectedObject:newSection];
    }
}
- (IBAction)clickNewPageButton:(id)sender {
    if (_pageLayoutWC == nil){
        _pageLayoutWC = [[BBNewPageLayoutWC alloc] initWithWindowNibName:[BBNewPageLayoutWC className]];
        _pageLayoutWC.pageController = self.pageController;
    }
    
    [self.view.window beginSheet:_pageLayoutWC.window completionHandler:^(NSModalResponse returnCode){
    }];
}
- (IBAction)clickNewClassButton:(id)sender {
    if(self.classController.selectedObjects.count > 0){
        IUClass *newClass = [[IUClass alloc] initWithPreset];
        [self.classController addObject:newClass];
        
    }
}

@end
