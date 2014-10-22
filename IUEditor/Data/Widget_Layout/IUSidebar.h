//
//  IUSidebar.h
//  IUEditor
//
//  Created by seungmi on 2014. 9. 17..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUImport.h"

typedef enum{
    IUSidebarTypeFull,
    IUSidebarTypeInside,
}IUSidebarType;

@interface IUSidebar : IUImport

@property IUSidebarType type;

@end
