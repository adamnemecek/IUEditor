//
//  IUWordpressProject.h
//  IUEditor
//
//  Created by jd on 2014. 7. 14..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUProject.h"
#import "IUPage.h"

@interface IUWordpressProject : IUProject

@property (nonatomic) NSInteger port;
@property  NSString *documentRoot;

//theme meta data
@property NSString *uri, *tags, *version, *themeDescription;

@end
