//
//  KddPhotoAlbumListVC.m
//  KddUserClient
//
//  Created by 李世飞 on 2020/7/8.
//  Copyright © 2020 大有. All rights reserved.
//

#import "KddPhotoAlbumListVC.h"
#import <Photos/Photos.h>
#import "KddPhotoAlbumListCell.h"

@interface KddPhotoAlbumListVC ()<UICollectionViewDataSource,UICollectionViewDelegate>
{
    UICollectionView * photoCollectView;
    
    NSMutableArray * photoClickStates;
    NSMutableArray * smallPhotos;

    CGSize thumbnailSize;
    CGRect previousPreheatRect;
}

@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) PHImageRequestOptions *requestOption;

@end

@implementation KddPhotoAlbumListVC

-(void)actNavRightBtn{
    
    self.actCompleteBlock();
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    navTitleLabel.text=@"选择图片";

    [self initData];
    [self initView];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    CGFloat scale = UIScreen.mainScreen.scale;
    CGFloat item_WH = (SCREEN_WIDTH-20)/3;
    thumbnailSize = CGSizeMake(item_WH * scale, item_WH * scale);
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    [self updateCachedAssets];
}

-(void)initData{
    
    photoClickStates =[NSMutableArray array];
    smallPhotos=[NSMutableArray array];
    
    for(NSInteger i=0;i<_fetchResult.count;i++){
        
        [photoClickStates addObject:@"0"];
    }
    
    _imageManager = [[PHCachingImageManager alloc] init];
     
    _requestOption = [[PHImageRequestOptions alloc] init];
    _requestOption.resizeMode = PHImageRequestOptionsResizeModeFast;

    [self resetCachedAssets];
     
}

-(void)resetCachedAssets
{
    [_imageManager stopCachingImagesForAllAssets];
    previousPreheatRect = CGRectZero;
}

-(void)initView{
    
    [self addRightButtonToNavView:@"取消" color:[CommonUtil getColor:@"ff9900"] rect:CGRectMake(SCREEN_WIDTH-60, StatusHeight, 60, navView.height-StatusHeight) font:[UIFont systemFontOfSize:15]];
    
    
    photoCollectView=[ControlUtil addCollectionViewToSubView:self.view rect:CGRectMake(0, NavigationHeight, SCREEN_WIDTH, ViewHeight-TabbarHeight-50) tag:1 backGroundColor:[UIColor whiteColor] delegate:self dataSource:self];
    [photoCollectView registerClass:[KddPhotoAlbumListCell class] forCellWithReuseIdentifier:@"KddPhotoAlbumListCell"];

    _addPhotoView=[[KddAddPhotoView alloc] initWithFrame:CGRectMake(0,photoCollectView.maxY,SCREEN_WIDTH, 50)];
    [self.view addSubview:_addPhotoView];
    
    WEAKBLOCK(self);
    
    _addPhotoView.resutlPhoto = ^(NSArray * photos) {
        
        STRONGBLOCK(self);
        
        self.actCompleteBlockWithArray(photos);
        
        [self.navigationController popViewControllerAnimated:NO];
    };

}

