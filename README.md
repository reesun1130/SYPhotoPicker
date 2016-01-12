# SYPhotoPicker
SYPhotoPicker photo photoPicker 相册读取及展示demo，适配iOS8，详情请看demo

#使用
    SYAlbumsListController *vcPhoto = [[SYAlbumsListController alloc] init];
    vcPhoto.delegate = self;
    [self presentViewController:vcPhoto animated:YES completion:nil];

#代理
   - (void)albumsListController:(SYAlbumsListController *)picker didFinishPickingPhotos:(NSArray *)photos {
       [picker dismissViewControllerAnimated:YES completion:nil];
       NSLog(@"didFinishPickingPhotos==%@",photos);
   }

   - (void)albumsListControllerDidCancel:(SYAlbumsListController *)picker {
       NSLog(@"albumsListControllerDidCancel");
   }

# 效果如下：
 ![image](https://github.com/reesun1130/SYPhotoPicker/blob/master/SYPhotoPicker/syphotopicker1.png)
 ![image](https://github.com/reesun1130/SYPhotoPicker/blob/master/SYPhotoPicker/syphotopicker2.png)
