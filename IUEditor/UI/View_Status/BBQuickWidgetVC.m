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

@property (weak) IBOutlet NSMatrix *quickWidgetMatrix;
@property (nonatomic) NSArray *quickWidgetArray;
@end

@implementation BBQuickWidgetVC{
    BBNewPageLayoutWC *_pageLayoutWC;
    NSString *_currentClassName;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set default quick widgets
    self.quickWidgetArray = @[@"IUBox", @"IUText", @"IUImage", @"IUTransition", @"IUCenterBox"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectWidget:) name:IUNotificationNewIUCreatedByCanvas object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectWidget:) name:IUWidgetLibrarySelectionDidChangeNotification object:self.view.window];

}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    JDSectionInfoLog(IULogDealloc, @"");
}

#pragma mark - iu widgets

- (void)setQuickWidgetArray:(NSArray *)quickWidgetArray{
    _quickWidgetArray = quickWidgetArray;
    [quickWidgetArray enumerateObjectsUsingBlock:^(NSString *className, NSUInteger idx, BOOL *stop) {
        NSButtonCell *cell = [_quickWidgetMatrix cellAtRow:0 column:idx];
        [cell setImage:[NSClassFromString(className) navigationImage]];
        [cell setRepresentedObject:className];
        [cell setImageScaling:NSImageScaleNone];
    }];
}

- (IBAction)clickQuickWidgetMatrix:(id)sender {
    NSString *className = [[_quickWidgetMatrix selectedCell] representedObject];
    if([className isEqualToString:_currentClassName]){
        [self deselectWidgetMatrix];
        [[NSNotificationCenter defaultCenter] postNotificationName:IUWidgetLibrarySelectionDidChangeNotification object:self.view.window userInfo:@{IUWidgetLibrarySender:self}];

    }
    else{
        [self clearColorWidgetMatrix];
        _currentClassName = className;
        [[_quickWidgetMatrix selectedCell] setBackgroundColor:[NSColor rgbColorRed:50 green:100 blue:180 alpha:1]];
        [[NSNotificationCenter defaultCenter] postNotificationName:IUWidgetLibrarySelectionDidChangeNotification object:self.view.window userInfo:@{IUWidgetLibraryKey:className, IUWidgetLibrarySender:self}];
    }

}

- (void)clearColorWidgetMatrix{
    NSArray *cellArray = [_quickWidgetMatrix cells];
    for(NSButtonCell *cell in cellArray){
        [cell setBackgroundColor:[NSColor clearColor]];
    }
}

- (void)deselectWidgetMatrix{
    [_quickWidgetMatrix deselectAllCells];
    [self clearColorWidgetMatrix];
    _currentClassName = nil;
}

- (void)deselectCurrentWidget:(NSNotification *)notification{
    [self deselectWidgetMatrix];
}

//call when select widget from other VCs
- (void)selectWidget:(NSNotification *)notification{
    if([notification.name isEqualToString:IUNotificationNewIUCreatedByCanvas]){
        [self deselectWidgetMatrix];
    }
    else if([notification.name isEqualToString:IUWidgetLibrarySelectionDidChangeNotification]){
        id sender = [notification.userInfo objectForKey:IUWidgetLibrarySender];
        if([sender isNotEqualTo:self]){
            [self deselectWidgetMatrix];
            NSString *className = [notification.userInfo objectForKey:IUWidgetLibraryKey];
            if(className){
                _currentClassName = className;
                if([self.quickWidgetArray containsString:className]){
                    NSInteger index = [self.quickWidgetArray indexOfObject:className];
                    [self.quickWidgetMatrix selectCellAtRow:0 column:index];
                    [[_quickWidgetMatrix selectedCell] setBackgroundColor:[NSColor rgbColorRed:50 green:100 blue:180 alpha:1]];
                }
            }
        }
    }
}

#pragma mark sheet, section

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
