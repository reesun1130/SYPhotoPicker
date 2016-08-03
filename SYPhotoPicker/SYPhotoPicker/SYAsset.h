//
//  SYAsset.h
//  SYPhotoPicker
//
//  Created by reesun on 16/8/1.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
//

#import <UIKit/UIKit.h>

@interface SYAsset : NSObject

/**
 *  PHAsset/ALAsset
 */
@property (nonatomic, strong, readonly, nonnull) id asset;

/**
 *  原图 (默认尺寸kOriginTargetSize)
 */
@property (nonatomic, strong, readonly, nonnull) UIImage *originImage;

/**
 *  预览图（默认尺寸kPreviewTargetSize）
 */
@property (nonatomic, strong, readonly, nonnull) UIImage *previewImage;

/**
 *  缩略图（默认尺寸kThumbnailTargetSize)
 */
@property (nonatomic, strong, readonly, nonnull) UIImage *thumbnailImage;

/**
 *  照片方向
 */
@property (nonatomic, assign, readonly) UIImageOrientation imageOrientation;

/**
 *  是否选中
 */
@property (nonatomic) BOOL selected;

/**
 *  是否在iCloud中
 */
@property (nonatomic, readonly, getter=isInCloud) BOOL isCloudImage;

/**
 *  初始化相片model
 *
 *  @param asset PHAsset/ALAsset
 *
 *  @return SYAsset
 */
- (id _Nonnull)initWithAsset:(id _Nonnull)asset;

/**
 *  是否在iCloud中未下载到本地
 *
 *  @return BOOL
 */
- (BOOL)isInCloud;

@end
