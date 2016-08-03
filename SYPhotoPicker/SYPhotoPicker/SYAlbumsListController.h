//
//  SYAlbumsListController.h
//  SYPhotoPicker
//
//  Created by reesun on 16/1/6.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
//

#import <UIKit/UIKit.h>
#import "SYPhotoPickerDelegate.h"

@interface SYAlbumsListController : UINavigationController

- (instancetype)initWithDelegate:(id<SYPhotoPickerDelegate>)pickerDelegate;

@end

@interface SYAlbumListController : UIViewController

- (instancetype)initWithDelegate:(id<SYPhotoPickerDelegate>)pickerDelegate;

@end
