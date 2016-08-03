//
//  SYPhotoPickerDelegate.h
//  SYPhotoPicker
//
//  Created by reesun on 16/8/1.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
//

#import <Foundation/Foundation.h>

@class SYPhotoPickerController;
@class SYAsset;

@protocol SYPhotoPickerDelegate <NSObject>

@required

- (void)photoPickerController:(SYPhotoPickerController *)picker didFinishPickingPhotos:(NSArray *)photos;

@optional

- (void)photoPickerController:(SYPhotoPickerController *)picker didSelectPhotoAtIndexPath:(NSIndexPath *)indexPath;
- (void)photoPickerController:(SYPhotoPickerController *)picker didSelectPhoto:(SYAsset *)photo;

@end
