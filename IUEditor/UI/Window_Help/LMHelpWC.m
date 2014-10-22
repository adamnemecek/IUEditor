//
//  LMHelpWC.m
//  IUEditor
//
//  Created by jd on 6/10/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "LMHelpWC.h"
#import <Quartz/Quartz.h>

static LMHelpWC *gHelpWC = nil;

@interface LMHelpWC ()

@property (weak) IBOutlet NSTabView *tabView;

@property (weak) IBOutlet WebView *webV;
@property (weak) IBOutlet PDFView *pdfV;
@property (weak) IBOutlet PDFThumbnailView *pdfThumbnailV;
@property (weak) IBOutlet NSTableView *pdfListTableView;

@property (strong) IBOutlet NSDictionaryController *pdfListDictController;
@property NSDictionary *pdfListDictionary;

@end

@implementation LMHelpWC{
    BOOL windowLoaded;
}

+ (LMHelpWC *)sharedHelpWC{
    if(gHelpWC == nil){
        gHelpWC = [[LMHelpWC alloc] initWithWindowNibName:[LMHelpWC class].className];
    }
    return gHelpWC;
}


- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        [self loadWindow];
        NSString *pdfFilePath = [[NSBundle mainBundle] pathForResource:@"help" ofType:@"plist"];
        _pdfListDictionary = [NSDictionary dictionaryWithContentsOfFile:pdfFilePath];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [_pdfListDictController setContent:_pdfListDictionary];
    
    [_pdfThumbnailV setMaximumNumberOfColumns:1];
    [_pdfThumbnailV setThumbnailSize:NSMakeSize(150, 100)];
    
    [_webV setPolicyDelegate:self];

    windowLoaded = YES;
    
}

- (void)showHelpDocument:(NSString*)fileName title:(NSString *)title{
    if (self.window == nil) {
        [self window];
    }
    [_tabView selectTabViewItemAtIndex:0];

    if([[fileName pathExtension] isEqualToString:@"pdf"]){
        NSURL *url = [[NSBundle mainBundle] URLForResource:[fileName stringByDeletingPathExtension] withExtension:@"pdf"];
        PDFDocument *doc = [[PDFDocument alloc] initWithURL:url];
        [self.pdfV setDocument:doc];
    }
    
    if(title){
        [[self window] setTitle:[NSString stringWithFormat:@"Manual For %@", title]];
    }
    else{
        [[self window] setTitle:@"Manual"];
    }
    
}

- (void)showHelpWebURL:(NSURL*)url withTitle:(NSString *)title{
    if (self.window == nil) {
        [self window];
    }
    
    self.window.title = title;
    
    [_tabView selectTabViewItemAtIndex:1];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [[self.webV mainFrame] loadRequest:request];
    [self.window makeKeyAndOrderFront:nil];
}


- (void)showFirstItem{
    [self showWindow:self];

    //select firstItem
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
    [_pdfListTableView selectRowIndexes:indexSet byExtendingSelection:NO];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification{
    NSString *key = [[_pdfListDictController selectedObjects][0] key];
    [self showHelpWindowWithKey:key];
}


- (void)showHelpWindowWithKey:(NSString *)key{
    [self showWindow:self];

    NSString *type = [_pdfListDictionary objectForKey:key][@"type"];
    
    if([type isEqualToString:@"pdf"]){
        
        NSString *fileName = [_pdfListDictionary objectForKey:key][@"pdf"];
        NSString *title= [_pdfListDictionary objectForKey:key][@"title"];
        
        [self showHelpDocument:fileName title:title];
    }
    else if([type isEqualToString:@"web"]){
        NSString *path = [_pdfListDictionary objectForKey:key][@"web"];
        NSString *title= [_pdfListDictionary objectForKey:key][@"title"];
        
        [self showHelpWebURL:[NSURL URLWithString:path] withTitle:title];
    }

}


#pragma mark -policy delegate
#if 0 // we do not open website at iueditor

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id < WebPolicyDecisionListener >)listener
{
    /*
     web에서 링크를 클릭했을 때 들어오는 actionInformation Dict
     WebActionButtonKey = 0;
     WebActionElementKey =     {
     WebElementDOMNode = "<DOMHTMLParagraphElement [P]: 0x10917c5a0 ''>";
     WebElementFrame = "<WebFrame: 0x60800001b520>";
     WebElementIsContentEditableKey = 0;
     WebElementIsInScrollBar = 0;
     WebElementIsSelected = 0;
     WebElementLinkIsLive = 1;
     WebElementLinkLabel = Recruit;
     WebElementLinkURL = "file:///Users/choiseungmi/IUProjTemp/myApp.iuproject/Index.html";
     WebElementTargetFrame = "<WebFrame: 0x60800001b520>";
     };
     WebActionModifierFlagsKey = 0;
     WebActionNavigationTypeKey = 0;
     WebActionOriginalURLKey = "file:///Users/choiseungmi/IUProjTemp/myApp.iuproject/Index.html"
     ;
     
     */
    NSDictionary *actionDict = [actionInformation objectForKey:WebActionElementKey];
    if(actionDict){
        NSURL *url = actionDict[@"WebElementLinkURL"];
        //Review : 링크가 help window 에서 열리기 위해서는 여기에 추가.
        if([[url host] isEqualToString:@"guide.iueditor.org"]){
            [listener use];
        }
        else{
            if(url){
                [[NSWorkspace sharedWorkspace] openURL:actionDict[@"WebElementLinkURL"]];
            }
            [listener ignore];
        }
    }
    else{
        [listener use];
    }
}

- (void)webView:(WebView *)webView decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id < WebPolicyDecisionListener >)listener
{
    NSDictionary *actionDict = [actionInformation objectForKey:WebActionElementKey];
    if(actionDict){
        NSURL *url = actionDict[@"WebElementLinkURL"];
        if(url){
            [[NSWorkspace sharedWorkspace] openURL:actionDict[@"WebElementLinkURL"]];
        }
        [listener ignore];
    }
    else{
        [listener use];
    }
}

#endif

@end
