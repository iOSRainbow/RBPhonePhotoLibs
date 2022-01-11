//
//  KddAlbumListVC.m
//  KddUserClient
//
//  Created by 李世飞 on 2020/7/8.
//  Copyright © 2020 大有. All rights reserved.
//

#import "KddAlbumListVC.h"
#import "KddPhotoManger.h"
#import "KddAlbumListModel.h"
#import "KddPhotoAlbumListVC.h"

@interface KddAlbumListVC ()<UITableViewDelegate,UITableViewDataSource>{
    
    UITableView * tableview;
    NSArray * albumList;
    
}

@end

@implementation KddAlbumListVC

-(void)actNavRightBtn{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    navTitleLabel.text=@"选择相册";
    
    [self addRightButtonToNavView:@"关闭" color:[CommonUtil getColor:@"ff9900"] rect:CGRectMake(SCREEN_WIDTH-60, StatusHeight, 60, navView.height-StatusHeight) font:[UIFont systemFontOfSize:15]];
    
    [self getAlbumListData];

    [self createAlbumListView];
    
    [self checkAuthorizationStatus];
}

//获取系统相册列表
-(void)getAlbumListData{
    
    albumList=[KddPhotoManger sharedInstance].getAllPhotoList;

}

-(void)createAlbumListView{

    tableview=[ControlUtil addTableViewToView:self.view rect:CGRectMake(0, NavigationHeight, SCREEN_WIDTH, ViewHeight) tag:1 delegate:self dataSource:self];
    tableview.rowHeight=80;
    
}


//检查相册权限
-(void)checkAuthorizationStatus{
    
    WEAKBLOCK(self);
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];

    if (status == PHAuthorizationStatusNotDetermined) {
           
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
               
            STRONGBLOCK(self);
            
            if(status ==PHAuthorizationStatusAuthorized) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                                    
                    [self reloadData];
                });
                
               } else {
                       
                   // 用户点击 不允许访问
                   [self.navigationController popViewControllerAnimated:YES];
               }
           }];
       }
}

//首次权限，点击允许后需重新获取数据
-(void)reloadData{
    
    [self getAlbumListData];
    [tableview reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return albumList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellWithIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
    
    if (cell == nil) {
       
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellWithIdentifier];
        
        [ControlUtil addImageViewToView:cell rect:CGRectMake(10,10,60,60) tag:1 imageName:nil placeholderImage:nil cornerRadius:0];
        
        [ControlUtil addLabelToView:cell text:nil font:[UIFont systemFontOfSize:16.0] rect:CGRectMake(90, 10, SCREEN_WIDTH-100, 30) alignment:NSTextAlignmentLeft textColor:[UIColor blackColor] lineBreakMode:NSLineBreakByCharWrapping tag:2];
        
        [ControlUtil addLabelToView:cell text:nil font:[UIFont systemFontOfSize:14.0] rect:CGRectMake(90, 40, SCREEN_WIDTH-100, 20) alignment:NSTextAlignmentLeft textColor:[UIColor grayColor] lineBreakMode:NSLineBreakByCharWrapping tag:3];
        
       
        [ControlUtil addViewToView:cell rect:CGRectMake(10, 79, SCREEN_WIDTH-10, 1) backgroundColor:MS_RGB(228, 228, 228) tag:4];
        
    }
    
    UIImageView * img =(UIImageView *)[cell viewWithTag:1];
    UILabel * groupName=(UILabel*)[cell viewWithTag:2];
    UILabel * photoNum=(UILabel*)[cell viewWithTag:3];
    UIView * line=(UILabel*)[cell viewWithTag:4];
    
    KddAlbumListModel * group =albumList[indexPath.row];
    
    groupName.text = group.groupName;
    
    photoNum.text = [NSString stringWithFormat:@"(%zi)",group.assetsCount];
    
    CGFloat scale = UIScreen.mainScreen.scale;

    [[KddPhotoManger sharedInstance] getImageByAsset:group.firstAsset makeSize:CGSizeMake(70*scale, 70*scale) makeResizeMode:1 deliveryMode:0 completion:^(UIImage * _Nonnull image) {
        
        if(image){
            
            img.image=image;
        }
    }];
 
    
    line.hidden=(albumList.count-1==indexPath.row)?YES:NO;
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    KddAlbumListModel * group =albumList[indexPath.row];
    
    //当前相册下所有photo
    NSArray * photos =[[KddPhotoManger sharedInstance] getAssetsInAssetCollection:group.assetCollection ascending:NO];
    
    KddPhotoAlbumListVC * photoVC =[[KddPhotoAlbumListVC alloc] init];
    photoVC.maxPhotoNum=_maxCount;
    photoVC.fetchResult=photos;
    [self.navigationController pushViewController:photoVC animated:YES];
    
    WEAKBLOCK(self);
    
    photoVC.actCompleteBlock=^{
        STRONGBLOCK(self);
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    photoVC.actCompleteBlockWithArray =^(NSArray *ary){
        STRONGBLOCK(self);
        [self dismissViewControllerAnimated:YES completion:^{
            self.completePhotosArray(ary);
        }];
    };
    
}

@end
