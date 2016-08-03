/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A collection view cell that displays a thumbnail image.
 */

#import "SYPhotoCell.h"

@interface SYPhotoCell ()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIButton *button;

@end

@implementation SYPhotoCell

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_imageView];
        
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setFrame:CGRectMake(frame.size.width - 25, 3, 22, 22)];
        [_button setBackgroundImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
        [_button setBackgroundImage:[UIImage imageNamed:@"selected_h"] forState:UIControlStateSelected];
        [_button setSelected:NO];
        [_imageView addSubview:_button];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
    _button.selected = NO;
}

- (void)setThumbnailImage:(UIImage *)thumbnailImage {
    _thumbnailImage = thumbnailImage;
    self.imageView.image = thumbnailImage;
}

- (void)setChecked:(BOOL)flag {
    _button.selected = flag;
}

@end
