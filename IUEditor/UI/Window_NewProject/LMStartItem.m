//
//  LMStartItem.m
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 6. 30..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "LMStartItem.h"

@interface LMStartItem()

@end
@implementation LMStartItem

- (id)initWithDict:(NSDictionary *)dict{
    self = [super init];
    if(self){
        self.thumbnail = [NSImage imageNamed:[dict objectForKey:@"thumbnail"]];
        self.name = [dict objectForKey:@"name"];
        self.projectType = [[dict objectForKey:@"type"] intValue];
        self.desc = [dict objectForKey:@"desc"];
        self.viewPorts = [dict objectForKey:@"pageSize"];
        self.previewImageArray = [dict objectForKey:@"previewImages"];
        self.previewVideoArray = [dict objectForKey:@"previewVideos"];
        self.packagePath = [dict objectForKey:@"projectPackageFile"];
        self.feature = [dict objectForKey:@"feature"];
        self.fileName = [dict objectForKey:@"fileName"];
        
    }
    return self;
}


@end