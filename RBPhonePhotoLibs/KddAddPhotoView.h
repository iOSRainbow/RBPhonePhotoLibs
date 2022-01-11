//
//  KddAddPhotoView.h
//  KddUserClient
//
//  Created by 李世飞 on 2020/7/8.
//  Copyright © 2020 大有. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KddAddPhotoView : UIView<UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate>
{
    
    UICollectionView * smallPhotoCollectView;
    UIButton * sureBtn;
    UIImageView * paoImg;
    
    UIScrollView * scr;
    UILabel * labPhotoNum;
    
    NSInteger currentPage;
}

@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) PHImageRequestOptions *requestOption;


@property(nonatomic,strong)NSArray * photos;

@property(nonatomic,copy)void(^resutlPhoto)(NSArray*photos);

@end

NS_ASSUME_NONNULL_END
