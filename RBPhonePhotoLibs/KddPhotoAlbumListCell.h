//
//  KddPhotoAlbumListCell.h
//  KddUserClient
//
//  Created by 李世飞 on 2020/7/8.
//  Copyright © 2020 大有. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KddPhotoAlbumListCell : UICollectionViewCell

@property (nonatomic, strong) NSString *representedAssetIdentifier;
@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, strong) UIImage *chooseImage;

@end

NS_ASSUME_NONNULL_END
