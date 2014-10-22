//
//  JDComboBoxCell.m
//  IUEditor
//
//  Created by seungmi on 2014. 9. 25..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "JDComboBoxCell.h"

@implementation JDComboBoxCell

- (NSString *)completedString:(NSString *)string
{
    NSString *result = nil;
    
    if (string == nil)
        return result;
    
    for (NSString *item in self.objectValues) {
        NSString *truncatedString = [item substringToIndex:MIN(item.length, string.length)];
        if ([truncatedString caseInsensitiveCompare:string] == NSOrderedSame) {
            result = item;
            break;
        }
    }
    
    return result;
}

@end
