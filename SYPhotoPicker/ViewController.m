//
//  ViewController.m
//  SYPhotoPicker
//
//  Created by reesun on 16/1/6.
//  Copyright © 2016年 SY. All rights reserved.
//

#import "ViewController.h"
#import "SYAlbumsListController.h"

@interface ViewController () <SYAlbumsListDelegate>

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
    SYAlbumsListController *vcPhoto = [[SYAlbumsListController alloc] init];
    vcPhoto.delegate = self;
    [self presentViewController:vcPhoto animated:YES completion:nil];
}

#pragma mark - SYAlbumsListDelegate

- (void)albumsListController:(SYAlbumsListController *)picker didFinishPickingPhotos:(NSArray *)photos {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"didFinishPickingPhotos==%@",photos);
}

- (void)albumsListControllerDidCancel:(SYAlbumsListController *)picker {
    NSLog(@"albumsListControllerDidCancel");
}

@end
