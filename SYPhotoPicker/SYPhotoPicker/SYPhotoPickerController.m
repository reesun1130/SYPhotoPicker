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
#import "SYAlbumsHelper.h"
#import "SYAsset.h"

@interface SYPhotoPickerController () <PHPhotoLibraryChangeObserver, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *arrPhotos;
@property (nonatomic, strong) PHFetchResult *fetchResultAfterChanges;
@property (nonatomic, strong) SYAlbum *album;
@property (nonatomic, weak) id<SYPhotoPickerDelegate>pickerDelegate;

@end

@implementation SYPhotoPickerController

static NSString *const kPhotoCellReuseID = @"kPhotoCell";

- (instancetype)initWithAlbum:(SYAlbum *)album
                     delegate:(id<SYPhotoPickerDelegate>)pickerDelegate {
    if (self = [super init]) {
        _album = album;
        _pickerDelegate = pickerDelegate;
        _arrPhotos = [[NSMutableArray alloc] init];
        _fetchResultAfterChanges = _album.fetchResult;
        
        //监控相册变化
        if (kIOS8OrLater) {
            [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self createTopBar];
    
    //照片流布局
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(kCellWidth, kCellWidth);//每个cell大小
    flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);//间距
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];//竖向滚动
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[SYPhotoCell class] forCellWithReuseIdentifier:kPhotoCellReuseID];//注册cell
    [self.view addSubview:self.collectionView];
    
    __weak SYPhotoPickerController *weakSelf = self;
    
    //load images
    [SYAlbumsHelper fetchAssetsWithAlbum:self.album
                              completion:^(NSArray<SYAsset *> * _Nonnull assets, BOOL success) {
                                  __strong SYPhotoPickerController *strongSelf = weakSelf;
                                  
                                  if (success) {
                                      [strongSelf.arrPhotos addObjectsFromArray:assets];
                                      [strongSelf reloadCollectionData];
                                  }
                              }];
}

- (void)createTopBar {
    // 右按钮
    UIButton *_btnRight = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 100, 20, 100, 44)];
    _btnRight.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _btnRight.titleLabel.font = [UIFont systemFontOfSize:18.0];
    _btnRight.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15);
    _btnRight.exclusiveTouch = YES;
    [_btnRight setTitle:@"确定" forState:UIControlStateNormal];
    [_btnRight setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_btnRight addTarget:self action:@selector(onClickBtnSave:) forControlEvents: UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:_btnRight];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)onClickBtnSave:(UIButton *)btn {
    NSArray *selectedPhotos = [self savedPhotos];
    if (selectedPhotos.count > 0) {
        if (_pickerDelegate && [_pickerDelegate respondsToSelector:@selector(photoPickerController:didFinishPickingPhotos:)]) {
            [_pickerDelegate photoPickerController:self didFinishPickingPhotos:selectedPhotos];
        }
        if (self.pickerDelegate) {
            [(UIViewController *)self.pickerDelegate dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else {
        NSLog(@"还未选择相片!!!");
    }
}

- (void)reloadCollectionData {
    [self.collectionView reloadData];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_arrPhotos.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

- (NSArray *)savedPhotos {
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    for (SYAsset *photo in _arrPhotos) {
        if (photo.selected)
            [photos addObject:photo];
    }
    
    return photos;
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
        SYAsset *asset = self.arrPhotos[indexPath.item];
        cell.thumbnailImage = asset.thumbnailImage;
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
        SYAsset *asset = self.arrPhotos[indexPath.item];
        NSLog(@"image info==%@",asset);
        
        if ([asset isInCloud]) {
            UIAlertView *vAlert = [[UIAlertView alloc] initWithTitle:nil message:@"该图片尚未从iCloud下载，请在系统相册中下载到本地后重新尝试" delegate:nil cancelButtonTitle:@"知道啦~" otherButtonTitles:nil, nil];
            [vAlert show];
        }
        else {
            [self photoTappedAtIndexPath:indexPath];
            
            if (_pickerDelegate && [_pickerDelegate respondsToSelector:@selector(photoPickerController:didSelectPhotoAtIndexPath:)]) {
                [_pickerDelegate photoPickerController:self didSelectPhotoAtIndexPath:indexPath];
            }
            if (_pickerDelegate && [_pickerDelegate respondsToSelector:@selector(photoPickerController:didSelectPhoto:)]) {
                [_pickerDelegate photoPickerController:self didSelectPhoto:asset];
            }
        }
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
    SYAsset *asset = self.arrPhotos[indexPath.item];
    
    BOOL checked = !asset.selected;
    asset.selected = checked;
    
    SYPhotoCell *cell = (SYPhotoCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [cell setChecked:asset.selected];
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    // Check if there are changes to the assets we are showing.
    PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.fetchResultAfterChanges];
    if (collectionChanges == nil) {
        return;
    }
    
    /*
     Change notifications may be made on a background queue. Re-dispatch to the
     main queue before acting on the change as we'll be updating the UI.
     */
    dispatch_async(dispatch_get_main_queue(), ^{
        // Get the new fetch result.
        self.fetchResultAfterChanges = [collectionChanges fetchResultAfterChanges];
        
        NSIndexSet *removedIndexes = [collectionChanges removedIndexes];
        NSIndexSet *insertedIndexes = [collectionChanges insertedIndexes];
        NSIndexSet *changedIndexes = [collectionChanges changedIndexes];
        
        if ([removedIndexes count] > 0) {
            [self.arrPhotos removeObjectsAtIndexes:removedIndexes];
        }
        else if ([insertedIndexes count] > 0) {
            __weak SYPhotoPickerController *weakSelf = self;
            
            //load images
            [SYAlbumsHelper fetchAssetsWithAlbum:self.fetchResultAfterChanges completion:^(NSArray<SYAsset *> * _Nonnull assets, BOOL success) {
                __strong SYPhotoPickerController *strongSelf = weakSelf;
                
                if (success) {
                    [strongSelf.arrPhotos addObjectsFromArray:[assets objectsAtIndexes:insertedIndexes]];
                }
            }];
        }
        else if ([changedIndexes count] > 0) {
            __weak SYPhotoPickerController *weakSelf = self;
            
            //load images
            [SYAlbumsHelper fetchAssetsWithAlbum:self.fetchResultAfterChanges completion:^(NSArray<SYAsset *> * _Nonnull assets, BOOL success) {
                __strong SYPhotoPickerController *strongSelf = weakSelf;
                
                if (success) {
                    [strongSelf.arrPhotos replaceObjectsAtIndexes:changedIndexes withObjects:[assets objectsAtIndexes:changedIndexes]];
                }
            }];
        }
        [self reloadCollectionData];
    });
}

- (void)dealloc {
    if (kIOS8OrLater) {
        [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    }
}

@end
