//
//  IUComponent.h
//  IUEditor
//
//  Created by JD on 3/17/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUSheet.h"

static NSString *kClassType = @"classType";
static NSString *IUClassHeader = @"headerClass";
static NSString *IUClassFooter = @"footerClass";
static NSString *IUClassSidebar = @"sidebarClass";

@class IUImport;

@interface IUClass : IUSheet

- (void)addReference:(IUImport*)import;
- (void)removeReference:(IUImport*)import;
- (NSArray*)references;
@end
