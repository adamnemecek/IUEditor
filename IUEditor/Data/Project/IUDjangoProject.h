//
//  IUDjangoProject.h
//  IUEditor
//
//  Created by jd on 4/25/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUProject.h"

@interface IUDjangoProject : IUProject

@property (nonatomic) NSInteger port;
@property (nonatomic) NSString *managePyPath;

-(NSString*)absoluteManagePyPath;

@end
