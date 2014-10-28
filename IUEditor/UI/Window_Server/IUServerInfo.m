//
//  IUServerInfo.m
//  IUEditor
//
//  Created by jd on 2014. 7. 21..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUServerInfo.h"

@implementation IUServerInfo


- (id)init{
    self = [super init];
    if (self){
        //initialize
        self.host = @"www.iueditor.org";
        self.syncUser = @"www-data";
        self.syncPassword = @"www-data";
        self.remotePath = @"/var/www";
        self.localPath = nil; // do not initialize local path. IUProject will initialize it;
        self.syncItem = nil; // do not initialize sync Item. IUProject will initialize it;
        
        self.isServerNeedRestart = NO;
        self.restartUser = @"root";
        self.restartPassword = @"rootPassword";
        self.restartCommand = @"service apache2 restart";
    }
    return self;
}

- (BOOL)isSyncValid{
    return [self.host length] && [self.remotePath length] && [self.syncUser length];
}

@end
