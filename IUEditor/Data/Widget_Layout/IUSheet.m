//
//  IUSheet.h
//  IUEditor
//
//  Created by JD on 3/17/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUSheet.h"
#import "IUProject.h"

@implementation IUSheet

-(id)initWithProject:(IUProject *)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    if(self){
        [self.undoManager disableUndoRegistration];
        _ghostOpacity = 0.5;
        
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self.undoManager disableUndoRegistration];
        
        _ghostX = [aDecoder decodeFloatForKey:@"ghostX"];
        _ghostY = [aDecoder decodeFloatForKey:@"ghostY"];
        _ghostOpacity = [aDecoder decodeFloatForKey:@"ghostOpacity"];
        _ghostImageName = [aDecoder decodeObjectForKey:@"ghostImageName"];
        _group = [aDecoder decodeObjectForKey:@"group"];


        [self.undoManager enableUndoRegistration];
    }
    return self;
}
-(id)awakeAfterUsingCoder:(NSCoder *)aDecoder{
    [super awakeAfterUsingCoder:aDecoder];
    [self.undoManager disableUndoRegistration];
    

    [self.undoManager enableUndoRegistration];
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeFloat:_ghostX forKey:@"ghostX"];
    [aCoder encodeFloat:_ghostY forKey:@"ghostY"];
    [aCoder encodeFloat:_ghostOpacity forKey:@"ghostOpacity"];
    [aCoder encodeObject:_ghostImageName forKey:@"ghostImageName"];
    [aCoder encodeObject:_group forKey:@"group"];
}


- (BOOL)containClass:(Class)class{
    for(IUBox *box in self.allChildren){
        if([box isKindOfClass:class]){
            return YES;
        }
    }
    return NO;
}

- (BOOL)canChangeXByUserInput{
    return NO;
}
- (BOOL)canChangeYByUserInput{
    return NO;
}
- (BOOL)canChangeWidthByUserInput{
    return NO;
}

- (BOOL)canChangeHeightByUserInput{
    return NO;
}




-(NSString*)editorSource{
    NSAssert(self.project.compiler, @"compiler");
    
    NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self" ascending: NO];
    NSArray *sortedArray= [self.project.mqSizes sortedArrayUsingDescriptors: [NSArray arrayWithObject: sortOrder]];
    
    
    
    return [self.project.compiler editorSource:self mqSizeArray:sortedArray];
}

- (NSString *)outputCSSSource{
    NSAssert(self.project.compiler, @"compiler");
    
    NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self" ascending: NO];
    NSArray *sortedArray= [self.project.mqSizes sortedArrayUsingDescriptors: [NSArray arrayWithObject: sortOrder]];
    
    return [self.project.compiler outputCSSSource:self mqSizeArray:sortedArray];
    
}

- (NSString*)outputHTMLSource{
    NSAssert(self.project.compiler, @"compiler");
    return [self.project.compiler outputHTMLSource:self];
}

- (JDCode *)outputInitJSCode{
    return [self.project.compiler outputJSInitializeSource:self];
}
- (NSArray *)outputArrayClipArt{
    return [self.project.compiler outputClipArtArray:self];
}

-(NSArray*)widthWithCSS{
    return @[];
}

-(IUBox *)selectableIUAtPoint:(CGPoint)point{
    return nil;
}

-(IUBox*)parent{
    return nil;
}

-(void)setParent:(IUBox *)parent{
#if DEBUG
//    NSAssert(0, @"");
#endif
}

- (BOOL)canMoveToOtherParent{
    return NO;
}
@end
