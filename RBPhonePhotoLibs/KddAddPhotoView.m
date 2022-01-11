//
//  KddAddPhotoView.m
//  KddUserClient
//
//  Created by 李世飞 on 2020/7/8.
//  Copyright © 2020 大有. All rights reserved.
//

#import "KddAddPhotoView.h"
#import "KddPhotoAlbumListCell.h"
#import "UIView+WZLBadge.h"
#import "KddPhotoManger.h"

@implementation KddAddPhotoView

-(instancetype)initWithFrame:(CGRect)frame{
    
    if(self=[super initWithFrame:frame]){
        
        _imageManager = [[PHCachingImageManager alloc] init];
        
        _requestOption = [[PHImageRequestOptions alloc] init];
        _requestOption.resizeMode = PHImageRequestOptionsResizeModeFast;
        _requestOption.networkAccessAllowed = YES;
        _requestOption.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        _requestOption.synchronous = NO;

        [self initView];
    }
    
    return self;
}

-(void)initView{
    
    UIView * bottomView =[ControlUtil addViewToView:self rect:CGRectMake(0, 0, SCREEN_WIDTH, 50) backgroundColor:[UIColor whiteColor] tag:2];
    
    smallPhotoCollectView=[ControlUtil addCollectionViewToSubView:bottomView rect:CGRectMake(0, 0, bottomView.width-60, bottomView.height) tag:2 backGroundColor:[UIColor whiteColor] delegate:self dataSource:self];
    
    [smallPhotoCollectView registerClass:[KddPhotoAlbumListCell class] forCellWithReuseIdentifier:@"KddPhotoAlbumListCell"];
    
    
    sureBtn=[ControlUtil addButtonToView:bottomView rect:CGRectMake(smallPhotoCollectView.maxX, 0, bottomView.width-smallPhotoCollectView.maxX, bottomView.height) tag:1 normalPhoto:nil hightlightedPhoto:nil title:@"完成" font:[UIFont systemFontOfSize:15] textColor:[CommonUtil getColor:@"ff9900"] backGroundColor:nil target:self selectAction:@selector(sure:) cornerRadius:0 borderWidth:0 borderColor:0];
    
    paoImg=[[UIImageView alloc] init];
    paoImg.frame=CGRectMake(0,0,40,20);
    paoImg.badgeCenterOffset=CGPointMake(-30, 10);
    paoImg.userInteractionEnabled=NO;
    [paoImg clearBadge];
    [sureBtn addSubview:paoImg];

}

-(void)sure:(UIButton*)btn{
    
    if(_photos.count==0) return;
    
    if(self.resutlPhoto){
                   
        self.resutlPhoto(_photos);
    }
   
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KddPhotoAlbumListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"KddPhotoAlbumListCell" forIndexPath:indexPath];

    PHAsset *asset = [_photos objectAtIndex:indexPath.item];
        
    [_imageManager requestImageForAsset:asset targetSize:CGSizeMake(40, 40) contentMode:PHImageContentModeAspectFill options:_requestOption resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
        cell.thumbnailImage = result;
    
    }];
    
    return cell;
}

#pragma mark <UICollectionViewDelegateFlowLayout>
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{

    return CGSizeMake(40, 40);
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
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    [self showPhoto:indexPath.row];

}

-(void)showPhoto:(NSInteger)index{
    
    NSInteger countPage = _photos.count;
    
    currentPage = index +1;
    
    [self hiden];
    
    scr =[ControlUtil addScrollViewToView:nil contentSize:CGSizeMake(SCREEN_WIDTH*_photos.count, SCREEN_HEIGHT) rect:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) tag:1];
    scr.delegate=self;
    scr.pagingEnabled=YES;
    scr.backgroundColor=[UIColor blackColor];
    [[AppDelegate sharedAppDelegate].window addSubview:scr];

    labPhotoNum=[ControlUtil addLabelToView:nil text:[NSString stringWithFormat:@"%zi/%zi",currentPage,countPage] font:[UIFont systemFontOfSize:16] rect:CGRectMake(0, SCREEN_HEIGHT-TabbarHeight-40, SCREEN_WIDTH, 40) alignment:1 textColor:[UIColor whiteColor] lineBreakMode:4 tag:1];
    [[AppDelegate sharedAppDelegate].window addSubview:labPhotoNum];

    UITapGestureRecognizer*singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiden)];
    singleRecognizer.numberOfTapsRequired = 1; // 单击
    [scr addGestureRecognizer:singleRecognizer];
       
    NSInteger i=0;
    
    for(PHAsset * asset in _photos){
           
        UIImageView * imageView =[ControlUtil addImageViewToView:scr rect:CGRectMake(SCREEN_WIDTH*i,(SCREEN_HEIGHT-SCREEN_WIDTH/2)/2,SCREEN_WIDTH, SCREEN_WIDTH/2) tag:i imageName:@"default_bg828x414" placeholderImage:nil cornerRadius:0];
   
        [_imageManager requestImageForAsset:asset targetSize:CGSizeMake(asset.pixelWidth,asset.pixelHeight) contentMode:PHImageContentModeAspectFill options:_requestOption resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
            if(result){
                             
                imageView.image=result;
                
                CGFloat rate = result.size.height/result.size.width;
                
                CGFloat h =SCREEN_WIDTH* rate;
                
                if(h>SCREEN_HEIGHT){
                    
                    h=SCREEN_HEIGHT;
                }
                
                imageView.height=h;
                imageView.y=(SCREEN_HEIGHT-h)/2;
                       
            }
        }];
     
        i++;
       
    }
    
    [scr scrollRectToVisible:CGRectMake(index*SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT) animated:NO];

}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    if(scrollView==scr){
        
        CGFloat scrollWidth = scrollView.contentOffset.x;
        
        currentPage=scrollWidth/SCREEN_WIDTH+1;
        
        labPhotoNum.text=[NSString stringWithFormat:@"%zi/%zi",currentPage,_photos.count];
    }
}

-(void)hiden{
    
    [scr removeFromSuperview];
    [labPhotoNum removeFromSuperview];
}


-(void)setPhotos:(NSArray *)photos{
    
    _photos=photos;
    [smallPhotoCollectView reloadData];
    
    if(_photos.count>0){
        
        [paoImg showBadgeWithStyle:WBadgeStyleNumber value:_photos.count animationType:WBadgeAnimTypeNone];

    }else{
        
        [paoImg clearBadge];
    }
}


@end
