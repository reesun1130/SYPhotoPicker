//
//  SYPhotoPickerController.m
//  SYPhotoPicker
//
//  Created by reesun on 16/1/5.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
//

#import "SYPhotoPickerController.h"
#import "SYPhotoCell.h"
#import "NSIndexSet+Convenience.h"
#import "UICollectionView+Convenience.h"
#import <PhotosUI/PhotosUI.h>
#import "SYPhotoCell.h"
#import "SYPhoto.h"
#import "SYAlbumsHelper.h"

#define kCellWidth (([UIScreen mainScreen].bounds.size.width - 50) / 4.0)//每行四个image

@interface SYPhotoPickerController () <PHPhotoLibraryChangeObserver, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *arrPhotos;

@property CGRect previousPreheatRect;

@end

@implementation SYPhotoPickerController

static NSString *const kPhotoCellReuseID = @"kPhotoCell";
static CGSize AssetGridThumbnailSize;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _arrPhotos = [[NSMutableArray alloc] init];
    [self createTopBar];
    
    //照片流布局
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(kCellWidth, kCellWidth);//每个cell大小
    flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);//间距
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];//竖向滚动
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64) collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[SYPhotoCell class] forCellWithReuseIdentifier:kPhotoCellReuseID];//注册cell
    [self.view addSubview:self.collectionView];

    if (kSYSTEM_VERSION > 8.0) {
        _imageManager = [[PHCachingImageManager alloc] init];
        [self resetCachedAssets];
        
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    }
}

- (void)dealloc {
    if (kSYSTEM_VERSION > 8.0) {
        [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cellSize = ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).itemSize;
    AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
        
    [self reloadCollectionData];
}

- (void)preparePhotos {
    if (kSYSTEM_VERSION > 8.0) {
        [self.assetsFetchResults enumerateObjectsUsingBlock:^(PHAsset *result, NSUInteger index, BOOL *stop) {
            if(result) {
                SYPhoto *photo = [[SYPhoto alloc] init];
                photo.selected = NO;
                photo.assetPH = result;
                [self.arrPhotos addObject:photo];
            }
        }];
    }
    else {
        [self.assetGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if(result) {
                SYPhoto *photo = [[SYPhoto alloc] init];
                photo.selected = NO;
                photo.assetAL = result;
                [self.arrPhotos addObject:photo];
            }
        }];
    }
}

- (void)reloadCollectionData {
    [self preparePhotos];
    [self.collectionView reloadData];
}

- (void)createTopBar {
    UIView *vTopBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    vTopBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    vTopBar.backgroundColor = [UIColor colorWithRed:250 / 255.0 green:250 / 255.0 blue:250 / 255.0 alpha:0.94];
    CGFloat btnWidth = 100;
    
    // 标题
    UIButton *_btnTitle = [[UIButton alloc] initWithFrame:CGRectMake(btnWidth, 20, self.view.frame.size.width - btnWidth * 2, 44)];
    _btnTitle.titleLabel.font = [UIFont systemFontOfSize:20.0];
    _btnTitle.exclusiveTouch = YES;
    [_btnTitle setTitle:@"相册" forState:UIControlStateNormal];
    [_btnTitle setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    // 左按钮
    UIButton *_btnLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, btnWidth, _btnTitle.frame.size.height)];
    _btnLeft.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _btnLeft.titleLabel.font = [UIFont systemFontOfSize:18.0];
    _btnLeft.exclusiveTouch = YES;
    _btnLeft.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    [_btnLeft setTitle:@"关闭" forState:UIControlStateNormal];
    [_btnLeft setTitleColor:_btnTitle.titleLabel.textColor forState:UIControlStateNormal];
    [_btnLeft addTarget:self action:@selector(onClickBtnBack:) forControlEvents: UIControlEventTouchUpInside];
    
    // 右按钮
    UIButton *_btnRight = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - btnWidth, 20, btnWidth, _btnTitle.frame.size.height)];
    _btnRight.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _btnRight.titleLabel.font = [UIFont systemFontOfSize:18.0];
    _btnRight.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15);
    _btnRight.exclusiveTouch = YES;
    [_btnRight setTitle:@"确定" forState:UIControlStateNormal];
    [_btnRight setTitleColor:_btnTitle.titleLabel.textColor forState:UIControlStateNormal];
    [_btnRight addTarget:self action:@selector(onClickBtnSave:) forControlEvents: UIControlEventTouchUpInside];
    
    [vTopBar addSubview:_btnTitle];
    [vTopBar addSubview:_btnLeft];
    [vTopBar addSubview:_btnRight];
    [self.view addSubview:vTopBar];
}

