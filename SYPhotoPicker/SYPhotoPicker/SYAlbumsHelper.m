//
//  SYAlbumsHelper.m
//  SYPhotoPicker
//
//  Created by reesun on 16/1/6.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
//

#import "SYAlbumsHelper.h"
#import "SYAlbum.h"
#import "SYAsset.h"

@interface SYAlbumsHelper ()

@property (nonatomic, strong) PHImageRequestOptions *imageRequestOption;
//@property (nonatomic, strong) NSDictionary *dicSmartAlbumNames;

@end

static SYAlbumsHelper *albumsHelper = nil;

@implementation SYAlbumsHelper
@synthesize imageRequestOption = _imageRequestOption;
//@synthesize dicSmartAlbumNames = _dicSmartAlbumNames;

+ (id _Nonnull)sharedHelper {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        albumsHelper = [[[self class] alloc] init];
    });
    
    return albumsHelper;
}

- (PHImageRequestOptions *)imageRequestOption {
    if (!_imageRequestOption) {
        _imageRequestOption = [[PHImageRequestOptions alloc] init];
        _imageRequestOption.synchronous = YES;
    }
    
    return _imageRequestOption;
}

#warning 要显示中文相册名称请设置info.plist
/**
 *  info.plist里面添加如下2个key : value
 Localizedresources can be mixed : YES
 Localization native development region : China
 */
//- (NSDictionary *)dicSmartAlbumNames {
//    if (!_dicSmartAlbumNames) {
//        _dicSmartAlbumNames = [[NSDictionary alloc] initWithObjectsAndKeys:@"相机胶卷",@"Camera Roll",@"收藏",@"Favorites",@"屏幕截图",@"Screenshots",@"相机胶卷",@"All Photos",@"自拍",@"Selfies",@"全景",@"Panoramas",@"最近删除",@"Recently Deleted",@"最近添加",@"Recently Added", nil];
//    }
//    
//    return _dicSmartAlbumNames;
//}
//- (NSString *)convertAlbumName:(NSString *)name {
//    NSString *albumName = [self.dicSmartAlbumNames objectForKey:name];
//    if (albumName) {
//        return albumName;
//    }
//    return name;
//}

//是否可以访问照片
+ (BOOL)canAccessAlbums {
    BOOL _isAuth = YES;
    if (kIOS8OrLater) {
        PHAuthorizationStatus author = [PHPhotoLibrary authorizationStatus];
        if (author == PHAuthorizationStatusRestricted || author == PHAuthorizationStatusDenied){
            //无权限
            _isAuth = NO;
        }
    }
    else {
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        
        if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusNotDetermined) {
            //无权限
            _isAuth = NO;
        }
    }
    
    return _isAuth;
}

//读取列表
+ (void)fetchAlbums:(void(^)(NSArray <SYAlbum *>*albums, BOOL success))completion {
    __block NSMutableArray *_arrAlbums = [[NSMutableArray alloc] init];
    
    if (kIOS8OrLater) {
        PHAuthorizationStatus author = [PHPhotoLibrary authorizationStatus];
        if (author == PHAuthorizationStatusRestricted || author == PHAuthorizationStatusDenied){
            //无权限
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(_arrAlbums, NO);
                }
            });
        }
        else {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    /**
                     *  系统自带智能分组相册，我们只取用户相册、收藏、最近添加，注意：自拍（PHAssetCollectionSubtypeSmartAlbumSelfPortraits）和截屏（PHAssetCollectionSubtypeSmartAlbumScreenshots）需要9.0及以上系统支持
                     */
                    [self fetchAlbumsWithType:PHAssetCollectionTypeSmartAlbum
                                      subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary
                                      options:nil
                                    resultArr:_arrAlbums];
                    
                    //收藏
                    [self fetchAlbumsWithType:PHAssetCollectionTypeSmartAlbum
                                      subtype:PHAssetCollectionSubtypeSmartAlbumFavorites
                                      options:nil
                                    resultArr:_arrAlbums];

                    //最近添加
                    [self fetchAlbumsWithType:PHAssetCollectionTypeSmartAlbum
                                      subtype:PHAssetCollectionSubtypeSmartAlbumRecentlyAdded
                                      options:nil
                                    resultArr:_arrAlbums];

                    if (kIOS9OrLater) {
                        //自拍
                        [self fetchAlbumsWithType:PHAssetCollectionTypeSmartAlbum
                                          subtype:PHAssetCollectionSubtypeSmartAlbumSelfPortraits
                                          options:nil
                                        resultArr:_arrAlbums];
                        
                        //屏幕截图
                        [self fetchAlbumsWithType:PHAssetCollectionTypeSmartAlbum
                                          subtype:PHAssetCollectionSubtypeSmartAlbumScreenshots
                                          options:nil
                                        resultArr:_arrAlbums];
                    }

                    /**
                     *  其他相册（包括手动和第三方应用创建的），我们只取常规的、手动导入的
                     */
                    [self fetchAlbumsWithType:PHAssetCollectionTypeAlbum
                                      subtype:PHAssetCollectionSubtypeAlbumRegular
                                      options:nil
                                    resultArr:_arrAlbums];

                    //导入的
                    [self fetchAlbumsWithType:PHAssetCollectionTypeAlbum
                                      subtype:PHAssetCollectionSubtypeAlbumImported
                                      options:nil
                                    resultArr:_arrAlbums];

                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completion) {
                            completion(_arrAlbums, YES);
                        }
                    });
                }
                else {
                    if (status != PHAuthorizationStatusNotDetermined) {
                        //无权限
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completion) {
                                completion(_arrAlbums, NO);
                            }
                        });
                    }
                }
            }];
        }
    }
    else {
        ALAssetsLibrary *_library = [[ALAssetsLibrary alloc] init];
        
        void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
            if (!group) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion(_arrAlbums, NO);
                    }
                });
                *stop = YES;
            }
            
            if ([group numberOfAssets] > 0) {
                NSUInteger nType = [[group valueForProperty:ALAssetsGroupPropertyType] intValue];
                NSString *sGroupPropertyName = (NSString *)[group valueForProperty:ALAssetsGroupPropertyName];
                
                SYAlbum *mAlbum = [[SYAlbum alloc] initWithFetchResult:group
                                                                  name:sGroupPropertyName.lowercaseString
                                                            assetCount:[group numberOfAssets]];
                
                if (([mAlbum.name isEqualToString:@"Camera Roll"] || [mAlbum.name isEqualToString:@"相机胶卷"]) && nType == ALAssetsGroupSavedPhotos) {
                    [_arrAlbums insertObject:mAlbum atIndex:0];
                }
                else {
                    [_arrAlbums addObject:mAlbum];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(_arrAlbums, YES);
                }
            });
        };
        
        void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(_arrAlbums, NO);
                }
            });
        };
        
        [_library enumerateGroupsWithTypes:ALAssetsGroupAll
                                usingBlock:assetGroupEnumerator
                              failureBlock:assetGroupEnumberatorFailure];
    }
}

