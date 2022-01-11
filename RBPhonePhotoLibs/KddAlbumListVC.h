//
//  KddAlbumListVC.h
//  KddUserClient
//
//  Created by 李世飞 on 2020/7/8.
//  Copyright © 2020 大有. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KddAlbumListVC : CommonViewController

//当前最大还可以选择多少张图片
@property(nonatomic,assign)NSInteger maxCount;

//图片选择成功回调NSArray<UIImage>
@property (nonatomic,copy)  void(^completePhotosArray)(NSArray *photos);


@end

NS_ASSUME_NONNULL_END
