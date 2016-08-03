//
//  ViewController.m
//  SYPhotoPicker
//
//  Created by reesun on 16/1/6.
//  Copyright © 2016年 SY. All rights reserved.
//

#import "ViewController.h"
#import "SYAlbumsListController.h"

@interface ViewController () <SYPhotoPickerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClickBtnAlbum:(id)sender {
    SYAlbumsListController *vcPhoto = [[SYAlbumsListController alloc] initWithDelegate:self];
    [self presentViewController:vcPhoto animated:YES completion:nil];
}

#pragma mark - SYPhotoPickerControllerDelegate

- (void)photoPickerController:(SYPhotoPickerController *)picker didFinishPickingPhotos:(NSArray *)photos {
    NSLog(@"selectedphotos==%@",photos);
}

- (void)photoPickerController:(SYPhotoPickerController *)picker didSelectPhoto:(SYAsset *)photo {
    NSLog(@"selectedphoto==%@",photo);
}

- (void)photoPickerController:(SYPhotoPickerController *)picker didSelectPhotoAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selectedindexpath==%@",indexPath);
}

@end
