//
//  PBPhotosViewController.m
//  ControlTest
//
//  Created by print on 2018/10/17.
//  Copyright © 2018年 liuxuanbo. All rights reserved.
//

#import "PBPhotosViewController.h"
#import <Photos/Photos.h>
#import "JMPhotoBrowser.h"
#import "PBDataHandler.h"
#import "PBPhoto.h"
#import "PBPhotesDetailViewController.h"
#import "PBSmallPhotoCollectionViewCell.h"
#import "PBFooterView.h"

#define ItemWidth ([UIScreen mainScreen].bounds.size.width - 25) / 4
@interface PBPhotosViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, PBFooterViewDelegate>
{
    BOOL _didScrollToBottom;
}
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *selectedImages;

@property (nonatomic, strong) PBFooterView *footerView;


@end

@implementation PBPhotosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self addRightButtonWithTitle:@"取消"];

    self.footerView = [[PBFooterView alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 44, [[UIScreen mainScreen] bounds].size.width, 44) type:0];
    _footerView.delegate = self;
    [_footerView setLeftButtonText:@"预览"];
    _footerView.backgroundColor = self.photoBrowser.footerViewBackgroundColor;
    _footerView.themeColor = self.photoBrowser.themeColor;
    _footerView.disableColor = self.photoBrowser.disableColor;
    [self setBottomViewStatus];
    [self.view addSubview:self.footerView];

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.minimumLineSpacing = 5;
    flowLayout.minimumInteritemSpacing = 5;
    flowLayout.itemSize = CGSizeMake(ItemWidth, ItemWidth);
    flowLayout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 44) collectionViewLayout:flowLayout];
    [_collectionView registerClass:[PBSmallPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"itemCell"];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_collectionView];
    
}

- (UIButton *)addRightButtonWithTitle:(NSString *)buttonTitle {
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 44, 44);
    [rightButton setTitle:buttonTitle forState:UIControlStateNormal];
    [rightButton setTitleColor:self.photoBrowser.themeColor ? self.photoBrowser.themeColor : [UIColor blackColor] forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [rightButton setTitleEdgeInsets:UIEdgeInsetsMake(0, CGRectGetWidth(rightButton.frame) - rightButton.titleLabel.intrinsicContentSize.width, 0, 0)];
    UIView *backView = [[UIView alloc] initWithFrame:rightButton.frame];
    [backView addSubview:rightButton];
    [rightButton addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backView];
    return rightButton;
}

- (void)reloadPhotos {
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photoArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PBSmallPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"itemCell" forIndexPath:indexPath];
    PBPhoto *photo = self.photoArray[indexPath.item];
    cell.imgView.image = photo.smallImage;
    
    if ([PBDataHandler photoArray:self.selectedImages ContainsAsset:photo.phAsset]) {
        cell.numberLabel.text = [NSString stringWithFormat:@"%lu", [self.selectedImages indexOfObject:self.photoArray[indexPath.item]] + 1];
        cell.numberLabel.hidden = NO;
    } else {
        cell.numberLabel.text = nil;
        cell.numberLabel.hidden = YES;
        if ([self selectedImagesEnough]) {
            [cell showMaskView];
        }
    }
    if (![self selectedImagesEnough]) {
        [cell removeMaskView];
    }
    __weak typeof(self) weakSelf = self;
    cell.didSelectImageBlock = ^{
        if ([PBDataHandler photoArray:weakSelf.selectedImages ContainsAsset:photo.phAsset]) {
            [weakSelf.selectedImages removeObject:photo];
        } else {
            if ([weakSelf selectedImagesEnough]) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"您最多只能选择%ld张照片", weakSelf.photoBrowser.maxSelectedCount] preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:nil]];
                [weakSelf presentViewController:alertController animated:YES completion:nil];
                return;
            }
            [weakSelf.selectedImages addObject:photo];
        }
        [collectionView reloadData];
        [weakSelf setBottomViewStatus];
    };
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self selectedImagesEnough]) {
        PBPhoto *photo = self.photoArray[indexPath.item];
        if (![PBDataHandler photoArray:self.selectedImages ContainsAsset:photo.phAsset]) {
            return;
        }
    }
    PBPhotesDetailViewController *photoDetailVC = [[PBPhotesDetailViewController alloc] init];
    photoDetailVC.selectedImages = self.selectedImages;
    [photoDetailVC.imageArray addObjectsFromArray:self.photoArray];
    photoDetailVC.photoBrowser = self.photoBrowser;
    photoDetailVC.index = indexPath.item;
    photoDetailVC.didChangeSelectedPhotoBlock = ^{
        [self.collectionView reloadData];
        [self setBottomViewStatus];
    };
    [self.navigationController pushViewController:photoDetailVC animated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == ((NSIndexPath *)[[collectionView indexPathsForVisibleItems] lastObject]).item && !_didScrollToBottom) {
        if (self.collectionView.contentSize.height > self.collectionView.frame.size.height - CGRectGetMaxY(self.navigationController.navigationBar.frame)) {
            _didScrollToBottom = YES;
            [self.collectionView setContentOffset:CGPointMake(self.collectionView.contentOffset.x, self.collectionView.contentSize.height - self.collectionView.frame.size.height)];
        }
    }
}

