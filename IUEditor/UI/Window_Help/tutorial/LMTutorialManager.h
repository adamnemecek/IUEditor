//
//  LMTutorialManager.h
//  IUEditor
//
//  Created by jd on 7/2/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>


/* 
 @brief
 old version의 튜토리얼을 삭제, 추후 추가되면 다시 사용할 수 있음.
 deprecated @141112, smchoi
 */
__attribute__((deprecated))
@interface LMTutorial : NSObject
@property NSString *title;
@property NSString *content;
@property NSString *tutorialID;
@end

__attribute__((deprecated))
@interface LMTutorialManager : NSObject

/**
 Check tutorial should be shown or not.
 @param tutorialID toturialID to show
 @return If that tutorial is seen, return false. If that tutorial is not unseen, return true.
 */
+ (BOOL)shouldShowTutorial:(NSString*)tutorialID;

/**
 Reset all show tutorial history.
 */
+ (void)reset;

/**
 Ignore all showTutorial: message.
 @note This function is opposite to unIgnore function.
 */

+ (void)ignore;

/**
 Show tutorial if showTutorial message comes.
 @note This function is opposite to ignore function.
 */
+ (void)unIgnore;
@end
