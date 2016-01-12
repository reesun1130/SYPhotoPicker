//
//  SYAlbumsListController.h
//  SYPhotoPicker
//
//  Created by reesun on 16/1/6.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
//

#import <UIKit/UIKit.h>

@class SYAlbumsListController;
@protocol SYAlbumsListDelegate <NSObject>

@required

- (void)albumsListController:(SYAlbumsListController *)picker didFinishPickingPhotos:(NSArray *)photos;

@optional

- (void)albumsListControllerDidCancel:(SYAlbumsListController *)picker;

@end

@interface SYAlbumsListController : UIViewController

@property (nonatomic, weak) id<SYAlbumsListDelegate>delegate;

@end
