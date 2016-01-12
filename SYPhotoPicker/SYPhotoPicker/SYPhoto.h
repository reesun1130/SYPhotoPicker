//
//  SYPhoto.h
//  SYPhotoPicker
//
//  Created by reesun on 16/1/6.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/ALAsset.h>
#import <Photos/PHAsset.h>

@interface SYPhoto : NSObject

@property (nonatomic, strong) ALAsset *assetAL;
@property (nonatomic, strong) PHAsset *assetPH;

@property (nonatomic) BOOL selected;

@end
