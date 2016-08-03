//
//  SYAlbumsListController.m
//  SYPhotoPicker
//
//  Created by reesun on 16/1/6.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
//

#import "SYAlbumsListController.h"
#import "SYPhotoPickerController.h"
#import "SYAlbumsHelper.h"
#import "SYAlbum.h"

@interface SYAlbumsListController ()

@property (nonatomic, weak) id<SYPhotoPickerDelegate>pickerDelegate;

@end

@implementation SYAlbumsListController

#pragma mark -
#pragma mark View lifecycle

- (instancetype)initWithDelegate:(id<SYPhotoPickerDelegate>)pickerDelegate {
    if (self = [super initWithRootViewController:[[SYAlbumListController alloc] initWithDelegate:pickerDelegate]]) {
        _pickerDelegate = pickerDelegate;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    __weak SYAlbumsListController *weakSelf = self;
    
    //load albums
    [SYAlbumsHelper fetchAlbums:^(NSArray *albums, BOOL success) {
        __strong SYAlbumsListController *strongSelf = weakSelf;
        
        if (success) {
            SYPhotoPickerController *vcPicker = [[SYPhotoPickerController alloc] initWithAlbum:albums[0]
                                                                                      delegate:strongSelf.pickerDelegate];
            vcPicker.title = [albums[0] name];
            [strongSelf pushViewController:vcPicker animated:NO];
        }
        else {
            [strongSelf showUserDenied];
        }
    }];
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

#warning 使用openURL前请添加scheme：prefs
- (void)onClickBtnSetting:(UIButton *)btn {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root"]];
}

@end


@interface SYAlbumListController () <PHPhotoLibraryChangeObserver, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *arrAlbums;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) id<SYPhotoPickerDelegate>pickerDelegate;

@end

@implementation SYAlbumListController

#pragma mark -
#pragma mark View lifecycle

- (instancetype)initWithDelegate:(id<SYPhotoPickerDelegate>)pickerDelegate {
    if (self = [super init]) {
        _pickerDelegate = pickerDelegate;
        _arrAlbums = [[NSMutableArray alloc] init];
        
        //监控相册变化
        if (kIOS8OrLater) {
            [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
        }
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    [self createTopBar];
    
    __weak SYAlbumListController *weakSelf = self;
    
    //load albums
    [SYAlbumsHelper fetchAlbums:^(NSArray *albums, BOOL success) {
        __strong SYAlbumListController *strongSelf = weakSelf;
        
        if (success) {
            [strongSelf.arrAlbums addObjectsFromArray:albums];
            [strongSelf reloadTableView];
        }
    }];
}

- (void)createTopBar {
    self.title = @"相册";
    
    CGFloat btnWidth = 100;
    
    // 右按钮
    UIButton *_btnRight = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - btnWidth, 20, btnWidth, 44)];
    _btnRight.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _btnRight.titleLabel.font = [UIFont systemFontOfSize:18.0];
    _btnRight.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15);
    _btnRight.exclusiveTouch = YES;
    [_btnRight setTitle:@"关闭" forState:UIControlStateNormal];
    [_btnRight setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_btnRight addTarget:self action:@selector(onClickBtnBack:) forControlEvents: UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:_btnRight];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)onClickBtnBack:(UIButton *)btn {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)reloadTableView {
    if (!self.tableView) {
        self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        self.tableView.rowHeight = 50;
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        [self.view addSubview:self.tableView];
    }
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = _arrAlbums.count;
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    if (_arrAlbums.count && _arrAlbums.count > indexPath.row) {
        SYAlbum *mAlbum = _arrAlbums[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@(%ld)",mAlbum.name,mAlbum.assetCount];
        cell.imageView.image = mAlbum.thumbnail;
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_arrAlbums.count && _arrAlbums.count > indexPath.row) {
        SYAlbum *mAlbum = _arrAlbums[indexPath.row];
        
        SYPhotoPickerController *vcPicker = [[SYPhotoPickerController alloc] initWithAlbum:mAlbum
                                                                                  delegate:self.pickerDelegate];
        vcPicker.title = mAlbum.name;
        [self.navigationController pushViewController:vcPicker animated:YES];
    }
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
        
        [_arrAlbums enumerateObjectsUsingBlock:^(SYAlbum *collectionsFetchResult, NSUInteger index, BOOL *stop) {
            PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:collectionsFetchResult.fetchResult];
            
            if (changeDetails != nil) {
                PHFetchResult *fetchResultAfterChanges = [changeDetails fetchResultAfterChanges];
                SYAlbum *mal = [[SYAlbum alloc] initWithFetchResult:fetchResultAfterChanges
                                                               name:collectionsFetchResult.name
                                                         assetCount:fetchResultAfterChanges.count];
                [updatedSectionFetchResults replaceObjectAtIndex:index withObject:mal];
                reloadRequired = YES;
            }
        }];
        
        if (reloadRequired) {
            _arrAlbums = updatedSectionFetchResults;
            [self reloadTableView];
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
    if (kIOS8OrLater) {
        [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    }
}

@end
