//
//  IUResource.h
//  IUEditor
//
//  Created by JD on 4/6/14.
//  Copyright (c) 2014 JDLab. All rights reserved.
//

#import <Foundation/Foundation.h>

/* Resource Management
 1) VC에서 읽어들일 파일과 해당 디렉토리를 선택
 2) NSDocument에서 fileWrapper을 통하여 file을 카피하면서 디렉토리에 저장
 3) IUResourceGroup을 refresh
 - 이전에 fileItem에 originalPath를 두곤 했는데, 아무래도 불편하며, sync에 문제가 있음.
 - 한 방에 깔끔하게 그냥 카피하고 끝내는게 편함.
 */


typedef enum _IUResourceType{
    IUResourceTypeNone,
    IUResourceTypeImage,
    IUResourceTypeCSS,
    IUResourceTypeJS,
    IUResourceTypeVideo,
}IUResourceType;


@class  IUResourceGroupItem;
@interface IUResourceFileItem : NSObject

- (NSArray *)children;
- (BOOL)isLeaf;
- (IUResourceGroupItem *)parent;
- (NSString *)name;
- (NSString*)absolutePath;
- (NSString*)relativePath;
- (IUResourceType) type;

@end


@interface IUResourceGroupItem : IUResourceFileItem

- (IUResourceFileItem *)resourceFileItemForName:(NSString *)name;
- (void)refresh:(BOOL)recursive;
/**
 @breif Getting contents in image resource group
 @return Array of IUResourceFile
 @note Not KVO-compliance
 */
- (NSArray*)imageResourceItems;

/**
 @breif Getting contents in video resource group
 @return Array of IUResourceFile
 @note Not KVO-compliance
 */
- (NSArray*)videoResourceItems;
@end


/**
 IUResourceRootItem is root file item in resource field
 */
@interface IUResourceRootItem : IUResourceGroupItem

- (void)loadFromPath:(NSString *)path;

@end