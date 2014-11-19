//
//  IURender.h
//  IUEditor
//
//  Created by jd on 4/24/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUBox.h"
#import "IUClass.h"

#define kIUImportEditorPrefix @"ImportedBy_"


@interface IUImport : IUBox
@property (nonatomic, weak) IUClass  *prototypeClass;

/**
 @brief ImportedBy_importID_iu.htmlID
 */
- (NSString *)modifieldHtmlIDOfChild:(IUBox *)iu;

- (id)initWithPreset:(IUClass*)aClass;
@end