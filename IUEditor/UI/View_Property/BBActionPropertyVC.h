//
//  BBActionPropertyVC.h
//  IUEditor
//
//  Created by seungmi on 2014. 12. 8..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "BBDefaultPropertyVC.h"
#import "IUProject.h"

/**
 @brief BBActionPropertyVC manages link, mouseover property
 */
@interface BBActionPropertyVC : BBDefaultPropertyVC <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, weak) IUProject *project;


@end
