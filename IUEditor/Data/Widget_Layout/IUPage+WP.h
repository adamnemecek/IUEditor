//
//  IUPage+WP.h
//  IUEditor
//
//  Created by jd on 8/10/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUPage.h"

@interface IUPage (WP)

-(void)WPInitializeAsHome;
-(void)WPInitializeAs404;
-(void)WPInitializeAsIndex;
-(void)WPInitializeAsPage;
-(void)WPInitializeAsCategory;

@end
