//
//  IUSourceDelegate.h
//  IUEditor
//
//  Created by seungmi on 2014. 10. 24..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#ifndef IUEditor_IUSourceDelegate_h
#define IUEditor_IUSourceDelegate_h

@protocol IUSourceDelegate <NSObject>
@required

//enable, disable update
- (void)enableUpdateAll:(id)sender;
- (void)disableUpdateAll:(id)sender;

#pragma mark - css
//update inline-css
-(void)IUClassIdentifier:(NSString *)identifier CSSUpdated:(NSString*)css;
//rempve style-sheet css (hover, active class)
-(void)removeCSSTextInDefaultSheetWithIdentifier:(NSString *)identifier;

- (void)enableUpdateCSS:(id)sender;
- (void)disableUpdateCSS:(id)sender;
- (BOOL)isUpdateCSSEnabled;



#pragma mark - JS
- (void)updateJS;

- (void)enableUpdateJS:(id)sender;
- (void)disableUpdateJS:(id)sender;
- (BOOL)isUpdateJSEnabled;



#pragma mark - HTML
-(void)IUHTMLIdentifier:(NSString *)identifier HTML:(NSString *)html withParentID:(NSString *)parentID;
-(void)IURemoved:(NSString*)identifier withParentID:(NSString *)parentID;

- (void)enableUpdateHTML:(id)sender;
- (void)disableUpdateHTML:(id)sender;
- (BOOL)isUpdateHTMLEnabled;


- (NSPoint)distanceFromIU:(NSString *)iuName to:(NSString *)parentName;
- (NSInteger)countOfLineWithIdentifier:(NSString *)identifier;


/**
 @brief call javascript function
 @param args javascirpt function argument, argument에 들어가는 것중에 dict, array는 string으로 보내서javascript내부에서 새로 var를 만들어서 사용
 */
- (id)callWebScriptMethod:(NSString *)function withArguments:(NSArray *)args;
- (id)evaluateWebScript:(NSString *)script;


@end

#endif
