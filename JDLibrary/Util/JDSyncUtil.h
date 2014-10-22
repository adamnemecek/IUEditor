//
//  JDFTPModule.h
//  IUEditor
//
//  Created by jd on 2014. 7. 17..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JDSyncUtilDeleagate <NSObject>

@required
- (void)syncUtilReceivedStdOutput:(NSString*)aMessage;
- (void)syncUtilReceivedStdError:(NSString*)aMessage;
- (void)syncFinished:(int)terminationStatus;

@end


typedef enum _JDNetworkProtocol{
    JDSFTP,
    JDGit,
} JDNetworkProtocol;

@interface JDSyncUtil : NSObject

@property (weak) id <JDSyncUtilDeleagate> delegate;

@property NSString *host;
@property NSString *user;
@property NSString *password;
@property NSString *syncDirectory;
@property NSString *localDirectory;
@property NSString *remoteDirectory;
@property NSString *afterCommand;
@property NSInteger tag;

@property JDNetworkProtocol protocol;

- (BOOL)upload;
- (BOOL)download;
- (BOOL)isSyncing;
- (BOOL)terminate;
@end