- (void)onClickBtnBack:(UIButton *)btn {
    if (_delegate && [_delegate respondsToSelector:@selector(photoPickerControllerDidCancel:)]) {
        [_delegate photoPickerControllerDidCancel:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onClickBtnSave:(UIButton *)btn {
    NSArray *selectedPhotos = [self savedPhotos];
    if (selectedPhotos.count > 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(photoPickerController:didFinishPickingPhotos:)]) {
            [self.delegate photoPickerController:self didFinishPickingPhotos:selectedPhotos];
        }
        if (self.parentController) {
            [self dismissViewControllerAnimated:NO completion:nil];
            [self.parentController.delegate albumsListController:self.parentController didFinishPickingPhotos:selectedPhotos];
        }
        else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else {
        NSLog(@"还未选择相片!!!");
    }
}

- (NSArray *)savedPhotos {
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    for (SYPhoto *photo in _arrPhotos) {
        if (photo.selected)
            [photos addObject:photo];
    }
    
    return photos;
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    // Check if there are changes to the assets we are showing.
    PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.assetsFetchResults];
    if (collectionChanges == nil) {
        return;
    }
    
    /*
     Change notifications may be made on a background queue. Re-dispatch to the
     main queue before acting on the change as we'll be updating the UI.
     */
    dispatch_async(dispatch_get_main_queue(), ^{
        // Get the new fetch result.
        self.assetsFetchResults = [collectionChanges fetchResultAfterChanges];
        
        UICollectionView *collectionView = self.collectionView;
        
        if (![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves]) {
            // Reload the collection view if the incremental diffs are not available
            [collectionView reloadData];
        }
        else {
            /*
             Tell the collection view to animate insertions and deletions if we
             have incremental diffs.
             */
            [collectionView performBatchUpdates:^{
                NSIndexSet *removedIndexes = [collectionChanges removedIndexes];
                if ([removedIndexes count] > 0) {
                    [collectionView deleteItemsAtIndexPaths:[removedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                }
                
                NSIndexSet *insertedIndexes = [collectionChanges insertedIndexes];
                if ([insertedIndexes count] > 0) {
                    [collectionView insertItemsAtIndexPaths:[insertedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                }
                
                NSIndexSet *changedIndexes = [collectionChanges changedIndexes];
                if ([changedIndexes count] > 0) {
                    [collectionView reloadItemsAtIndexPaths:[changedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                }
            } completion:NULL];
        }
        
        [self resetCachedAssets];
    });
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.arrPhotos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SYPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellReuseID forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[SYPhotoCell alloc] initWithFrame:CGRectMake(0, 0, kCellWidth, kCellWidth)];
    }
    NSUInteger photoCount = self.arrPhotos.count;
    if (photoCount > 0 && photoCount > indexPath.item) {
        SYPhoto *asset = self.arrPhotos[indexPath.item];

        if (kSYSTEM_VERSION > 8.0) {
            NSUInteger photoCount = self.assetsFetchResults.count;
            if (photoCount > 0 && photoCount > indexPath.item) {
                //最新的放在前面
                PHAsset *asset = self.assetsFetchResults[photoCount - indexPath.item - 1];
                cell.representedAssetIdentifier = asset.localIdentifier;
                
                [self.imageManager requestImageForAsset:asset
                                             targetSize:AssetGridThumbnailSize
                                            contentMode:PHImageContentModeAspectFill
                                                options:nil
                                          resultHandler:^(UIImage *result, NSDictionary *info) {
                                              if ([cell.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
                                                  cell.thumbnailImage = result;
                                              }
                                          }];
            }
        }
        else {
            cell.thumbnailImage = [UIImage imageWithCGImage:asset.assetAL.thumbnail];
        }

        [cell setChecked:asset.selected];
    }

    return cell;
}

//定义每个UICollectionViewCell 的大小
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    return CGSizeMake(kCellWidth, kCellWidth);
//}

////定义每个Section 的 margin
//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//    return UIEdgeInsetsMake(10, 10, 0, 10);//分别为上、左、下、右
//}

//每个section中不同的行之间的行间距
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
//    return 10;
//}

////每个item之间的间距
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
//    return 3;
//}

//选择了某个cell
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger photoCount = self.arrPhotos.count;
    if (photoCount > 0 && photoCount > indexPath.item) {
        [self photoTappedAtIndexPath:indexPath];
        
        SYPhoto *asset = self.arrPhotos[indexPath.item];

        if (_delegate && [_delegate respondsToSelector:@selector(photoPickerController:didSelectPhotoAtIndexPath:)]) {
            [_delegate photoPickerController:self didSelectPhotoAtIndexPath:indexPath];
        }
        if (_delegate && [_delegate respondsToSelector:@selector(photoPickerController:didSelectPhoto:)]) {
            [_delegate photoPickerController:self didSelectPhoto:asset];
        }
        NSLog(@"image info==%@",asset);
    }
}

//取消选择了某个cell
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor redColor]];
    NSLog(@"image info==");
}

- (void)checkButtonTapped:(id)sender event:(id)event {
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:currentTouchPosition];
    
    if (indexPath) {
        [self photoTappedAtIndexPath:indexPath];
    }
}

- (void)photoTappedAtIndexPath:(NSIndexPath *)indexPath {
    SYPhoto *asset = self.arrPhotos[indexPath.item];
    
    BOOL checked = !asset.selected;
    asset.selected = checked;
    
    SYPhotoCell *cell = (SYPhotoCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [cell setChecked:asset.selected];
}

#pragma mark - Asset Caching

- (void)resetCachedAssets {
    if (kSYSTEM_VERSION > 8.0) {
        [self.imageManager stopCachingImagesForAllAssets];
        self.previousPreheatRect = CGRectZero;
    }
}

@end
