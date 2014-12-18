//
//  BBProjectPreferenceWC.m
//  IUEditor
//
//  Created by seungmi on 2014. 12. 18..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBProjectPreferenceWC.h"

#import "BBDefaultProjectPreferenceVC.h"

@interface BBProjectPreferenceWC ()


@property (weak) IBOutlet NSTableView *preferenceTableView;

@end

@implementation BBProjectPreferenceWC{
    BBDefaultProjectPreferenceVC *_defaultProjectPreferenceVC;
    
    NSMutableArray *_preferenceVCArray;
}


- (id)initWithWindowNibName:(NSString *)windowNibName{
    self = [super initWithWindowNibName:windowNibName];
    if(self){
        
        _preferenceVCArray = [NSMutableArray array];
        
        //add preference VCs
        _defaultProjectPreferenceVC = [[BBDefaultProjectPreferenceVC alloc] initWithNibName:[BBDefaultProjectPreferenceVC className] bundle:nil];
        [_preferenceVCArray addObject:_defaultProjectPreferenceVC];
        
    }
    return self;
}


- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)setProject:(IUProject *)project{
    _project = project;
    _defaultProjectPreferenceVC.project = project;
}
- (void)setResourceRootItem:(IUResourceRootItem *)resourceRootItem{
    _resourceRootItem = resourceRootItem;
    _defaultProjectPreferenceVC.resourceRootItem = resourceRootItem;
}

#pragma mark - table view

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return _preferenceVCArray.count;
}
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    return [[_preferenceVCArray objectAtIndex:row] view];
}
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return [[[_preferenceVCArray objectAtIndex:row] view] frame].size.height;
}

#pragma mark - sheet control
- (IBAction)clickOkButton:(id)sender{
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
}

- (IBAction)clickCancelButton:(id)sender{
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseCancel];
}


@end
