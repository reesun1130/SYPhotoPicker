//
//  SYAlbumsHelper.h
//  SYPhotoPicker
//
//  Created by reesun on 16/1/6.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
//

#import <Foundation/Foundation.h>

#define kSYSTEM_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

@interface SYAlbumsHelper : NSObject

//是否可以访问照片
+ (BOOL)canAccessAlbums;

//读取列表
+ (void)fetchAlbums:(void(^)(NSArray *Albums, BOOL success))block;

@end
