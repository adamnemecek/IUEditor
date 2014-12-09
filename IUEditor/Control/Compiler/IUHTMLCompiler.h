//
//  IUHTMLCompiler.h
//  IUEditor
//
//  Created by seungmi on 2014. 9. 19..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JDCode.h"
#import "IUCSSCode.h"
#import "IUBoxes.h"

/**
 IU, Rule, ViewPort, CSSCode 정보를 받아서 JDCode 형태로 만들어준다.
 기존에는 IUCSSCompiler 를 직접 소유하기도 하였으나, IUCSSCompiler 가 한개의 identifier가 아닌 여러개의 identifier를 생성해야하므로 밖에서도 만들어야한다. 때문에 밖에서 만들어봤자 중복작업이 된다.
 외부에서 CSSCode를 생성하고, HTMLCompiler에서는 그 쪽의 Main Identifier만 받아서 작업하기로 한다.
 그러나 child또한 만들어주므로, cssCode는 NSDictionary {key=IUBox, value=IUCSSCode} 가 되어야한다.
 */

@interface IUHTMLCompiler : NSObject

@property (copy) NSString *editorResourcePrefix;
@property (copy) NSString *outputResourcePrefix;

/**
 @brief DOM에 insert/replace 할 수 있는 HTML Code 를 생성한다.
 @note IUCSSCode 가 style(CSSCode의 MainIdentifier)를 받지 않고 바로 IUCSSCode를 바로 받는 이유는 IUMenuBar등 어떻게 관리해야할지 불명확한 객체들을
 다루기 위함이다. 이 csscode 오브젝트에서 viewPort 위치를 맞춰주어서 editorHTMLCode를 생성해내는 것으로 한다. 만약에 cssCode에 해당 viewPort 에 대한
 정보가 들어있지 않으면 NSAssert을 발생시킨다.
 
 @param cssCodes IUCSSCompiler에서 생성된 CSSCode. iu의 children의 cssCode까지 모두 담아야한다.
 @param rule const NSString형태의 컴파일 룰이다. HTMLCompiler에서는 기본적으로 default 가 들어오게 될 것이며,
 향후에 subclassing에 따라 Django에 대응하는 const NSString *이 들어올 수 있다.
 */
- (JDCode *)editorHTMLCode:(IUBox *)iu htmlIDPrefix:(NSString *)htmlIDPrefix rule:(NSString *)rule viewPort:(NSInteger)viewPort cssCodes:(NSDictionary *)codes;


/**
 @brief HTML 파일에 넣을 수 있는 HTML Code를 생성한다.
 
 @param cssCode IUCSSCompiler에서 생성된 CSSCode. mainIdentifier가 style에 들어가게 되며, 따라서 style에 들어가지 않는 필요없는 정보는 들어오면 안된다. 이 부분은 IUCSSCompiler가 책임질 것.
 @param rule const NSString형태의 컴파일 룰이다. HTMLCompiler에서는 기본적으로 default 가 들어오게 될 것이며,
 향후에 subclassing에 따라 Django에 대응하는 const NSString *이 들어올 수 있다.

 */
- (JDCode *)outputHTMLCode:(IUBox *)iu htmlIDPrefix:(NSString *)htmlIDPrefix rule:(NSString *)rule cssCodes:(NSDictionary *)codes;

@end