- (BOOL)selectedImagesEnough {
    return self.selectedImages.count >= self.photoBrowser.maxSelectedCount;
}

- (void)pbFooterViewDidSelectButton:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        // 预览
        PBPhotesDetailViewController *photoDetailVC = [[PBPhotesDetailViewController alloc] init];
        photoDetailVC.selectedImages = self.selectedImages;
        [photoDetailVC.imageArray addObjectsFromArray:self.selectedImages];
        photoDetailVC.photoBrowser = self.photoBrowser;
        photoDetailVC.index = 0;
        photoDetailVC.isPreview = YES;
        photoDetailVC.didChangeSelectedPhotoBlock = ^{
            [self.collectionView reloadData];
            [self setBottomViewStatus];
        };
        [self.navigationController pushViewController:photoDetailVC animated:YES];
    } else {
        // 发送
        if (self.selectedImages.count) {
            NSMutableArray *resultSet = [NSMutableArray array];
            PHImageManager *imageManager = [PHImageManager defaultManager];
            PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
            requestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
            requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            for (int i = 0; i < self.selectedImages.count; i++) {
                PBPhoto *photo = self.selectedImages[i];
                [imageManager requestImageForAsset:photo.phAsset targetSize:CGSizeMake([UIScreen mainScreen].bounds.size.width * 2, [UIScreen mainScreen].bounds.size.height * 2) contentMode:PHImageContentModeAspectFit options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    if (result) {
                        [resultSet addObject:result];
                        if (resultSet.count == self.selectedImages.count) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:SelectNotificationName object:nil userInfo:@{@"ImageResult": resultSet}];
                        }
                    }
                }];
            }
        }
    }
}

- (void)setBottomViewStatus {
    self.footerView.leftButton.enabled = self.selectedImages.count == 0 ? NO : YES;
    self.footerView.rightButton.enabled = self.selectedImages.count == 0 ? NO : YES;
    self.footerView.rightButton.alpha = self.selectedImages.count == 0 ? 0.6 : 1;
    [self.footerView.rightButton setTitle:self.selectedImages.count == 0 ? @"发送" : [NSString stringWithFormat:@"发送(%ld)", self.selectedImages.count] forState:UIControlStateNormal];
}

- (void)rightButtonAction:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:CancelNotificationName object:nil];
}

- (NSMutableArray<PBPhoto *> *)photoArray {
    if (!_photoArray) {
        _photoArray = [NSMutableArray array];
    }
    return _photoArray;
}

- (NSMutableArray *)selectedImages {
    if (!_selectedImages) {
        _selectedImages = [NSMutableArray array];
    }
    return _selectedImages;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