-(void)updateCachedAssets
{
    if (!self.isViewLoaded || self.view.window == nil) {
        return;
    }
    
    // 预热区域 preheatRect 是 可见区域 visibleRect 的两倍高
    CGRect visibleRect = CGRectMake(0,photoCollectView.contentOffset.y, photoCollectView.bounds.size.width, photoCollectView.bounds.size.height);
    CGRect preheatRect = CGRectInset(visibleRect, 0, -0.5*visibleRect.size.height);
    
    // 只有当可见区域与最后一个预热区域显著不同时才更新
    CGFloat delta = fabs(CGRectGetMidY(preheatRect) - CGRectGetMidY(previousPreheatRect));
    if (delta > self.view.bounds.size.height / 3.f) {
        // 计算开始缓存和停止缓存的区域
        [self computeDifferenceBetweenRect:previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
            [self imageManagerStopCachingImagesWithRect:removedRect];
        } addedHandler:^(CGRect addedRect) {
            [self imageManagerStartCachingImagesWithRect:addedRect];
        }];
        previousPreheatRect = preheatRect;
    }
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler
{
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        //添加 向下滑动时 newRect 除去与 oldRect 相交部分的区域（即：屏幕外底部的预热区域）
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        //添加 向上滑动时 newRect 除去与 oldRect 相交部分的区域（即：屏幕外底部的预热区域）
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        //移除 向上滑动时 oldRect 除去与 newRect 相交部分的区域（即：屏幕外底部的预热区域）
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        //移除 向下滑动时 oldRect 除去与 newRect 相交部分的区域（即：屏幕外顶部的预热区域）
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    }
    else {
        //当 oldRect 与 newRect 没有相交区域时
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

-(void)imageManagerStartCachingImagesWithRect:(CGRect)rect
{
    NSMutableArray<PHAsset *> *addAssets = [self indexPathsForElementsWithRect:rect];
    [_imageManager startCachingImagesForAssets:addAssets targetSize:thumbnailSize contentMode:PHImageContentModeAspectFill options:_requestOption];
}

-(void)imageManagerStopCachingImagesWithRect:(CGRect)rect
{
    NSMutableArray<PHAsset *> *removeAssets = [self indexPathsForElementsWithRect:rect];
    [_imageManager stopCachingImagesForAssets:removeAssets targetSize:thumbnailSize contentMode:PHImageContentModeAspectFill options:_requestOption];
}

- (NSMutableArray<PHAsset *> *)indexPathsForElementsWithRect:(CGRect)rect
{
    UICollectionViewLayout *layout = photoCollectView.collectionViewLayout;
    NSArray<__kindof UICollectionViewLayoutAttributes *> *layoutAttributes = [layout layoutAttributesForElementsInRect:rect];
    NSMutableArray<PHAsset *> *assets = [NSMutableArray array];
    for (__kindof UICollectionViewLayoutAttributes *layoutAttr in layoutAttributes) {
        NSIndexPath *indexPath = layoutAttr.indexPath;
        PHAsset *asset = [_fetchResult objectAtIndex:indexPath.item];
        [assets addObject:asset];
    }
    return assets;
}

#pragma mark - UIScrollViewDelegate -
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView==photoCollectView){
        
        [self updateCachedAssets];
    }
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _fetchResult.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KddPhotoAlbumListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"KddPhotoAlbumListCell" forIndexPath:indexPath];

    PHAsset *asset = [_fetchResult objectAtIndex:indexPath.item];
    
    BOOL isClickPhoto =[photoClickStates[indexPath.row] boolValue];
    
    cell.representedAssetIdentifier = asset.localIdentifier;
    
    [_imageManager requestImageForAsset:asset targetSize:thumbnailSize contentMode:PHImageContentModeAspectFill options:_requestOption resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        // 当 resultHandler 被调用时，cell可能已被回收，所以此处加个判断条件
        
        if ([cell.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
            
            cell.thumbnailImage = result;
            
            cell.chooseImage=[UIImage imageNamed:isClickPhoto?@"image_yes":@"image_no"];
        }
   
    }];
    
    return cell;
}

#pragma mark <UICollectionViewDelegateFlowLayout>
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
        
    CGFloat item_WH = (SCREEN_WIDTH-20)/3.f;
    return CGSizeMake(item_WH, item_WH);
    
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    
    BOOL isClickPhoto =[photoClickStates[indexPath.row] boolValue];
        
    if(isClickPhoto){
            
        [photoClickStates replaceObjectAtIndex:indexPath.row withObject:@"0"];
            
        [smallPhotos removeObject:_fetchResult[indexPath.row]];

       
    }else{
            
        
        if(_maxPhotoNum==smallPhotos.count){
            
            [DYRoute.topViewController showHint:[NSString stringWithFormat:@"最多选择%zi张图片",_maxPhotoNum]];
            return;
        }
        
        [photoClickStates replaceObjectAtIndex:indexPath.row withObject:@"1"];
            
        [smallPhotos addObject:_fetchResult[indexPath.row]];
       
    }
   
    [photoCollectView reloadItemsAtIndexPaths:@[indexPath]];
    
    _addPhotoView.photos=smallPhotos;
        
}

@end
