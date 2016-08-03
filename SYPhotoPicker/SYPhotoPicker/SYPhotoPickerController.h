//
//  SYPhotoPickerController.h
//  SYPhotoPicker
//
//  Created by reesun on 16/1/5.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
//

#import <UIKit/UIKit.h>
#import "SYAlbum.h"
#import "SYPhotoPickerDelegate.h"

@interface SYPhotoPickerController : UIViewController

- (instancetype)initWithAlbum:(SYAlbum *)album
                     delegate:(id<SYPhotoPickerDelegate>)pickerDelegate;
- (void)reloadCollectionData;

@end
