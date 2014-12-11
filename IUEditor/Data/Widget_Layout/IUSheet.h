//
//  IUSheet.h
//  IUEditor
//
//  Created by JD on 3/17/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IUCompiler.h"
#import "IUBox.h"
#import "IUIdentifierManager.h"
#import "IUFileItem.h"


@class IUSheetGroup;

@interface IUSheet : IUBox <IUFileItemProtocol>

@property CGFloat ghostX, ghostY, ghostOpacity;
@property NSString *ghostImageName;

- (NSDictionary *)eventVariableDict;

@property (weak) id <IUFileItemProtocol, JDCoding> parentFileItem;

@end