//
//  BBWindowProtocol.h
//  IUEditor
//
//  Created by seungmi on 2014. 12. 8..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#ifndef IUEditor_BBWindowProtocol_h
#define IUEditor_BBWindowProtocol_h

#import "IUSheetController.h"
#import "IUController.h"
#import "IUSourceManager.h"


@protocol BBWindowProtocol <NSObject>

@required
@property IUSourceManager *sourceManager;
@property IUSheetController *pageController;
@property IUSheetController *classController;
@property IUController *iuController;

@end


#endif
