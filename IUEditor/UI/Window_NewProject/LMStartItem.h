//
//  LMStartItem.h
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 6. 30..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IUProject.h"

@interface LMStartItem : NSObject

//property for loading project
@property NSImage *thumbnail;
@property NSString *fileName;
@property NSString *name;
@property NSString *packagePath;

//template description
@property NSString *desc , *feature;
@property NSString *mqSizes;
@property IUProjectType projectType;
@property NSArray *previewImageArray;
@property NSArray *previewVideoArray;

- (id)initWithDict:(NSDictionary *)dict;


@end
