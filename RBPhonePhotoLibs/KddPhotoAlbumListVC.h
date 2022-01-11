//
//  KddPhotoAlbumListVC.h
//  KddUserClient
//
//  Created by 李世飞 on 2020/7/8.
//  Copyright © 2020 大有. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KddAddPhotoView.h"

NS_ASSUME_NONNULL_BEGIN

@interface KddPhotoAlbumListVC : CommonViewController

@property(nonatomic,assign) NSInteger maxPhotoNum;

@property (strong,nonatomic) NSArray *fetchResult;

@property (nonatomic,copy) void  (^actCompleteBlock)(void);

@property (nonatomic,copy) void (^actCompleteBlockWithArray)(NSArray *array);

@property(nonatomic,strong)KddAddPhotoView * addPhotoView;


@end

NS_ASSUME_NONNULL_END
