//
//  LMWidgetLibraryVC.m
//  IUEditor
//
//  Created by JD on 3/25/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "LMWidgetLibraryVC.h"
#import "IUBox.h"
#import "LMWC.h"
#import "LMHelpPopover.h"
#import "LMGeneralObject.h"

@interface LMWidgetLibraryVC ()

@property (weak) IBOutlet NSTabView *collectionTabV;

@property (weak) IBOutlet NSTabView *primaryTabView;
@property (weak) IBOutlet NSTabView *secondaryTabView;
@property (weak) IBOutlet NSTabView *PGTabView;
@property (weak) IBOutlet NSTabView *WPTabView;

@property (weak) IBOutlet NSButton *listB;
@property (weak) IBOutlet NSButton *iconB;

@property (weak) IBOutlet NSTextField *wpDisableTF;

//select widget
@property (weak) IBOutlet NSMatrix *widgetTabMatrix;
@property (weak) IBOutlet NSButtonCell *wpButtonCell;


//widget array
@property  NSMutableArray *primaryWidgets, *secondaryWidgets, *PGWidgets, *WPWidgets;

@end

@implementation LMWidgetLibraryVC{
    NSArray *widgetProperties;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _primaryWidgets = [NSMutableArray array];
        _secondaryWidgets = [NSMutableArray array];
        _PGWidgets = [NSMutableArray array];
        _WPWidgets = [NSMutableArray array];
    }
    return self;
}

#pragma mark -init with LMWC

-(void)addWidgetProperties:(NSArray*)array{
    
    for(NSString *className in array){
        LMGeneralObject *object = [[LMGeneralObject alloc] init];
        object.title = className;
        
        Class iuclass = NSClassFromString(className);
        object.image = [iuclass classImage];
        object.shortDesc = [iuclass shortDescription];
        
        switch ([iuclass widgetType]) {
            case IUWidgetTypePrimary:
                [_primaryWidgets addObject:object];
                break;
            case IUWidgetTypeSecondary:
                [_secondaryWidgets addObject:object];
                break;
            case IUWidgetTypePG:
                [_PGWidgets addObject:object];
                break;
            case IUWidgetTypeWP:
                [_WPWidgets addObject:object];
                break;
                
            default:
                break;
        }
    }
    
    
}

- (void)setProject:(IUProject *)project{
    _project = project;
    [self addWidgetProperties:[[project class] widgetList]];
}

- (void)awakeFromNib{
    if(_project){
        if(_project.projectType != IUProjectTypeWordpress){
            [_wpButtonCell setTransparent:YES];
            [_wpButtonCell setEnabled:NO];
        }
    }
}

#pragma mark collectionview -drag
- (BOOL)collectionView:(NSCollectionView *)collectionView writeItemsAtIndexes:(NSIndexSet *)indexes toPasteboard:(NSPasteboard *)pasteboard{
    NSAssert(_project, @"");
    [_project.identifierManager resetUnconfirmedIUs];
    NSUInteger index = [indexes firstIndex];
    LMGeneralObject *object = [[collectionView itemAtIndex:index] representedObject];
    
    IUBox *obj = [[NSClassFromString(object.title) alloc] initWithProject:_project options:nil];
    if (obj == nil) {
    //    NSAssert(0, @"");
        JDErrorLog(@"objISNil");
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
    [pasteboard setData:data forType:kUTTypeIUType];
    
    /* note  ----------------------------------------------------
    /  please check obj.retainCount is <1> at current point     /
    / ----------------------------------------------------------*/

    
    LMWC *lmWC = [NSApp mainWindow].windowController;
    lmWC.pastedNewIU = obj;
    JDInfoLog([obj description], nil);
    
    return YES;
}


- (NSImage *)collectionView:(NSCollectionView *)collectionView draggingImageForItemsAtIndexes:(NSIndexSet *)indexes withEvent:(NSEvent *)event offset:(NSPointPointer)dragImageOffset{
    
    NSUInteger index = [indexes firstIndex];
    LMGeneralObject *object = [[collectionView itemAtIndex:index] representedObject];

    return [object image];
}



#pragma mark -
#pragma mark widget list - icon 

- (IBAction)clickListView:(id)sender{
    [_primaryTabView selectTabViewItemAtIndex:0];
    [_secondaryTabView selectTabViewItemAtIndex:0];
    [_PGTabView selectTabViewItemAtIndex:0];
    [_WPTabView selectTabViewItemAtIndex:0];
    
    [_listB setEnabled:NO];
    [_iconB setEnabled:YES];

}

- (IBAction)clickIconView:(id)sender{
    [_primaryTabView selectTabViewItemAtIndex:1];
    [_secondaryTabView selectTabViewItemAtIndex:1];
    [_PGTabView selectTabViewItemAtIndex:1];
    [_WPTabView selectTabViewItemAtIndex:1];
    
    [_listB setEnabled:NO];
    [_iconB setEnabled:YES];
}


- (IBAction)clickWidgetTabMatrix:(id)sender {
    NSInteger selectedIndex = [sender selectedRow];
    [_collectionTabV selectTabViewItemAtIndex:selectedIndex];
}

- (void)doubleClick:(id)sender{
    
    NSView *targetView = (id)sender;
    NSCollectionView *currentCollectionView = (NSCollectionView *)[targetView superview];
    if([currentCollectionView isKindOfClass:[NSCollectionView class]]){
        
        NSUInteger index = [[currentCollectionView selectionIndexes] firstIndex];
        LMGeneralObject *object = [[currentCollectionView itemAtIndex:index] representedObject];

            
        LMHelpPopover *popover = [LMHelpPopover sharedHelpPopover];
        
        if([object.title isStartWithPrefix:@"PG"]){
            [popover setType:LMPopoverTypeTextAndLargeVideo];
            [popover setVideoName:[@"PGGroup" stringByAppendingPathExtension:@"mp4"] title:object.title rtfFileName:[object.title stringByAppendingPathExtension:@"rtf"]];
            
        }
        else{
            NSString *moviePath = [[NSBundle mainBundle] pathForResource:object.title ofType:@"mp4"];
            if(moviePath){
                [popover setType:LMPopoverTypeTextAndVideo];
                [popover setVideoName:[object.title stringByAppendingPathExtension:@"mp4"] title:object.title rtfFileName:[object.title stringByAppendingPathExtension:@"rtf"]];
            }
            else{
                
                [popover setType:LMPopoverTypeTextAndImage];
                [popover setImage:object.image title:object.title subTitle:object.shortDesc rtfFileName:[object.title stringByAppendingPathExtension:@"rtf"]];
            }
        }
        [popover showRelativeToRect:[targetView bounds] ofView:sender preferredEdge:NSMinXEdge];
    }
    else{
        NSAssert(0, @"");
    }
    
}
@end
