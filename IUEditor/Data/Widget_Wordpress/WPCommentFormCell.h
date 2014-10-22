//
//  WPCommentFormCell.h
//  IUEditor
//
//  Created by jd on 9/16/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import "IUBox.h"
#import "IUProtocols.h"
#import "WPCommentForm.h"

typedef enum _WPCommentFormCellType{
    WPCommentFormCellTypeField,
    WPCommentFormCellTypeTextArea
}WPCommentFormCellType;

@interface WPCommentFormCell : IUBox <IUSampleHTMLProtocol, IUPHPCodeProtocol>

@property (nonatomic) WPCommentFormCellType cellType;
@property (nonatomic) WPCommentFormType formType;

@end
