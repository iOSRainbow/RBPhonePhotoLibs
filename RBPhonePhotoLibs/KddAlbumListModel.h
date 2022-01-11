//
//  KddAlbumListModel.h
//  KddUserClient
//
//  Created by 李世飞 on 2020/7/9.
//  Copyright © 2020 大有. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface KddAlbumListModel : NSObject

/**
 *  组名
 */
@property (nonatomic , copy) NSString *groupName;

/**
 *  第一张图片
 */
@property (nonatomic , strong) PHAsset * firstAsset;

/**
 *  组里面的图片个数
 */
@property (nonatomic , assign) NSInteger assetsCount;

/**
 *  组里面的所有图片
 */
@property(nonatomic,strong)PHAssetCollection * assetCollection;

@end

NS_ASSUME_NONNULL_END
