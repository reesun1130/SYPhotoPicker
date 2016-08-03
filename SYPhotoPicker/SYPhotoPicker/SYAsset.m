//
//  SYAsset.m
//  SYPhotoPicker
//
//  Created by reesun on 16/8/1.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
//

#import "SYAsset.h"
#import "SYAlbumsHelper.h"

@interface SYAsset ()

@property (nonatomic, strong) PHImageRequestOptions *imageRequestOption;

@end

@implementation SYAsset
@synthesize asset = _asset;
@synthesize originImage = _originImage;
@synthesize thumbnailImage = _thumbnailImage;
@synthesize previewImage = _previewImage;
@synthesize imageOrientation = _imageOrientation;

- (id)initWithAsset:(id)asset {
    if (self = [super init]) {
        _asset = asset;
    }
    
    return self;
}

- (PHImageRequestOptions *)imageRequestOption {
    if (!_imageRequestOption) {
        _imageRequestOption = [[PHImageRequestOptions alloc] init];
        _imageRequestOption.synchronous = YES;
    }
    
    return _imageRequestOption;
}

#pragma mark - Getters

- (UIImageOrientation)imageOrientation {
    return self.thumbnailImage.imageOrientation;
}

- (UIImage *)originImage {
    if (_originImage) {
        return _originImage;
    }
    __block UIImage *resultImage = nil;

    [[SYAlbumsHelper sharedHelper] fetchImageWithAsset:self targetSize:kOriginTargetSize completion:^(UIImage *_Nullable image, NSDictionary *_Nullable info) {
        resultImage = image;
    }];
    _originImage = resultImage;
    
    return _originImage;
}

- (UIImage *)thumbnailImage {
    if (_thumbnailImage) {
        return _thumbnailImage;
    }
    __block UIImage *resultImage;
   
    [[SYAlbumsHelper sharedHelper] fetchImageWithAsset:self targetSize:kThumbnailTargetSize completion:^(UIImage *_Nullable image, NSDictionary *_Nullable info) {
        resultImage = image;
    }];
    _thumbnailImage = resultImage;
    
    return _thumbnailImage;
}

- (UIImage *)previewImage {
    if (_previewImage) {
        return _previewImage;
    }
    __block UIImage *resultImage;
    
    [[SYAlbumsHelper sharedHelper] fetchImageWithAsset:self targetSize:kPreviewTargetSize completion:^(UIImage *_Nullable image, NSDictionary *_Nullable info) {
        resultImage = image;
    }];
    _previewImage = resultImage;
    
    return _previewImage;
}

- (BOOL)isInCloud {
    __block BOOL isCloudImage = NO;
    
    [[SYAlbumsHelper sharedHelper] fetchImageWithAsset:self targetSize:kPreviewTargetSize completion:^(UIImage *_Nullable image, NSDictionary *_Nullable info) {
        if (info) {
            id isIcloud = [info objectForKey:PHImageResultIsInCloudKey];
            if (isIcloud && [isIcloud boolValue]) {
                isCloudImage = YES;
            }
        }
    }];
    
    return isCloudImage;
}

@end
