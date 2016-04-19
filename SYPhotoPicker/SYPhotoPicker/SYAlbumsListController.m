//
//  SYAlbumsListController.m
//  SYPhotoPicker
//
//  Created by reesun on 16/1/6.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
//

#import "SYAlbumsListController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import "SYPhotoPickerController.h"
#import <PhotosUI/PhotosUI.h>
#import "SYAlbumsHelper.h"

@interface SYAlbumsListController () <PHPhotoLibraryChangeObserver, UITableViewDataSource, UITableViewDelegate, SYPhotoPickerDelegate>

@property (nonatomic, strong) NSMutableArray *arrAlbums;
@property (nonatomic, strong) NSMutableArray *arrResults;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) ALAssetsLibrary *library;

@end

@implementation SYAlbumsListController

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    [self createTopBar];

    _arrAlbums = [[NSMutableArray alloc] init];
    _arrResults = [[NSMutableArray alloc] init];
    _imageManager = [[PHCachingImageManager alloc] init];

    __weak SYAlbumsListController *weakSelf = self;
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];

    [SYAlbumsHelper fetchAlbums:^(NSArray *albums, BOOL success) {
        if (success) {
            [weakSelf.arrAlbums addObjectsFromArray:albums];
            [weakSelf reloadTableView];
        }
        else {
            [weakSelf showUserDenied];
        }
    }];
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
    [_btnRight setTitle:@"保存" forState:UIControlStateNormal];
    [_btnRight setTitleColor:_btnTitle.titleLabel.textColor forState:UIControlStateNormal];
    [_btnRight addTarget:self action:@selector(onClickBtnSave:) forControlEvents: UIControlEventTouchUpInside];
    
    [vTopBar addSubview:_btnTitle];
    [vTopBar addSubview:_btnLeft];
    [vTopBar addSubview:_btnRight];
    [self.view addSubview:vTopBar];
}

