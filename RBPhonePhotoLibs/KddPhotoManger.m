//
//  KddPhotoManger.m
//  KddUserClient
//
//  Created by 李世飞 on 2020/7/9.
//  Copyright © 2020 大有. All rights reserved.
//

#import "KddPhotoManger.h"
#import "KddAlbumListModel.h"

@implementation KddPhotoManger

+(instancetype)sharedInstance
{
    static KddPhotoManger *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[KddPhotoManger alloc]init];
    });
    return sharedInstance;
}

-(NSArray*)getAllPhotoList{
    
    NSMutableArray * photoList = [[NSMutableArray alloc] init];
    /**
     *  获取系统相册本来就有的相册
     */
    PHFetchResult * smartAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    [smartAlbum enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
        
        PHFetchResult * result = [self fetchAssetsInAssetCollection:collection ascending:NO];
        
            if (result.count > 0) {
               
                KddAlbumListModel * group = [[KddAlbumListModel alloc]init];
                group.groupName = collection.localizedTitle;
                group.assetsCount = result.count;
                group.firstAsset = result.firstObject;
                group.assetCollection = collection;
                [photoList addObject:group];
            }
        
    }];
    /**
     *  用户在系统之后又创建的相册
     */
    PHFetchResult * userAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    [userAlbum enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
        PHFetchResult *result = [self fetchAssetsInAssetCollection:collection ascending:NO];
        if (result.count > 0) {
            
            KddAlbumListModel * group = [[KddAlbumListModel alloc]init];
         
            group.groupName = collection.localizedTitle;
            group.assetsCount = result.count;
            group.firstAsset = result.firstObject;
            group.assetCollection = collection;
            [photoList addObject:group];
            
        }
    }];
    
    return photoList;
}

#pragma mark ---   获取asset相对应的照片
-(void)getImageByAsset:(PHAsset *)asset makeSize:(CGSize)size makeResizeMode:(PHImageRequestOptionsResizeMode)resizeMode deliveryMode:(PHImageRequestOptionsDeliveryMode)deliveryMode completion:(void (^)(UIImage *))completion{

    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = resizeMode;//控制照片尺寸
    option.networkAccessAllowed = YES;
  
    if(deliveryMode==1){
        
        option.synchronous = YES;
        option.deliveryMode = deliveryMode;
    }

    [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        completion(image);
    }];
    
}


#pragma mark ---  获得指定相册的所有照片
-(NSArray*)getAssetsInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending{
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    PHFetchResult *result = [self fetchAssetsInAssetCollection:assetCollection ascending:ascending];
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

            [arr addObject:obj];
    }];
    return arr;
}

- (PHFetchResult *)fetchAssetsInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending
{
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:option];
    
    return result;
}

@end
