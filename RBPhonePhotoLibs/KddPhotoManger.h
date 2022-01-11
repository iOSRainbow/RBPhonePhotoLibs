//
//  KddPhotoManger.h
//  KddUserClient
//
//  Created by 李世飞 on 2020/7/9.
//  Copyright © 2020 大有. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KddPhotoManger : NSObject

+(instancetype)sharedInstance;

/**
 *  获取所有相册分组List
 */
-(NSArray*)getAllPhotoList;

/**
 * 获取asset相对应的照片
 */
-(void)getImageByAsset:(PHAsset *)asset makeSize:(CGSize)size makeResizeMode:(PHImageRequestOptionsResizeMode)resizeMode deliveryMode:(PHImageRequestOptionsDeliveryMode)deliveryMode completion:(void (^)(UIImage *))completion;

//获得指定相册的所有照片
-(NSArray*)getAssetsInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending;

@end

NS_ASSUME_NONNULL_END
