# v1.1做了架构优化，类似QQ相册选取，首次默认进入相机胶卷，可以返回到相册列表重新进入新的相册，更加简单易用
     v1.1:
     1.添加iCloud图片判断
     2.增加相册和图片对象（分为三个尺寸图片：缩略图，预览图、原图）
     3.增加helper方法
     4.优化相册读取方法
     5.相册中文名字显示

# SYPhotoPicker
SYPhotoPicker photo photoPicker 相册读取及展示demo，适配iOS8，详情请看demo

#使用 实现SYPhotoPickerDelegate代理
      SYAlbumsListController *vcPhoto = [[SYAlbumsListController alloc] initWithDelegate:self];
      [self presentViewController:vcPhoto animated:YES completion:nil];

#代理
    - (void)photoPickerController:(SYPhotoPickerController *)picker didFinishPickingPhotos:(NSArray *)photos {
       NSLog(@"selectedphotos==%@",photos);
    }

    - (void)photoPickerController:(SYPhotoPickerController *)picker didSelectPhoto:(SYAsset *)photo {
       NSLog(@"selectedphoto==%@",photo);
    }
    
    - (void)photoPickerController:(SYPhotoPickerController *)picker didSelectPhotoAtIndexPath:(NSIndexPath *)indexPath {
       NSLog(@"selectedindexpath==%@",indexPath);
    }

# 效果如下：
 ![image](https://github.com/reesun1130/SYPhotoPicker/blob/master/SYPhotoPicker/syphotopicker1.png)
 ![image](https://github.com/reesun1130/SYPhotoPicker/blob/master/SYPhotoPicker/syphotopicker2.png)
 ![image](https://github.com/reesun1130/SYPhotoPicker/blob/master/SYPhotoPicker/syphotopicker3.png)