- (void)onClickBtnBack:(UIButton *)btn {
    if (_delegate && [_delegate respondsToSelector:@selector(albumsListControllerDidCancel:)]) {
        [_delegate albumsListControllerDidCancel:self];
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onClickBtnSave:(UIButton *)btn {
    if (_arrResults.count > 0) {
        if (_delegate && [_delegate respondsToSelector:@selector(albumsListController:didFinishPickingPhotos:)]) {
            [_delegate albumsListController:self didFinishPickingPhotos:_arrResults];
        }
    }
    else {
        NSLog(@"还未选择相片!!!");
    }
}

- (void)reloadTableView {
    if (!self.tableView) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        [self.view addSubview:self.tableView];
    }
    [self.tableView reloadData];
}

- (void)showUserDenied {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.textColor = [UIColor redColor];
    [self.view addSubview:label];
    
    NSString *str = [NSString stringWithFormat:@"您没有权限访问相册\n\n请到“设置-隐私-照片”里\n允许”SYPhotoPicker“访问"];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20.0] range:[str rangeOfString:@"您没有权限访问相册"]];
    label.attributedText = attributedString;
    [label sizeToFit];
    label.frame = CGRectMake(0, 0, label.frame.size.width, label.frame.size.height);
    label.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    
    UIButton *settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    settingBtn.frame = CGRectMake(0, 0, 140, 40);
    settingBtn.backgroundColor = [UIColor blueColor];
    settingBtn.layer.cornerRadius = 5;
    settingBtn.layer.masksToBounds = YES;
    [settingBtn setTitle:@"去设置" forState:UIControlStateNormal];
    [settingBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    settingBtn.center = CGPointMake(self.view.frame.size.width / 2, label.center.y + 5 + 20 + label.frame.size.height / 2);
    [settingBtn addTarget:self action:@selector(onClickBtnSetting:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:settingBtn];
}

- (void)onClickBtnSetting:(UIButton *)btn {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root"]];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kSYSTEM_VERSION > 8.0 ? _arrAlbums.count : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = _arrAlbums.count;
    
    if (kSYSTEM_VERSION > 8.0) {
        if (section == 0) {
            numberOfRows = 1;
        }
        else {
            PHFetchResult *fetchResult = _arrAlbums[section];
            numberOfRows = fetchResult.count;
        }
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    if (kSYSTEM_VERSION > 8.0) {
        PHFetchResult *fetchResult = _arrAlbums[indexPath.section];

        if (indexPath.section == 0) {
            cell.textLabel.text = @"相机胶卷";
        }
        else {
            PHCollection *collection = fetchResult[indexPath.row];

            if ([collection isKindOfClass:[PHAssetCollection class]]) {
                PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
                fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
            }
            cell.textLabel.text = [NSString stringWithFormat:@"%@(%ld)",collection.localizedTitle,fetchResult.count];
        }
        
        if (fetchResult && fetchResult.count > 0) {
            //取最新的一张图片
            PHAsset *asset = [fetchResult lastObject];
            
            if (asset) {
                CGFloat width = [UIScreen mainScreen].scale * 50;
                
                [self.imageManager requestImageForAsset:asset
                                             targetSize:CGSizeMake(width, width)
                                            contentMode:PHImageContentModeAspectFill
                                                options:nil
                                          resultHandler:^(UIImage *result, NSDictionary *info) {
                                              cell.imageView.image = result;
                                          }];
            }
        }
    }
    else {
        ALAssetsGroup *g = (ALAssetsGroup *)[_arrAlbums objectAtIndex:indexPath.row];
        [g setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        NSString *groupName = [g valueForProperty:ALAssetsGroupPropertyName];
        if ([[groupName lowercaseString] isEqualToString:@"camera roll"])
            groupName = @"相机胶卷";
        
        cell.textLabel.text = groupName;
        [cell.imageView setImage:[UIImage imageWithCGImage:[(ALAssetsGroup *)[_arrAlbums objectAtIndex:indexPath.row] posterImage]]];
    }
    
//    [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];

    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SYPhotoPickerController *vcPicker = [[SYPhotoPickerController alloc] init];
    vcPicker.delegate = self;
    vcPicker.parentController = self;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    vcPicker.title = cell.textLabel.text;
    
    if (kSYSTEM_VERSION > 8.0) {
        PHFetchResult *fetchResult = _arrAlbums[indexPath.section];
        
        if (indexPath.section == 0) {
            vcPicker.assetsFetchResults = fetchResult;
        }
        else {
            PHCollection *collection = fetchResult[indexPath.row];
            if (![collection isKindOfClass:[PHAssetCollection class]]) {
                return;
            }
            
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
            
            vcPicker.assetsFetchResults = assetsFetchResult;
            vcPicker.assetCollection = assetCollection;
        }
    }
    else {
        vcPicker.assetGroup = [_arrAlbums objectAtIndex:indexPath.row];
        [vcPicker.assetGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
    }
    [self presentViewController:vcPicker animated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    if (kSYSTEM_VERSION > 8.0) {
//        return @[@"Camera Roll",@"Albums",@"Smart Albums"][section];
//    }
//    
//    return @"";
//}

#pragma mark - SYPhotoPickerControllerDelegate

- (void)photoPickerController:(SYPhotoPickerController *)picker didFinishPickingPhotos:(NSArray *)photos {
    NSLog(@"selectedphotos==%@",photos);
    if (photos && photos.count > 0) {
        [_arrResults removeAllObjects];
        [_arrResults addObjectsFromArray:photos];
    }
}

- (void)photoPickerController:(SYPhotoPickerController *)picker didSelectPhoto:(SYPhoto *)photo {
    NSLog(@"selectedphoto==%@",photo);
}

- (void)photoPickerController:(SYPhotoPickerController *)picker didSelectPhotoAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selectedindexpath==%@",indexPath);
}

- (void)photoPickerControllerDidCancel:(SYPhotoPickerController *)picker {
    NSLog(@"photoPickerControllerDidCancel");
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    /*
     Change notifications may be made on a background queue. Re-dispatch to the
     main queue before acting on the change as we'll be updating the UI.
     */
    dispatch_async(dispatch_get_main_queue(), ^{
        // Loop through the section fetch results, replacing any fetch results that have been updated.
        NSMutableArray *updatedSectionFetchResults = [_arrAlbums mutableCopy];
        __block BOOL reloadRequired = NO;
        
        [_arrAlbums enumerateObjectsUsingBlock:^(PHFetchResult *collectionsFetchResult, NSUInteger index, BOOL *stop) {
            PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:collectionsFetchResult];
            
            if (changeDetails != nil) {
                [updatedSectionFetchResults replaceObjectAtIndex:index withObject:[changeDetails fetchResultAfterChanges]];
                reloadRequired = YES;
            }
        }];
        
        if (reloadRequired) {
            _arrAlbums = updatedSectionFetchResults;
            [self.tableView reloadData];
        }
    });
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"didReceiveMemoryWarning...");
}

- (void)dealloc {
    NSLog(@"dealloc...");
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

@end
