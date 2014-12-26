//
//  BBBackEndpropertyVC.h
//  IUEditor
//
//  Created by seungmi on 2014. 12. 8..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBDefaultPropertyVC.h"

@interface BBBackEndPropertyVC : BBDefaultPropertyVC <NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IUProject *project;

@end
