//
//  IUMQData.h
//  IUEditor
//
//  Created by seungmi on 2014. 10. 14..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JDCoder.h"
#import "IUDataStorage.h"

@protocol IUMQDataDelegate

@required
- (void)updateHTML;
- (NSUndoManager *)undoManager;
@end

/**
 This class for media query data, not css
 
 */
@interface IUMQData : NSObject <NSCoding, JDCoding, NSCopying>

#if 0

@property (nonatomic)  NSInteger editViewPort;
@property (nonatomic)  NSInteger maxViewPort;
@property (weak) id  <IUMQDataDelegate> delegate;

//set tag, or delete tag
-(void)setValue:(id)value forTag:(IUMQDataTag)tag;
-(void)setValue:(id)value forTag:(IUMQDataTag)tag forViewport:(NSInteger)width;


/**
 @brief find viewport tag, if there not, return default value for tag
 */
-(id)effectiveValueForTag:(IUMQDataTag)tag forViewport:(NSInteger)width;
-(id)valueForTag:(IUMQDataTag)tag forViewport:(NSInteger)width;


//remove tag of all tag dictionay in width
-(void)eradicateTag:(IUMQDataTag)tag;
-(void)removeTagDictionaryForViewport:(NSInteger)width;

//get mqdata tag dictionary for specific width
-(NSDictionary*)tagDictionaryForViewport:(NSInteger)width;
-(NSArray*)allViewports;
/**
 get mqdata tag dictionary for width
 */
-(NSDictionary *)dictionaryForTag:(IUMQDataTag)tag;

//observable.
@property (readonly) NSDictionary *effectiveTagDictionary;



/*convert to storageManager */
- (IUDataStorageManager *)convertToPropertyStorageManager;

#endif

@end
