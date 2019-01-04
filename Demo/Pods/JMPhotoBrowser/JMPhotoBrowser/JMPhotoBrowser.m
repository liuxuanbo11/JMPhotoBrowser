//
//  JMPhotoBrowser.m
//  ControlTest
//
//  Created by print on 2018/10/18.
//  Copyright © 2018年 liuxuanbo. All rights reserved.
//

#import "JMPhotoBrowser.h"
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import "PBAlbumsViewController.h"
#import "PBPhotosViewController.h"
#import "PBAlbum.h"
#import "PBPhoto.h"
#import "JMPhotoRequest.h"
#import "MBProgressHUD.h"


#define ItemWidth ([UIScreen mainScreen].bounds.size.width - 25) / 4

@interface JMPhotoBrowser ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, weak) UIViewController *presentController;

@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@end

@implementation JMPhotoBrowser

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (JMPhotoBrowser *)browserWithDelegate:(id)delegate presentController:(UIViewController *)presentController {
    JMPhotoBrowser *photoBrowser = [[JMPhotoBrowser alloc] initWithDelegate:delegate presentController:presentController];
    return photoBrowser;
}

- (instancetype)initWithDelegate:(id)delegate presentController:(UIViewController *)presentController
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.presentController = presentController;
        self.singleSelect = YES;
        self.maxSelectedCount = 9;
        self.footerViewBackgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectedImagesNotification:) name:SelectNotificationName object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(canceledNotification:) name:CancelNotificationName object:nil];
    }
    return self;
}

- (void)fetchPhotoSource {
    // 获取照片资源
    UINavigationController *navigationController = (UINavigationController *)self.presentController.presentedViewController;
    PBPhotosViewController *photosVC = [navigationController.viewControllers lastObject];
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showHUDAddedTo:photosVC.view animated:YES];
    });
    JMPhotoRequest *photoRequest = [[JMPhotoRequest alloc] init];
    [photoRequest fetchPhotoSourceWithAssetSize:CGSizeMake(ItemWidth * 2, ItemWidth * 2) completion:^(NSArray<PBAlbum *> * _Nonnull datasources) {
        [MBProgressHUD hideHUDForView:photosVC.view animated:YES];
        PBAlbumsViewController *albumsVC = [navigationController.viewControllers firstObject];
        albumsVC.datasource = datasources;
        for (PBAlbum *album in datasources) {
            if (album.collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                [photosVC.photoArray addObjectsFromArray:album.photos];
                [photosVC reloadPhotos];
            }
        }
    }];
}

- (void)showActionSheet {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self showPhotoSelectView];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self.presentController presentViewController:self.imagePickerController animated:YES completion:nil];

        NSString *mediaType = AVMediaTypeVideo;//读取媒体类型
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];//读取设备授权状态
        if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"请在iPhone的\"设置-隐私\"选项中, 允许APP访问你的摄像头" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
            [self.imagePickerController presentViewController:alertController animated:YES completion:nil];
        }
    }]];

    [self.presentController presentViewController:alertController animated:YES completion:nil];
}

- (void)showPhotoSelectView {
    if (self.singleSelect) {
        // 单选
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self.presentController presentViewController:self.imagePickerController animated:YES completion:nil];
    } else {
        // 多选
        UINavigationController *navigationController = [[UINavigationController alloc] init];
        PBAlbumsViewController *albumsVC = [[PBAlbumsViewController alloc] init];
        albumsVC.photoBrowser = self;
        PBPhotosViewController *photosVC = [[PBPhotosViewController alloc] init];
        photosVC.photoBrowser = self;
        navigationController.viewControllers = @[albumsVC, photosVC];
        [self.presentController presentViewController:navigationController animated:YES completion:nil];

        if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    // 访问同意
                    [self fetchPhotoSource];
                } else {
                    [self.presentController dismissViewControllerAnimated:YES completion:nil];
                }
            }];
        } else if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied) {
            // 访问拒绝
            photosVC.navigationItem.hidesBackButton = YES;
            UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
            maskView.backgroundColor = [UIColor whiteColor];
            [photosVC.view addSubview:maskView];
            UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 80)];
            tipsLabel.text = @"请在iPhone的\"设置-隐私-照片\"选项中,\n允许APP访问你的手机相册";
            tipsLabel.numberOfLines = 0;
            tipsLabel.textAlignment = NSTextAlignmentCenter;
            tipsLabel.textColor = [UIColor blackColor];
            tipsLabel.font = [UIFont systemFontOfSize:16];
            [maskView addSubview:tipsLabel];

        } else if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
            // 访问同意
            [self fetchPhotoSource];
        }
    }
}

- (void)didSelectedImagesNotification:(NSNotification *)notification {
    [self.presentController dismissViewControllerAnimated:YES completion:nil];
    NSArray *selectedImages = notification.userInfo[@"ImageResult"];
    if ([self.delegate respondsToSelector:@selector(photoBrowser:didSelectedImages:)]) {
        [self.delegate photoBrowser:self didSelectedImages:selectedImages];
    }
}

- (void)canceledNotification:(NSNotification *)notification {
    [self.presentController dismissViewControllerAnimated:YES completion:nil];
    if ([self.delegate respondsToSelector:@selector(photoBrowserDidDismissed)]) {
        [self.delegate photoBrowserDidDismissed];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    if ([self.delegate respondsToSelector:@selector(photoBrowser:didFinishPickingMediaWithInfo:)]) {
        [self.delegate photoBrowser:self didFinishPickingMediaWithInfo:info];
    }
    [self.presentController dismissViewControllerAnimated:YES completion:nil];
}

- (UIImagePickerController *)imagePickerController {
    if (!_imagePickerController) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
    }
    return _imagePickerController;
}


@end
