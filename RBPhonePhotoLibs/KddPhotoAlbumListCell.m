//
//  KddPhotoAlbumListCell.m
//  KddUserClient
//
//  Created by 李世飞 on 2020/7/8.
//  Copyright © 2020 大有. All rights reserved.
//

#import "KddPhotoAlbumListCell.h"

@interface KddPhotoAlbumListCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *chooseImageView;

@end

@implementation KddPhotoAlbumListCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView
{
    _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    [self.contentView addSubview:_imageView];
    
    _chooseImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_imageView.width-30, 10,20,20)];
    [self.contentView addSubview:_chooseImageView];
}

- (void)setThumbnailImage:(UIImage *)thumbnailImage
{
    _thumbnailImage = thumbnailImage;
    _imageView.image = thumbnailImage;
}

-(void)setChooseImage:(UIImage *)chooseImage{
    
    _chooseImage=chooseImage;
    _chooseImageView.image=chooseImage;
}

@end
