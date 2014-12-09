//
//  IUBoxSubclass.h
//  IUEditor
//
//  Created by Joodong Yang on 2014. 12. 10..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

@interface IUBox(Subclass)
- (NSMutableDictionary *)_m_storageManagerDict;
- (NSMutableArray *)_m_children;
- (void)bindStorages;
- (void)unbindStorages;
@end