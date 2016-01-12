//
//  SYAlbumsHelper.m
//  SYPhotoPicker
//
//  Created by reesun on 16/1/6.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
//

#import "SYAlbumsHelper.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@implementation SYAlbumsHelper

//是否可以访问照片
+ (BOOL)canAccessAlbums {
    BOOL _isAuth = YES;
    if (kSYSTEM_VERSION > 8.0) {
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
+ (void)fetchAlbums:(void(^)(NSArray *albums, BOOL success))block {
    NSMutableArray *_arrAlbums = [[NSMutableArray alloc] init];
    if (kSYSTEM_VERSION > 8.0) {
        PHAuthorizationStatus author = [PHPhotoLibrary authorizationStatus];
        if (author == PHAuthorizationStatusRestricted || author == PHAuthorizationStatusDenied){
            //无权限
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) {
                    block(_arrAlbums, NO);
                }
            });
        }
        else {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    PHFetchResult *allPhotos = [PHAsset fetchAssetsWithOptions:nil];
                    [_arrAlbums addObject:allPhotos];

                    PHFetchResult *albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
                    
                    if (albums.count > 0 && [SYAlbumsHelper hasPhoto:albums]) {
                        [_arrAlbums addObject:albums];
                    }

                    //自带智能分组相册只保留<个人收藏>
                    PHFetchResult *smartAlbumsFav = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumFavorites options:nil];
                    
                    if (smartAlbumsFav.count > 0 && [SYAlbumsHelper hasPhoto:smartAlbumsFav]) {
                        [_arrAlbums addObject:smartAlbumsFav];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (block) {
                            block(_arrAlbums, YES);
                        }
                    });
                }
                else {
                    if (status != PHAuthorizationStatusNotDetermined) {
                        //无权限
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (block) {
                                block(_arrAlbums, NO);
                            }
                        });
                    }
                }
            }];
        }
    }
    else {
        ALAssetsLibrary *_library = [[ALAssetsLibrary alloc] init];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
                if (group == nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (block) {
                            block(_arrAlbums, NO);
                        }
                    });
                    
                    return;
                }
                
                NSString *sGroupPropertyName = (NSString *)[group valueForProperty:ALAssetsGroupPropertyName];
                NSUInteger nType = [[group valueForProperty:ALAssetsGroupPropertyType] intValue];
                
                if (([[sGroupPropertyName lowercaseString] isEqualToString:@"camera roll"] || [sGroupPropertyName isEqualToString:@"相机胶卷"]) && nType == ALAssetsGroupSavedPhotos) {
                    [_arrAlbums insertObject:group atIndex:0];
                }
                else {
                    [_arrAlbums addObject:group];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (block) {
                        block(_arrAlbums, YES);
                    }
                });
            };
            
            void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (block) {
                        block(_arrAlbums, NO);
                    }
                });
            };
            
            [_library enumerateGroupsWithTypes:ALAssetsGroupAll
                                    usingBlock:assetGroupEnumerator
                                  failureBlock:assetGroupEnumberatorFailure];
        });
    }
}

+ (BOOL)hasPhoto:(PHFetchResult *)fetchResult {
    BOOL flag = NO;
    
    //最新的放在前面
    PHCollection *collection = fetchResult[0];
    if ([collection isKindOfClass:[PHAssetCollection class]]) {
        PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
        fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    }
    
    if (fetchResult && fetchResult.count > 0) {
        flag = YES;
    }
    
    return flag;
}

@end
