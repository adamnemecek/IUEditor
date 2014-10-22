//
//  LMProjectPropertyWC.m
//  IUEditor
//
//  Created by seungmi on 2014. 7. 16..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMProjectPropertyWC.h"
#import "IUDjangoProject.h"
#import "IUWordpressProject.h"

@interface LMProjectPropertyWC ()
@property (weak)  IUProject *project;

@property (weak) IBOutlet NSTableView *tableV;
@property (weak) IBOutlet NSLayoutConstraint *heightConstraint;


//default
@property (strong) IBOutlet NSView *defaultView;
@property (weak) IBOutlet NSComboBox *faviconComboBox;
@property (weak) IBOutlet NSTextField *authorTF;
@property (weak) IBOutlet NSTextField *buildPathTF;
@property (weak) IBOutlet NSTextField *buildResourcePathTF;
@property (weak) IBOutlet NSButton *enableMinWidthCheckBox;

//django
@property (strong) IBOutlet NSView *djangoView;
@property (weak) IBOutlet NSTextField *djangoPortTF;
@property (weak) IBOutlet NSTextField *managyPyTF;

//wordpress
@property (strong) IBOutlet NSView *wordpressView;
@property (weak) IBOutlet NSTextField *wordPortTF;
@property (weak) IBOutlet NSTextField *documentRootTF;
@property (weak) IBOutlet NSTextField *uriTF;
@property (weak) IBOutlet NSTextField *tagTF;
@property (weak) IBOutlet NSTextField *versionTF;
@property (unsafe_unretained) IBOutlet NSTextView *themeDescTV;

@end

@implementation LMProjectPropertyWC{
    NSMutableArray *viewArray;
}
- (id)initWithWindowNibName:(NSString *)windowNibName withIUProject:(IUProject *)project{
    self = [super initWithWindowNibName:windowNibName];
    if (self) {
        _project = project;
        viewArray = [NSMutableArray array];
    }
    return self;

}

- (void)windowDidLoad
{
    [super windowDidLoad];
    NSAssert(_project, @"should have project");
    
    //project property
    [_authorTF bind:NSValueBinding toObject:self withKeyPath:@"project.author" options:IUBindingDictNotRaisesApplicableAndContinuousUpdate];
    [_faviconComboBox bind:NSContentBinding toObject:self withKeyPath:@"project.resourceManager.imageFiles" options:IUBindingDictNotRaisesApplicableAndContinuousUpdate];
    [_faviconComboBox bind:NSValueBinding toObject:self withKeyPath:@"project.favicon" options:IUBindingDictNotRaisesApplicableAndContinuousUpdate];
    [_enableMinWidthCheckBox bind:NSValueBinding toObject:self withKeyPath:@"project.enableMinWidth" options:IUBindingDictNotRaisesApplicableAndContinuousUpdate];
    [_buildPathTF bind:NSValueBinding toObject:self withKeyPath:@"project.buildPath" options:IUBindingDictNotRaisesApplicableAndContinuousUpdate];
    [_buildResourcePathTF bind:NSValueBinding toObject:self withKeyPath:@"project.buildResourcePath" options:IUBindingDictNotRaisesApplicableAndContinuousUpdate];
    
    
    [viewArray addObject:_defaultView];
    //project
    if([self.project isKindOfClass:[IUDjangoProject class]]){
        [viewArray addObject:_djangoView];
        
        [_djangoPortTF bind:NSValueBinding toObject:self withKeyPath:@"project.port" options:IUBindingDictNumberAndNotRaisesApplicable];
        [_managyPyTF bind:NSValueBinding toObject:self withKeyPath:@"project.managePyPath" options:IUBindingDictNotRaisesApplicableAndContinuousUpdate];
    }
    else if([self.project isKindOfClass:[IUWordpressProject class]]){
        [viewArray addObject:_wordpressView];
        
        [_wordPortTF bind:NSValueBinding toObject:self withKeyPath:@"project.port" options:IUBindingDictNumberAndNotRaisesApplicable];
        [_documentRootTF bind:NSValueBinding toObject:self withKeyPath:@"project.documentRoot" options:IUBindingDictNotRaisesApplicableAndContinuousUpdate];
        
        [_uriTF bind:NSValueBinding toObject:self withKeyPath:@"project.uri" options:IUBindingDictNotRaisesApplicableAndContinuousUpdate];
        [_tagTF bind:NSValueBinding toObject:self withKeyPath:@"project.tags" options:IUBindingDictNotRaisesApplicableAndContinuousUpdate];
        [_versionTF bind:NSValueBinding toObject:self withKeyPath:@"project.version" options:IUBindingDictNotRaisesApplicableAndContinuousUpdate];

        [_themeDescTV bind:NSValueBinding toObject:self withKeyPath:@"project.themeDescription" options:IUBindingDictNotRaisesApplicableAndContinuousUpdate];

    }
    
    [self setTableHeight];
    
}

- (void)setTableHeight{
    CGFloat height = 0;
    for(NSView *view in viewArray){
        height += view.frame.size.height;
    }
    [_heightConstraint setConstant:height];
}

- (IBAction)pressOKBtn:(id)sender {
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
}

- (IBAction)findBuildPath:(id)sender {
    NSURL *url = [[JDFileUtil util] openDirectoryByNSOpenPanelWithTitle:@"Select Build Folder"];
    _project.buildPath = [url path];
}

- (IBAction)findBuildResourcePath:(id)sender {
    NSURL *url = [[JDFileUtil util] openDirectoryByNSOpenPanelWithTitle:@"Select Build Resource Folder"];
    _project.buildResourcePath = [url path];
}


- (void)cancelOperation:(id)sender{
    [self pressOKBtn:self];
}

#pragma mark - tableView
#pragma mark tableView

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    id v = [viewArray objectAtIndex:row];
    return v;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView{
    return [viewArray count];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    if([viewArray count] == 0){
        return 0.1;
    }
    
    return [(NSView*)[viewArray objectAtIndex:row] frame].size.height;
}

- (IBAction)resetBuildPath:(id)sender {
    [self.project resetBuildPath];
}



@end
