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

#pragma mark - css
//update inline-css
-(void)IUClassIdentifier:(NSString *)identifier CSSUpdated:(NSString*)css;
//rempve style-sheet css (hover, active class)
-(void)removeCSSTextInDefaultSheetWithIdentifier:(NSString *)identifier;


#pragma mark - JS
- (void)updateJS;

- (void)enableUpdateJS:(id)sender;
- (void)disableUpdateJS:(id)sender;
- (BOOL)isUpdateJSEnabled;


/**
 @brief call javascript function
 @param args javascirpt function argument, argument에 들어가는 것중에 dict, array는 string으로 보내서javascript내부에서 새로 var를 만들어서 사용
 */
- (id)callWebScriptMethod:(NSString *)function withArguments:(NSArray *)args;
- (id)evaluateWebScript:(NSString *)script;



#pragma mark - HTML
-(void)IUHTMLIdentifier:(NSString *)identifier HTML:(NSString *)html;
-(void)IURemoved:(NSString*)identifier;



- (NSRect)absoluteIUFrame:(NSString *)identifier;
- (NSInteger)countOfLineWithIdentifier:(NSString *)identifier;


@end

#endif
