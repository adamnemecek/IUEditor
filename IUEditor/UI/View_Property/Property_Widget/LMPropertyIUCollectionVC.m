//
//  LMPropertyIUCollectionVC.m
//  IUEditor
//
//  Created by jd on 4/29/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "LMPropertyIUCollectionVC.h"
#import "IUProject.h"

@interface LMPropertyIUCollectionVC ()

@property (weak) IBOutlet NSTextField *variableTF;

@property (weak) IBOutlet NSTextField *itemCountTF;
@property (weak) IBOutlet NSStepper *itemCountStepper;

@end

@implementation LMPropertyIUCollectionVC{
    IUProject *_project;
    NSInteger selectedSize, maxSize, largeSize;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self loadView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectMQSize:) name:IUNotificationMQSelectedWithInfo object:nil];
    }
    return self;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    if ([keyPath isEqualToString:@"selection"]) {
        [self updateCount];
    }
    else if( [[keyPath pathExtension] isEqualToString:@"defaultItemCount"]){
        [self updateCount];
    }

}



- (void)setController:(IUController *)controller{
    [super setController:controller];
    
    [self outlet:_variableTF bind:NSValueBinding property:@"collectionVariable"];

    //observing
    [self addObserverForProperty:@"defaultItemCount" options:0 context:nil];
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserverForProperty:@"defaultItemCount"];
}

- (void)setProject:(IUProject*)project{
    _project = project;
}



- (void)selectMQSize:(NSNotification *)notification{
    selectedSize = [[notification.userInfo objectForKey:IUNotificationMQSize] integerValue];
    largeSize = [[notification.userInfo objectForKey:IUNotificationMQLargerSize] integerValue];
    maxSize = [[notification.userInfo objectForKey:IUNotificationMQMaxSize] integerValue];
 
    [self updateCount];
}

- (void)updateCount{
    id value = [self valueForProperty:@"defaultItemCount"];

    if(value == NSMultipleValuesMarker || value == NSNotApplicableMarker || value == NSNoSelectionMarker){
        [_itemCountTF setStringValue:@""];
        [[_itemCountTF cell] setPlaceholderString:[NSString stringWithValueMarker:value]];
        return;
    }
    NSInteger defaultCount = [value integerValue];
    BOOL isToBeSetPlaceHolder;
    NSInteger selectedCount= -1;

    
    if(selectedSize == maxSize){
        isToBeSetPlaceHolder = NO;
        selectedCount = defaultCount;
    }
    else{
        //responsiveSetting 검사후에 없으면 default로 넣음.
        NSArray *responsiveSetting = [self valueForProperty:@"responsiveSetting"];
        
        for(NSDictionary *dict in responsiveSetting){
            NSInteger width = [[dict objectForKey:@"width"] integerValue];
            if(width == largeSize-1){
                selectedCount = [[dict objectForKey:@"count"] integerValue];
                break;
            }
        }
        
        //found responsive count
        if(selectedCount >=0){
            isToBeSetPlaceHolder = NO;
        }
        //there is no responsive count, set to default count
        else{
            isToBeSetPlaceHolder = YES;
        }
    }
    
    if(isToBeSetPlaceHolder){
        [_itemCountTF setStringValue:@""];
        [[_itemCountTF cell] setPlaceholderString:[NSString stringWithFormat:@"%ld", defaultCount]];
        [_itemCountStepper setIntegerValue:defaultCount];

    }
    else{
        [_itemCountTF setStringValue:[NSString stringWithFormat:@"%ld", selectedCount]];
        [[_itemCountTF cell] setPlaceholderString:@""];
        [_itemCountStepper setIntegerValue:selectedCount];

    }


}

#pragma mark -
- (IBAction)clickCountStepper:(id)sender {
    NSInteger count = [_itemCountStepper integerValue];
    [self setItemCount:count];
}
- (IBAction)clickItemCountTF:(id)sender {
    
    NSInteger count = [_itemCountTF integerValue];
    [self setItemCount:count];
}

- (void)setItemCount:(NSInteger)count{
    if(selectedSize == maxSize){
        [self setValue:@(count) forIUProperty:@"defaultItemCount"];
    }
    else{
        NSMutableArray *responsiveSetting = [[self valueForProperty:@"responsiveSetting"] mutableCopy];

        NSMutableArray *selectedDictArray = [NSMutableArray array];
        for(NSDictionary *dict in responsiveSetting){
            NSInteger width = [[dict objectForKey:@"width"] integerValue];
            if(width == largeSize-1){
                [selectedDictArray addObject:dict];
            }
        }
        for(NSDictionary *selectedDict in selectedDictArray){
            [responsiveSetting removeObject:selectedDict];
        }
        [responsiveSetting addObject:@{@"width":@(largeSize-1), @"count":@(count)}];
        
        [self setValue:responsiveSetting forIUProperty:@"responsiveSetting"];
    }
    [self updateCount];
}


@end
