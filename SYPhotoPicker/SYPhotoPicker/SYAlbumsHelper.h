//
//  SYAlbumsHelper.h
//  SYPhotoPicker
//
//  Created by reesun on 16/1/6.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

#define kScreenScale ([UIScreen mainScreen].scale)
#define kScreenSize ([UIScreen mainScreen].bounds.size)
#define kScreenWidth (kScreenSize.width)
#define kScreenHeight (kScreenSize.height)
#define kCellWidth ((kScreenWidth - 50) / 4.0)//每行四个image
#define kIOS8OrLater ([[[UIDevice currentDevice] systemVersion] compare:@"8" options:NSNumericSearch] != NSOrderedAscending)
#define kIOS9OrLater ([[[UIDevice currentDevice] systemVersion] compare:@"9" options:NSNumericSearch] != NSOrderedAscending)
#define kOriginTargetSize (kIOS8OrLater ? PHImageManagerMaximumSize : CGSizeMake(kScreenWidth * kScreenScale, kScreenHeight * kScreenScale))//原图尺寸
#define kPreviewTargetSize (kScreenSize)//预览图尺寸
#define kThumbnailTargetSize (CGSizeMake(kCellWidth, kCellWidth))//缩略图尺寸，如果感觉模糊可以再*kScreenScale

@class SYAlbum;
@class SYAsset;

@interface SYAlbumsHelper : NSObject

+ (id _Nonnull)sharedHelper;

//是否可以访问照片
+ (BOOL)canAccessAlbums;

//读取相册列表albums
+ (void)fetchAlbums:(void(^_Nonnull)(NSArray <SYAlbum *>*_Nonnull albums, BOOL success))completion;

//读取相册内assets
+ (void)fetchAssetsWithAlbum:(id _Nonnull)album
                  completion:(void(^_Nonnull)(NSArray <SYAsset *>*_Nonnull assets, BOOL success))completion;

//读取asset内image
- (void)fetchImageWithAsset:(id _Nonnull)asset
                 targetSize:(CGSize)targetSize
                 completion:(void(^_Nullable)(UIImage *_Nullable image, NSDictionary *_Nullable info))completion;

@end
