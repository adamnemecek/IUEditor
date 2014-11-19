//
//  IUFileItem.h
//  IUEditor
//
//  Created by Joodong Yang on 2014. 11. 19..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#ifndef IUEditor_IUFileItem_h
#define IUEditor_IUFileItem_h

@protocol IUFileItem <NSObject>

@optional
- (id)project;

@required
- (NSArray *)childrenFileItem;

@end

#endif
