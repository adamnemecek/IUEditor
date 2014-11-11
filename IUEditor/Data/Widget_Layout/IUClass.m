//
//  IUComponent.m
//  IUEditor
//
//  Created by JD on 3/17/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUClass.h"
#import "IUProject.h"
#import "IUImport.h"

@implementation IUClass{
    NSMutableArray *_referenceImports;
}

#pragma mark - class attributes

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"ic_comp"];
}

#pragma mark - Initialize

- (id)initWithProject:(id <IUProjectProtocol>)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    if(self){
        [self.undoManager disableUndoRegistration];
        _referenceImports = [NSMutableArray array];
        
        [self initializeDefaultCSSWithProject:project option:options];
        
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

- (void)initializeDefaultCSSWithProject:(id <IUProjectProtocol>)project option:(NSDictionary *)option{
    NSString *type = [option objectForKey:kClassType];
    
    
    IUBox *titleBox = [[IUBox alloc] initWithProject:project options:option];
    [titleBox.css setValue:@(140) forTag:IUCSSTagPixelWidth forViewport:IUCSSDefaultViewPort];
    [titleBox.css setValue:@(34) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];
    [titleBox.css setValue:@(43) forTag:IUCSSTagPixelY forViewport:IUCSSDefaultViewPort];
    [titleBox.css setValue:@(24) forTag:IUCSSTagFontSize forViewport:IUCSSDefaultViewPort];
    [titleBox.css setValue:@(IUAlignCenter) forTag:IUCSSTagTextAlign forViewport:IUCSSDefaultViewPort];
    [titleBox.css setValue:[NSColor rgbColorRed:153 green:153 blue:153 alpha:1] forTag:IUCSSTagFontColor forViewport:IUCSSDefaultViewPort];
    [titleBox.css setValue:nil forTag:IUCSSTagBGColor forViewport:IUCSSDefaultViewPort];
    [titleBox.css setValue:@"Helvetica" forTag:IUCSSTagFontName forViewport:IUCSSDefaultViewPort];
    
    titleBox.positionType = IUPositionTypeAbsolute;
    titleBox.enableHCenter = YES;
    
    
    if([type isEqualToString:IUClassHeader]){
        [self.css eradicateTag:IUCSSTagPixelWidth];
        [self.css setValue:@(YES) forTag:IUCSSTagWidthUnitIsPercent forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(100) forTag:IUCSSTagPercentWidth forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(120) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];
        [self.css setValue:[NSColor rgbColorRed:50 green:50 blue:50 alpha:1] forTag:IUCSSTagBGColor forViewport:IUCSSDefaultViewPort];
       
        titleBox.textType = IUTextTypeH1;
        [titleBox.mqData setValue:@"Header Area" forTag:IUMQDataTagInnerHTML forViewport:IUCSSDefaultViewPort];
        
        [self addIU:titleBox error:nil];
        
    }
    else if([type isEqualToString:IUClassFooter]){
        [self.css eradicateTag:IUCSSTagPixelWidth];
        [self.css setValue:@(YES) forTag:IUCSSTagWidthUnitIsPercent forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(100) forTag:IUCSSTagPercentWidth forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(120) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];
        
        [titleBox.mqData setValue:@"Footer Area" forTag:IUMQDataTagInnerHTML forViewport:IUCSSDefaultViewPort];
        [self addIU:titleBox error:nil];

        
    }
    else if([type isEqualToString:IUClassSidebar]){
        [self.css eradicateTag:IUCSSTagPixelWidth];
        [self.css setValue:@(YES) forTag:IUCSSTagWidthUnitIsPercent forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(100) forTag:IUCSSTagPercentWidth forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(YES) forTag:IUCSSTagHeightUnitIsPercent forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(100) forTag:IUCSSTagPercentHeight forViewport:IUCSSDefaultViewPort];
        [titleBox.css setValue:@(12) forTag:IUCSSTagFontSize forViewport:IUCSSDefaultViewPort];

        [titleBox.mqData setValue:@"Sidebar Area" forTag:IUMQDataTagInnerHTML forViewport:IUCSSDefaultViewPort];        
        [self addIU:titleBox error:nil];

    }
    
    [self.project.identifierManager registerIUs:@[titleBox]];

}
- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder{
    self =  [super awakeAfterUsingCoder:aDecoder];
    [self.undoManager disableUndoRegistration];

    _referenceImports = [[aDecoder decodeObjectForKey:@"referenceImport"] mutableCopy];
    NSArray *copy = [_referenceImports copy];
    NSInteger index = [copy count] - 1;
    for (id object in [copy reverseObjectEnumerator]) {
        if ([_referenceImports indexOfObject:object inRange:NSMakeRange(0, index)] != NSNotFound) {
            [_referenceImports removeObjectAtIndex:index];
        }
        index--;
    }

    [self.undoManager enableUndoRegistration];
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_referenceImports forKey:@"referenceImport"];
}


-(BOOL)canChangeWidthByUserInput{
    return YES;
}

-(BOOL)canChangeHeightByUserInput{
    return YES;
}

- (void)addReference:(IUImport*)import{
    if([_referenceImports containsObject:import] == NO){
        [_referenceImports addObject:import];
    }
}
- (void)removeReference:(IUImport*)import{
    [_referenceImports removeObject:import];
}

- (NSArray*)references{
    return [_referenceImports copy];
}

- (void)updateCSS{
    [super updateCSS];
    for(IUImport *import in _referenceImports){
        [import updateCSS];
    }
}


@end
