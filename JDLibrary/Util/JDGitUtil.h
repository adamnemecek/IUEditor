//
//  JDGitUtil.h
//  Mango
//
//  Created by JD on 13. 5. 16..
/// Copyright (c) 2004-2013, JDLab  / Yang Joodong
/// All rights reserved. Licensed under the GPL.
/// See the GNU General Public License for more details. (/LICENSE)

//

#import <Foundation/Foundation.h>

@class JDGitUtil;
@protocol JDGitUtilDelegate
@required
- (void)gitUtil:(JDGitUtil*)util pushMessageReceived:(NSString*)aMessage;
- (void)gitUtilPushFinished:(JDGitUtil*)util;
@end

@interface JDGitUtil : NSObject

-(id)initWithGitRepoPath:(NSString*)filePath;
-(BOOL)isGitRepo;
-(BOOL)gitInit;
-(BOOL)addAll;
-(BOOL)commit:(NSString*)commitMsg;
-(void)push:(NSString*)remote branch:(NSString*)branch force:(BOOL)force;

- (void)herokuPush;

@property id <JDGitUtilDelegate> delegate;

@end