+ (NSArray <SYAlbum *> *)fetchAlbumsWithType:(PHAssetCollectionType)type
                                     subtype:(PHAssetCollectionSubtype)subtype
                                     options:(nullable PHFetchOptions *)options
                                   resultArr:(NSMutableArray *_Nonnull)resultArr {
    PHFetchResult *albumsdd = [PHAssetCollection fetchAssetCollectionsWithType:type
                                                                       subtype:subtype
                                                                       options:options];
    for (PHAssetCollection *collection in albumsdd) {
        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection
                                                                   options:nil];
        
        if (fetchResult.count == 0)
            continue;
        
        SYAlbum *mAlbum = [[SYAlbum alloc] initWithFetchResult:fetchResult
                                                          name:collection.localizedTitle
                                                    assetCount:[fetchResult count]];
        
        if ([collection.localizedTitle isEqualToString:@"Camera Roll"]) {
            [resultArr insertObject:mAlbum atIndex:0];
        }
        else {
            [resultArr addObject:mAlbum];
        }
    }
    
    return resultArr;
}

+ (void)fetchAssetsWithAlbum:(id _Nonnull)album
                  completion:(void (^)(NSArray<SYAsset *> * _Nonnull, BOOL))completion {
    __block NSMutableArray *photoArr = [NSMutableArray array];
    
    id albumTemp = [album isKindOfClass:[SYAlbum class]] ? [album fetchResult] : album;
    
    if ([albumTemp isKindOfClass:[PHFetchResult class]]) {
        [albumTemp enumerateObjectsUsingBlock:^(PHAsset *_Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
            SYAsset *mAsset = [[SYAsset alloc] initWithAsset:asset];
            [photoArr addObject:mAsset];
        }];
    }
    else if ([albumTemp isKindOfClass:[ALAssetsGroup class]]) {
        [albumTemp setAssetsFilter:[ALAssetsFilter allPhotos]];
        [albumTemp enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
            SYAsset *mAsset = [[SYAsset alloc] initWithAsset:asset];
            [photoArr addObject:mAsset];
        }];
    }
    
    if (completion) {
        completion(photoArr, photoArr.count);
    }
}

- (void)fetchImageWithAsset:(id _Nonnull)asset
                 targetSize:(CGSize)targetSize
                 completion:(void(^_Nullable)(UIImage *_Nullable image, NSDictionary *_Nullable info))completion {
    __block UIImage *resultImage = nil;
    __block NSDictionary *resultInfo = nil;
    
    id assetTemp = [asset isKindOfClass:[SYAsset class]] ? [asset asset] : asset;
    
    if ([assetTemp isKindOfClass:[PHAsset class]]) {
        [[PHImageManager defaultManager] requestImageForAsset:assetTemp targetSize:targetSize contentMode:PHImageContentModeDefault options:self.imageRequestOption resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            resultImage = result;
            resultInfo = info;
        }];
    }
    else if ([assetTemp isKindOfClass:[ALAsset class]]) {
        if (CGSizeEqualToSize(targetSize, kThumbnailTargetSize)) {
            resultImage = [UIImage imageWithCGImage:[assetTemp thumbnail]];
        }
        else {
            ALAssetRepresentation *assetRep = [assetTemp defaultRepresentation];
            resultImage = [UIImage imageWithCGImage:assetRep.fullScreenImage
                                              scale:assetRep.scale
                                        orientation:(UIImageOrientation)assetRep.orientation];
        }
    }
    
    if (completion) {
        completion(resultImage, resultInfo);
    }
}

@end
