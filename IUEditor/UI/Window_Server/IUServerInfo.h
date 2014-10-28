//
//  IUServerInfo.h
//  IUEditor
//
//  Created by jd on 2014. 7. 21..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IUServerInfo : NSObject

@property NSString *host;

@property NSString *syncUser;
@property NSString *syncPassword;
@property NSString *remotePath;
@property NSString *localPath;
@property NSString *syncItem;


@property BOOL isServerNeedRestart;
@property NSString *restartUser;
@property NSString *restartPassword;
@property NSString *restartCommand;

- (BOOL)isSyncValid;

@end