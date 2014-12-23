//
//  JDMemoryCheck.h
//  IUEditor
//
//  Created by Joodong Yang on 2014. 12. 22..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class  JDMemoryChecker;
@protocol JDMemoryCheckerDelegate <NSObject>
@required
- (void)memoryCheckerObjectWillDeallocated:(NSString *)className aliveObjectCount:(NSInteger)objCount;
@end


@interface JDMemoryChecker : NSObject

+(JDMemoryChecker *)sharedChecker;
-(void)fireMemoryCheckAfterDelay:(NSTimeInterval)sec;
-(void)memoryCheck;

-(void)objDidAllocated:(NSString *)className;
-(void)objWillDeallocated:(NSString *)className;
@property (readonly) NSCountedSet *set;


@property id <JDMemoryCheckerDelegate> delegate;
@end


@interface JDMemoryCheckVC : NSViewController

@end
