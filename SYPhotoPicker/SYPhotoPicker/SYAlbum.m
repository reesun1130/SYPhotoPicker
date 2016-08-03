//
//  SYAlbum.m
//  SYPhotoPicker
//
//  Created by reesun on 16/8/1.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
//

#import "SYAlbum.h"
#import "SYAlbumsHelper.h"

@implementation SYAlbum

- (id _Nonnull)initWithFetchResult:(id _Nonnull)fetchResult name:(NSString * _Nonnull)name assetCount:(NSUInteger)assetCount {
    if (self = [super init]) {
        _fetchResult = fetchResult;
        _assetCount = assetCount;
        _name = name;
    }
    
    return self;
}

- (UIImage *_Nonnull)displayHeaderImage {
    __block UIImage *img;
    
    if ([_fetchResult isKindOfClass:[PHFetchResult class]]) {
        [[SYAlbumsHelper sharedHelper] fetchImageWithAsset:[_fetchResult lastObject] targetSize:kThumbnailTargetSize completion:^(UIImage *_Nullable image, NSDictionary *_Nullable info) {
            img = image;
        }];
    }
    else if ([_fetchResult isKindOfClass:[ALAssetsGroup class]]) {
        img = [UIImage imageWithCGImage:[_fetchResult posterImage]];
    }
    
    return img;
}

@end
