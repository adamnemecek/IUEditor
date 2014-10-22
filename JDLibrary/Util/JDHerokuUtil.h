//
//  JDHerokuUtil.h
//  Mango
//
//  Created by JD on 13. 5. 17..
/// Copyright (c) 2004-2013, JDLab  / Yang Joodong
/// All rights reserved. Licensed under the GPL.
/// See the GNU General Public License for more details. (/LICENSE)

//

#import <Foundation/Foundation.h>

@class JDHerokuUtil;

@protocol JDHerokuUtilLoginDelegate <NSObject>
@required
-(void)herokuUtil:(JDHerokuUtil*)util loginProcessFinishedWithResultCode:(NSInteger)resultCode;
-(void)herokuUtil:(JDHerokuUtil*)util logoutProcessFinishedWithResultCode:(NSInteger)resultCode;
@end


static NSString * kNotiHerokuLogin = @"kNotiHerokuLogin";

@interface JDHerokuUtil : NSObject{
}

-(id)init;
-(BOOL)create:(NSString*)appName resultLog:(NSString**)resultLog;
-(void)login:(NSString*)myid password:(NSString*)mypasswd;
-(void)logout;
-(BOOL)combineGitPath:(NSString*)path appName:(NSString*)appName;
+(NSString*)configMessageForPath:(NSString*)path;
//-(void)updateLoginInfo;

@property NSString *loginID;

- (BOOL)logging;
+(NSString*)loginID;
+ (NSString*)herokuAppNameAtPath:(NSString*)path;

@property id <JDHerokuUtilLoginDelegate>    loginDelegate;
- (void)prepareHerokuUpload:(NSString*)path;

@end