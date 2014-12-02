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

- (id)initWithPreset{
    self = [super initWithPreset];
    _ghostOpacity = 0.5;
    return self;
}

- (id)initWithJDCoder:(JDCoder *)aDecoder{
    self = [super initWithJDCoder:aDecoder];
    if(self){
        _ghostX = [aDecoder decodeFloatForKey:@"ghostX"];
        _ghostY = [aDecoder decodeFloatForKey:@"ghostY"];
        _ghostOpacity = [aDecoder decodeFloatForKey:@"ghostOpacity"];
        _ghostImageName = [aDecoder decodeObjectForKey:@"ghostImageName"];

    }
    return self;
}
- (void)awakeAfterUsingJDCoder:(JDCoder *)aDecoder{
    [super awakeAfterUsingJDCoder:aDecoder];
    
    [self.undoManager disableUndoRegistration];
    _parentFileItem = [aDecoder decodeByRefObjectForKey:@"group"];
    [self.undoManager enableUndoRegistration];
}

- (void)encodeWithJDCoder:(JDCoder *)aCoder{
    [super encodeWithJDCoder:aCoder];
    [aCoder encodeFloat:_ghostX forKey:@"ghostX"];
    [aCoder encodeFloat:_ghostY forKey:@"ghostY"];
    [aCoder encodeFloat:_ghostOpacity forKey:@"ghostOpacity"];
    [aCoder encodeObject:_ghostImageName forKey:@"ghostImageName"];
    
    [aCoder encodeByRefObject:_parentFileItem forKey:@"group"];
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

- (BOOL)isFileItemGroup{
    return NO;
}

/*
-(IUBox *)selectableIUAtPoint:(CGPoint)point{
    return nil;
}
 */


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

#pragma mark - event variable dict

- (NSMutableArray *)receiverArrayOfVariable:(NSString *)variable inVariableDictionary:(NSDictionary *)variableDictionary{
    NSMutableDictionary *dict = variableDictionary[variable];
    return dict[IUEventTagReceiverArray];
}

- (NSDictionary *)eventVariableDict{
    NSMutableDictionary *variableDictionary = [NSMutableDictionary dictionary];
    
    for (IUBox *obj in self.allChildren) {
        //setting trigger
        NSString *variable =  obj.event.variable;
        if(variable){
            NSMutableDictionary *oneDict = variableDictionary[variable];
            if(oneDict == nil){
                oneDict = [NSMutableDictionary dictionary];
                NSMutableArray *array = [NSMutableArray array];
                [oneDict setObject:array forKey:IUEventTagReceiverArray];
                [variableDictionary setObject:oneDict forKey:variable];
            }
            [oneDict setObject:variable forKey:IUEventTagVariable];
            if([oneDict objectForKey:IUEventTagIUID]){
                NSMutableArray *ids = [[oneDict objectForKey:IUEventTagIUID] mutableCopy];
                if([ids containsString:obj.htmlID] == NO){
                    [ids addObject:obj.htmlID];
                    [oneDict setObject:ids forKey:IUEventTagIUID];
                }
            }
            else{
                [oneDict setObject:@[obj.htmlID] forKey:IUEventTagIUID];
            }
            [oneDict setObject:@(obj.event.initialValue) forKey:IUEventTagInitialValue];
            [oneDict setObject:@(obj.event.maxValue) forKey:IUEventTagMaxValue];
            [oneDict setObject:@(obj.event.actionType) forKey:IUEventTagActionType];
        }
    }
    
    for(IUBox *obj in self.allChildren){
        //setting receiver - visible
        NSString *visibleVariable = obj.event.eqVisibleVariable;
        if(visibleVariable){
            NSMutableDictionary *visibleDict = [NSMutableDictionary dictionary];
            [visibleDict setObject:obj.htmlID forKey:IUEventTagVisibleID];
            [visibleDict setObject:obj forKey:IUEventTagVisibleIU];
            [visibleDict setObject:obj.event.eqVisible forKey:IUEventTagVisibleEquation];
            [visibleDict setObject:@(obj.event.eqVisibleDuration) forKey:IUEventTagVisibleDuration];
            [visibleDict setObject:@(obj.event.directionType) forKey:IUEventTagVisibleType];
            
            NSMutableArray *receiverArray = [self receiverArrayOfVariable:visibleVariable inVariableDictionary:variableDictionary];
            if(receiverArray){
                [receiverArray addObject:visibleDict];
            }
        }
        
        //setting receiver - frame
        NSString *frameVariable = obj.event.eqFrameVariable;
        if(frameVariable){
            NSMutableDictionary *frameDict = [NSMutableDictionary dictionary];
            [frameDict setObject:obj.htmlID forKey:IUEventTagFrameID];
            [frameDict setObject:obj forKey:IUEventTagFrameIU];
            [frameDict setObject:obj.event.eqFrame forKey:IUEventTagFrameEquation];
            [frameDict setObject:@(obj.event.eqFrameDuration) forKey:IUEventTagFrameDuration];
            [frameDict setObject:@(obj.event.eqFrameWidth) forKey:IUEventTagFrameWidth];
            [frameDict setObject:@(obj.event.eqFrameHeight) forKey:IUEventTagFrameHeight];
            
            NSMutableArray *receiverArray = [self receiverArrayOfVariable:frameVariable inVariableDictionary:variableDictionary];
            if(receiverArray){
                [receiverArray addObject:frameDict];
            }
        }
    }
    if ([variableDictionary count]) {
        return [variableDictionary copy];
    }
    return nil;
}

- (IUProject *)project {
    return self.parentFileItem.project;
}

@end
