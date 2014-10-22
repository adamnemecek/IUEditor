//
//  LMAppearanceVC.m
//  IUEditor
//
//  Created by ChoiSeungmi on 2014. 4. 16..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMAppearanceVC.h"
#import "LMAppearanceFrameVC.h"
#import "LMPropertyBorderVC.h"
#import "LMAppearanceColorVC.h"
#import "LMPropertyFontVC.h"
#import "LMPropertyShadowVC.h"
#import "LMPropertyDisplayVC.h"

@interface LMAppearanceVC ()
@property (weak) IBOutlet NSOutlineView *outlineV;

@end

@implementation LMAppearanceVC{
    LMAppearanceFrameVC    *appearanceFrameVC;
    LMPropertyBorderVC  *propertyBorderVC;
    LMAppearanceColorVC *appearanceColorVC;
    LMPropertyFontVC    *appearanceFontVC;
    LMPropertyShadowVC  *propertyShadowVC;
    LMPropertyDisplayVC *propertyDisplayVC;
    LMPropertyBGImageVC *propertyBGImageVC;
    
    NSMutableArray *outlineVOrderArray;
}

- (NSString*)CSSBindingPath:(IUCSSTag)tag{
    return [@"controller.selection.css.effectiveTagDictionary." stringByAppendingString:tag];
}


- (void)dealloc{
    [JDLogUtil log:IULogDealloc string:@"ApperanceVC"];
}
- (void)prepareDealloc{
    [propertyBGImageVC prepareDealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //init VC
        appearanceFrameVC = [[LMAppearanceFrameVC alloc] initWithNibName:@"LMAppearanceFrameVC" bundle:nil];
        [appearanceFrameVC bind:@"controller" toObject:self withKeyPath:@"controller" options:nil];
        
        propertyBGImageVC = [[LMPropertyBGImageVC alloc] initWithNibName:@"LMPropertyBGImageVC" bundle:nil];
        [propertyBGImageVC bind:@"controller" toObject:self withKeyPath:@"controller" options:nil];
        [propertyBGImageVC bind:@"resourceManager" toObject:self withKeyPath:@"resourceManager" options:nil];
        
        propertyBorderVC = [[LMPropertyBorderVC alloc] initWithNibName:@"LMPropertyBorderVC" bundle:nil];
        [propertyBorderVC bind:@"controller" toObject:self withKeyPath:@"controller" options:nil];
        
        appearanceColorVC = [[LMAppearanceColorVC alloc] initWithNibName:@"LMAppearanceColorVC" bundle:nil];
        [appearanceColorVC bind:@"controller" toObject:self withKeyPath:@"controller" options:nil];
        
        appearanceFontVC = [[LMPropertyFontVC alloc] initWithNibName:@"LMPropertyFontVC" bundle:nil];
        [appearanceFontVC bind:@"controller" toObject:self withKeyPath:@"controller" options:nil];

        propertyShadowVC = [[LMPropertyShadowVC alloc] initWithNibName:@"LMPropertyShadowVC" bundle:nil];
        [propertyShadowVC bind:@"controller" toObject:self withKeyPath:@"controller" options:nil];
        
        propertyDisplayVC = [[LMPropertyDisplayVC alloc] initWithNibName:@"LMPropertyDisplayVC" bundle:nil];
        [propertyDisplayVC bind:@"controller" toObject:self withKeyPath:@"controller" options:nil];
        

        [self loadView];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self expandAll];
        });
        

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self expandAll];
        });

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self expandAll];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self expandAll];
        });
    }
    return self;
}

- (void)expandAll{
    JDTraceLog([self.outlineV description], nil );
    id item = [self.outlineV itemAtRow:1];
    [self.outlineV expandItem:item];
    item = [self.outlineV itemAtRow:3];
    [self.outlineV expandItem:item];
    item = [self.outlineV itemAtRow:5];
    [self.outlineV expandItem:item];
    item = [self.outlineV itemAtRow:7];
    [self.outlineV expandItem:item];
    item = [self.outlineV itemAtRow:9];
    [self.outlineV expandItem:item];

}
- (void)awakeFromNib{
    //make array
    outlineVOrderArray = [NSMutableArray array];
    [outlineVOrderArray addObject:appearanceFrameVC.view];
    [outlineVOrderArray addObject:appearanceColorVC.view];
    [outlineVOrderArray addObject:propertyBGImageVC.view];
    [outlineVOrderArray addObject:appearanceFontVC.view];
    [outlineVOrderArray addObject:propertyShadowVC.view];
    [outlineVOrderArray addObject:propertyBorderVC.view];
    [outlineVOrderArray addObject:propertyDisplayVC.view];
}

- (NSView *)contentViewOfTitleView:(NSView *)titleV{
    for(JDOutlineCellView *cellV in outlineVOrderArray){
        if( [cellV.titleV isEqualTo:titleV] ){
            return cellV.contentV;
        }
    }
    return nil;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item{
    if(item == nil){
        //root
        return outlineVOrderArray.count;
    }
    else{
        if([((JDOutlineCellView *)appearanceFrameVC.view).titleV isEqualTo:item]){
            return 0;
        }
        else if([((JDOutlineCellView *)propertyDisplayVC.view).titleV isEqualTo:item]){
            return 0;
        }
        else if([[item identifier] isEqualToString:@"title"]){
            return 1;
        }
        return 0;
    }
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item{
    if(item == nil){
        JDOutlineCellView *view = outlineVOrderArray[index];
        return view.titleV;
    }
    else{
        return [self contentViewOfTitleView:item];
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item{
    if([((JDOutlineCellView *)appearanceFrameVC.view).titleV isEqualTo:item]){
            return NO;
    }
    else if([((JDOutlineCellView *)propertyDisplayVC.view).titleV isEqualTo:item]){
        return 0;
    }

    //root or title V
    else if(item == nil || [[item identifier] isEqualToString:@"title"]){
        return YES;
    }

    return NO;
}


- (id)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item{
    return item;
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(NSView *)item{
    NSAssert(item != nil, @"");
    CGFloat height = item.frame.size.height;
    if(height <=0){
        height = 0.1;
    }
    return height;
    
}

- (IBAction)outlineViewClicked:(NSOutlineView *)sender{
    id clickItem = [sender itemAtRow:[sender clickedRow]];
    
    [sender isItemExpanded:clickItem] ?
    [sender.animator collapseItem:clickItem] : [sender.animator expandItem:clickItem];
}



@end
