//
//  SYPhotoPickerController.h
//  SYPhotoPicker
//
//  Created by reesun on 16/1/5.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "SYPhoto.h"
#import "SYAlbumsListController.h"

@class SYPhotoPickerController;
@protocol SYPhotoPickerDelegate <NSObject>

@required

- (void)photoPickerController:(SYPhotoPickerController *)picker didFinishPickingPhotos:(NSArray *)photos;

@optional

- (void)photoPickerController:(SYPhotoPickerController *)picker didSelectPhotoAtIndexPath:(NSIndexPath *)indexPath;
- (void)photoPickerController:(SYPhotoPickerController *)picker didSelectPhoto:(SYPhoto *)photo;
- (void)photoPickerControllerDidCancel:(SYPhotoPickerController *)picker;

@end

@interface SYPhotoPickerController : UIViewController

//8.0 and later
@property (nonatomic, strong) PHFetchResult *assetsFetchResults;
@property (nonatomic, strong) PHAssetCollection *assetCollection;

//pre 8.0
@property (nonatomic, strong) ALAssetsGroup *assetGroup;

@property (nonatomic, weak) id<SYPhotoPickerDelegate>delegate;
@property (nonatomic, weak) SYAlbumsListController *parentController;//实现这个会直接关闭父controller

- (void)reloadCollectionData;

@end
