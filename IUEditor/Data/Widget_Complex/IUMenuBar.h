//
//  IUMenuBar.h
//  IUEditor
//
//  Created by seungmi on 2014. 7. 31..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUBox.h"

typedef enum{
    IUMenuBarAlignLeft,
    IUMenuBarAlignRight,
}IUMenuBarAlign;

@interface IUMenuBar : IUBox

//Menubar property
@property (nonatomic) IUMenuBarAlign align;

- (NSInteger)count;
- (void)setCount:(NSInteger)count;

//Menubar - Mobile property
@property (nonatomic) NSString *mobileTitle;
@property (nonatomic) NSColor *mobileTitleColor, *iconColor;

- (NSString *)mobileButtonIdentifier;
- (NSString *)topButtonIdentifier;
- (NSString *)bottomButtonIdentifier;

//editor mode - display : mobile version
@property BOOL isOpened;
- (NSString *)editorDisplayIdentifier;


@end
