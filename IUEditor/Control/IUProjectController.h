//
//  IUProjectController.h
//  IUEditor
//
//  Created by ChoiSeungme on 2014. 6. 10..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 IUProjectController supports making new document with url
 because IUEditor needs a base url (support for css, js)
 (NSDocumentController make new document without url)
 */
@interface IUProjectController : NSDocumentController

/**
option - project type & project option
url을 넘기고 싶으면 IUProjectKeyIUFilePath를 key로 option에 넣어야함.
*/
- (void)newDocument:(id)sender withOption:(NSDictionary *)option __deprecated;

- (NSDictionary *)newDocumentOption;

@end
