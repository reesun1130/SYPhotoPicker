//
//  SYAlbum.h
//  SYPhotoPicker
//
//  Created by reesun on 16/8/1.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
//

#import <UIKit/UIKit.h>

@interface SYAlbum : NSObject

/**
*  相册的名称
*/
@property (nonatomic, copy, readonly, nonnull) NSString *name;

/**
 *  头图
 */
@property (nonatomic, strong, readonly, nonnull, getter=displayHeaderImage) UIImage *thumbnail;

/**
 *  照片的数量
 */
@property (nonatomic, assign, readonly) NSUInteger assetCount;

/**
 *  PHFetchResult<PHAsset>/ALAssetsGroup<ALAsset>
 */
@property (nonatomic, strong, readonly, nonnull) id fetchResult;

/**
 *  初始化SYAlbum
 *
 *  @param fetchResult PHFetchResult<PHAsset>/ALAssetsGroup<ALAsset>
 *  @param name        相册的名称
 *  @param assetCount  照片的数量
 *
 *  @return SYAlbum
 */
- (id _Nonnull)initWithFetchResult:(id _Nonnull)fetchResult
                              name:(NSString *_Nonnull)name
                        assetCount:(NSUInteger)assetCount;

@end
