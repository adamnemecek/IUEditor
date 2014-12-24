//
//  LMDebugSourceWC.m
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 6. 3..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMDebugSourceWC.h"
#import "IUProject.h"

@interface LMDebugSourceWC ()
@property (weak) IBOutlet NSSearchField *searchField;
@property (strong) IBOutlet NSTextFinder *textFinder;
@property (unsafe_unretained) IBOutlet NSTextView *codeTextView;
@end

@implementation LMDebugSourceWC{
    NSRange currentFindRange;
}


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
    
    [_codeTextView setSelectedTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [NSColor highlightColor], NSBackgroundColorAttributeName,
      [NSColor blackColor], NSForegroundColorAttributeName,
      nil]];
    
}

- (void)showCurrentSource:(id)sender{
    NSString *htmlSource =  [(DOMHTMLElement *)[[[[_canvasVC webCanvasView] mainFrame] DOMDocument] documentElement] outerHTML];
    [self setCurrentSource:htmlSource];
    [self showWindow:sender];
}
- (void)setCurrentSource:(NSString *)source{
    [_codeTextView setString:source];
}

- (IBAction)searchField:(id)sender {
    NSString *searchString = [sender stringValue];
    currentFindRange = [[_codeTextView string] rangeOfString:searchString];
    [self showSearch];
    [self setColoringToSearcinString];
}

- (void)setColoringToSearcinString{
    
    NSString *searchString = [_searchField stringValue];
    NSString *wholeString = [_codeTextView string];

    NSRange findRange = [wholeString rangeOfString:searchString];
    NSMutableArray *selecteRanges = [NSMutableArray array];
    while(findRange.location != NSNotFound){
        [selecteRanges addObject:[NSValue valueWithRange:findRange]];
        
        NSUInteger start = findRange.length + findRange.location;
        findRange =  [wholeString rangeOfString:searchString options:NSCaseInsensitiveSearch range:NSMakeRange(start, wholeString.length -start)];
        
    }
    if(selecteRanges.count > 0){
        [_codeTextView setSelectedRanges:selecteRanges];
    }
    else{
        [_codeTextView setSelectedRange:NSMakeRange(0, 0)];
    }
}

- (IBAction)previousSearch:(id)sender {
    NSString *wholeString = [_codeTextView string];

    if(currentFindRange.location == NSNotFound){
        currentFindRange = NSMakeRange(wholeString.length, 0);
    }
    
    
    NSString *searchString = [_searchField stringValue];
    currentFindRange = [wholeString rangeOfString:searchString options:NSCaseInsensitiveSearch|NSBackwardsSearch range:NSMakeRange(0, currentFindRange.location)];
    [self showSearch];
    
}
- (IBAction)nextSearch:(id)sender {
    if(currentFindRange.location == NSNotFound){
        currentFindRange = NSMakeRange(0, 0);
    }
    
    NSString *searchString = [_searchField stringValue];
    NSString *wholeString = [_codeTextView string];
    NSUInteger start = currentFindRange.length + currentFindRange.location;
    currentFindRange =  [wholeString rangeOfString:searchString options:NSCaseInsensitiveSearch range:NSMakeRange(start, wholeString.length -start)];
    [self showSearch];
    
}


- (void)showSearch{
    if(currentFindRange.location != NSNotFound){
        [_codeTextView showFindIndicatorForRange:currentFindRange];
    }
}

#pragma mark - button
- (IBAction)openAsAFile:(id)sender {
    NSString *buildPath = [_canvasVC.sheet.project absoluteBuildPath];

    if ([[NSFileManager defaultManager] fileExistsAtPath:buildPath] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:buildPath withIntermediateDirectories:NO attributes:nil error:nil];
    }

    //debug_html
    NSString *debugFileName= [[_canvasVC.sheet.name stringByAppendingString:@"_debug"] stringByAppendingPathExtension:@"html"];
    NSString *filePath = [buildPath stringByAppendingPathComponent:debugFileName];
    
    if ([[_codeTextView string] writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil] == NO){
        NSAssert(0, @"write fail");
    }
    
    [[NSWorkspace sharedWorkspace] openFile:filePath];
    
    
}


@end
