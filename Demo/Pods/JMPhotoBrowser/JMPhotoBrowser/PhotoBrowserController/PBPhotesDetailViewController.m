//
//  PBPhotesDetailViewController.m
//  ControlTest
//
//  Created by print on 2018/10/17.
//  Copyright © 2018年 liuxuanbo. All rights reserved.
//

#import "PBPhotesDetailViewController.h"
#import <Photos/Photos.h>
#import <objc/runtime.h>
#import "JMPhotoBrowser.h"
#import "PBDataHandler.h"
#import "PBPhoto.h"
#import "PBPhotoDetailCollectionViewCell.h"
#import "PBFooterView.h"

#define DisplayButtonSize 56
@interface PBPhotesDetailViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, PBFooterViewDelegate, PBPhotoDetailCollectionViewCellDelegate>
{
    BOOL _didScrollToTargetPosition;
}
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) PHImageManager *imageManager;

@property (nonatomic, strong) PHImageRequestOptions *requestOptions;

@property (nonatomic, strong) UIButton *rightButton;

@property (nonatomic, strong) UILabel *numberLabel;

@property (nonatomic, strong) PBFooterView *footerView;

@property (nonatomic, strong) UIScrollView *displayScrollView;

@property (nonatomic, assign) BOOL isHidden;

@property (nonatomic, strong) UIButton *currentDisplayButton;

@end

@implementation PBPhotesDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.view.backgroundColor = [UIColor blackColor];
    self.rightButton = [self addRightButtonWithImage:[UIImage imageNamed:@"check"] imageHeight:30];
    self.rightButton.imageView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.1];
    self.rightButton.imageView.layer.cornerRadius = 15;
    self.rightButton.imageView.layer.masksToBounds = YES;

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumLineSpacing = 20;
    flowLayout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 20);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width + 20, [[UIScreen mainScreen] bounds].size.height) collectionViewLayout:flowLayout];
    [_collectionView registerClass:[PBPhotoDetailCollectionViewCell class] forCellWithReuseIdentifier:@"itemCell"];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor blackColor];
    _collectionView.pagingEnabled = YES;
    if (@available(iOS 11.0, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.view addSubview:_collectionView];
    
    self.footerView = [[PBFooterView alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 44, [[UIScreen mainScreen] bounds].size.width, 44) type:1];
    _footerView.delegate = self;
    [_footerView setLeftButtonText:@"原图"];
    [_footerView.rightButton setTitle:self.selectedImages.count == 0 ? @"发送" : [NSString stringWithFormat:@"发送(%ld)", self.selectedImages.count] forState:UIControlStateNormal];
    _footerView.backgroundColor = self.photoBrowser.footerViewBackgroundColor;
    _footerView.themeColor = self.photoBrowser.themeColor;
    _footerView.disableColor = self.photoBrowser.disableColor;
    if (self.photoBrowser.footerCheckImage) {
        [_footerView.leftButton setImage:self.photoBrowser.footerCheckImage forState:UIControlStateSelected];
    }
    if (self.photoBrowser.footerNotCheckImage) {
        [_footerView.leftButton setImage:self.photoBrowser.footerNotCheckImage forState:UIControlStateNormal];
        [_footerView.leftButton setImage:self.photoBrowser.footerNotCheckImage forState:UIControlStateHighlighted];
    }
    [self.view addSubview:self.footerView];
    
    if (self.selectedImages.count) {
        // 被选中图片展示
        for (int i = 0; i < self.selectedImages.count; i++) {
            PBPhoto *photo = self.selectedImages[i];
            [self createDisplayButtonWithFrame:CGRectMake(12 + i * (DisplayButtonSize + 12), 12, DisplayButtonSize, DisplayButtonSize) photo:photo tag:i + 1];
        }
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (UIButton *)addRightButtonWithImage:(UIImage *)buttonImage imageHeight:(CGFloat)imageHeight {
    imageHeight = fmin(imageHeight, 44);
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 44, 44);
    if (buttonImage && buttonImage.size.height > 0) {
        [rightButton setImage:buttonImage forState:UIControlStateNormal];
        CGFloat width = buttonImage.size.width / buttonImage.size.height * imageHeight;
        [rightButton setImageEdgeInsets:UIEdgeInsetsMake((CGRectGetHeight(rightButton.frame) - imageHeight) / 2, CGRectGetWidth(rightButton.frame) - width, (CGRectGetHeight(rightButton.frame) - imageHeight) / 2, 0)];
        rightButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        rightButton.adjustsImageWhenHighlighted = NO;
    }
    UIView *backView = [[UIView alloc] initWithFrame:rightButton.frame];
    [backView addSubview:rightButton];
    [rightButton addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backView];
    return rightButton;
}

// 创建被选中图片按钮
- (UIButton *)createDisplayButtonWithFrame:(CGRect)frame photo:(PBPhoto *)photo tag:(NSInteger)tag {
    UIButton *displayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    displayButton.frame = frame;
    [displayButton setImage:photo.smallImage forState:UIControlStateNormal];
    displayButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    displayButton.adjustsImageWhenHighlighted = NO;
    displayButton.tag = tag;
    [displayButton addTarget:self action:@selector(displayButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    objc_setAssociatedObject(displayButton, &"photo", photo, OBJC_ASSOCIATION_RETAIN_NONATOMIC); // 视图和数据源绑定
    [self.displayScrollView addSubview:displayButton];
    self.displayScrollView.contentSize = CGSizeMake(CGRectGetMaxX(displayButton.frame) + 12 > _displayScrollView.frame.size.width + 0.3 ? CGRectGetMaxX(displayButton.frame) + 12 : _displayScrollView.frame.size.width + 0.3, 0);
    return displayButton;
}

- (void)displayButtonAction:(UIButton *)sender {
    NSInteger index = self.index;
    if (self.isPreview) {
        index = sender.tag - 1;
    } else {
        PBPhoto *photo = (PBPhoto *)objc_getAssociatedObject(sender, &"photo");
        index = [self.imageArray indexOfObject:photo];
    }
    // 点击按钮滚动到对应的位置
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
}

- (void)rightButtonAction:(UIButton *)sender {
    PBPhoto *photo = self.imageArray[self.index];
    BOOL isContains = [PBDataHandler photoArray:self.selectedImages ContainsAsset:photo.phAsset];
    if (isContains) {
        self.numberLabel.hidden = YES;
        self.numberLabel.text = nil;
        if (!self.isPreview) {
            UIButton *displayButton = [self.displayScrollView viewWithTag:[self.selectedImages indexOfObject:photo] + 1];
            [UIView animateWithDuration:0.2 animations:^{
                displayButton.alpha = 0;
            } completion:^(BOOL finished) {
                [displayButton removeFromSuperview];
            }];
            for (NSInteger i = displayButton.tag; i < self.selectedImages.count; i++) {
                UIButton *displayButton = [self.displayScrollView viewWithTag:i + 1];
                displayButton.tag -= 1;
                [UIView animateWithDuration:0.2 animations:^{
                    displayButton.frame = CGRectMake(displayButton.frame.origin.x - 68, displayButton.frame.origin.y, displayButton.frame.size.width, displayButton.frame.size.height);
                }];
            }
            [UIView animateWithDuration:0.2 animations:^{
                self.displayScrollView.contentSize = CGSizeMake(self.displayScrollView.contentSize.width - 68 >= self.displayScrollView.frame.size.width + 0.3 ? self.displayScrollView.contentSize.width - 68 : self.displayScrollView.frame.size.width + 0.3, self.displayScrollView.contentSize.height);
            }];
        }
        [self.selectedImages removeObject:photo];
        if (!self.isPreview && !self.selectedImages.count) {
            [UIView animateWithDuration:0.2 animations:^{
                self->_displayScrollView.alpha = 0;
            } completion:^(BOOL finished) {
                [self->_displayScrollView removeFromSuperview];
                self->_displayScrollView = nil;
            }];
        }
    } else {
        if (self.selectedImages.count >= self.photoBrowser.maxSelectedCount) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"您最多只能选择%ld张照片", self.photoBrowser.maxSelectedCount] preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
            return;
        }
        [self.selectedImages addObject:photo];
        self.numberLabel.hidden = NO;
        self.numberLabel.text = [NSString stringWithFormat:@"%lu", [self.selectedImages indexOfObject:photo] + 1];
        if (!self.isPreview) {
            if (!_displayScrollView) {
                self.displayScrollView.alpha = 0;
                [UIView animateWithDuration:0.2 animations:^{
                    self.displayScrollView.alpha = 1;
                }];
            }
            UIButton *displayButton = [self createDisplayButtonWithFrame:CGRectMake(12 + (self.selectedImages.count - 1) * (DisplayButtonSize + 12), 12, DisplayButtonSize, DisplayButtonSize) photo:photo tag:self.selectedImages.count];
            if (self.currentDisplayButton) {
                [self setLayerWithButton:self.currentDisplayButton borderType:0];
            }
            [self setLayerWithButton:displayButton borderType:1];
            [self setDisplayScrollViewOffsetWithButton:displayButton animated:YES];
            self.currentDisplayButton = displayButton;
        }
    }
    if (self.isPreview) {
        UIButton *displayButton = [self.displayScrollView viewWithTag:self.index + 1];
        UIView *whiteMask = [displayButton viewWithTag:99];
        if (whiteMask) {
            [whiteMask removeFromSuperview];
        } else {
            whiteMask = [[UIView alloc] initWithFrame:displayButton.bounds];
            whiteMask.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
            whiteMask.userInteractionEnabled = NO;
            whiteMask.tag = 99;
            [displayButton addSubview:whiteMask];
        }
    }
    
    [self.footerView.rightButton setTitle:self.selectedImages.count == 0 ? @"发送" : [NSString stringWithFormat:@"发送(%ld)", self.selectedImages.count] forState:UIControlStateNormal];
    if (self.isPreview) {
        self.footerView.rightButton.enabled = self.selectedImages.count;
        self.footerView.rightButton.alpha = !self.selectedImages.count ? 0.6 : 1;
    }
    if (self.didChangeSelectedPhotoBlock) {
        self.didChangeSelectedPhotoBlock();
    }
}

- (void)pbFooterViewDidSelectButton:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        // 原图
        if (self.footerView.leftButton.selected) {
            [self showOriginalImageSizeWithPhoto:self.imageArray[self.index]];
        } else {
            [self.footerView setLeftButtonText:@"原图"];
        }
    } else {
        // 发送
        if (self.selectedImages.count) {
            NSMutableArray *resultSet = [NSMutableArray array];
            for (int i = 0; i < self.selectedImages.count; i++) {
                PBPhoto *photo = self.selectedImages[i];
                UIImage *resultImage = self.footerView.leftButton.selected ? photo.originalImage : photo.clearlyImage;
                if (resultImage) {
                    [resultSet addObject:resultImage];
                } else {
                    [self requestResultSetImageForPhoto:photo resultSet:resultSet maxCount:self.selectedImages.count completedHandler:nil];
                }
            }
            if (resultSet.count == self.selectedImages.count) {
                [[NSNotificationCenter defaultCenter] postNotificationName:SelectNotificationName object:nil userInfo:@{@"ImageResult": resultSet}];
            }
        } else if (!self.isPreview) {
            PBPhoto *photo = [self.imageArray objectAtIndex:self.index];
            UIImage *resultImage = self.footerView.leftButton.selected ? photo.originalImage : photo.clearlyImage;
            NSMutableArray *resultSet = [NSMutableArray array];
            if (resultImage) {
                [resultSet addObject:resultImage];
                [[NSNotificationCenter defaultCenter] postNotificationName:SelectNotificationName object:nil userInfo:@{@"ImageResult": resultSet}];
            } else {
                [self requestResultSetImageForPhoto:photo resultSet:resultSet maxCount:1 completedHandler:nil];
            }
        }
    }
}

// 下载图片
- (void)requestResultSetImageForPhoto:(PBPhoto *)photo resultSet:(NSMutableArray *)resultSet maxCount:(NSInteger)maxCount completedHandler:(void (^)(UIImage *result))completedHandler {
    if (self.footerView.leftButton.selected) {
        [self requestOriginalImageForPhoto:photo completedHandler:^(UIImage *result) {
            if (resultSet) {
                [resultSet addObject:result];
                if (resultSet.count == maxCount) {
                    if (completedHandler) {
                        completedHandler(result);
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:SelectNotificationName object:nil userInfo:@{@"ImageResult": resultSet}];
                }
            } else if (completedHandler) {
                completedHandler(result);
            }
        }];
    } else {
        [self requestClearnImageForPhoto:photo completedHandler:^(UIImage *result) {
            if (resultSet) {
                [resultSet addObject:result];
                if (resultSet.count == maxCount) {
                    if (completedHandler) {
                        completedHandler(result);
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:SelectNotificationName object:nil userInfo:@{@"ImageResult": resultSet}];
                }
            } else if (completedHandler) {
                completedHandler(result);
            }
        }];
    }
}

// 下载清晰图
- (void)requestClearnImageForPhoto:(PBPhoto *)photo completedHandler:(void (^)(UIImage *result))completedHandler {
    [self.imageManager requestImageForAsset:photo.phAsset targetSize:CGSizeMake([UIScreen mainScreen].bounds.size.width * 2, [UIScreen mainScreen].bounds.size.height * 2) contentMode:PHImageContentModeAspectFit options:self.requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (result) {
            photo.clearlyImage = result;
            if (completedHandler) {
                completedHandler(result);
            }
        }
    }];
}

// 下载原图
- (void)requestOriginalImageForPhoto:(PBPhoto *)photo completedHandler:(void (^)(UIImage *result))completedHandler {
    [self.imageManager requestImageDataForAsset:photo.phAsset options:self.requestOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        if (imageData) {
            UIImage *result = [UIImage imageWithData:imageData scale:1];
            photo.originalImage = result;
            NSString *unit = imageData.length >= 1024 * 1024 ? @"MB" : @"KB";
            CGFloat size = imageData.length >= 1024 * 1024 ? imageData.length / (1024 * 1024.0) : imageData.length / 1024.0;
            photo.sizeFormat = [NSString stringWithFormat:@"%.1f%@", size, unit];
            if (completedHandler) {
                completedHandler(result);
            }
        }
    }];
}

- (void)showOriginalImageSizeWithPhoto:(PBPhoto *)photo {
    if (photo.sizeFormat) {
        [self.footerView setLeftButtonText:[NSString stringWithFormat:@"原图(%@)", photo.sizeFormat]];
    } else {
        [self requestOriginalImageForPhoto:photo completedHandler:^(UIImage *result) {
            [self.footerView setLeftButtonText:[NSString stringWithFormat:@"原图(%@)", photo.sizeFormat]];
        }];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PBPhotoDetailCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"itemCell" forIndexPath:indexPath];
    cell.delegate = self;
    PBPhoto *photo = self.imageArray[indexPath.row];
    if (photo.clearlyImage) {
        cell.image = photo.clearlyImage;
    } else {
        cell.image = photo.smallImage;
        [self requestClearnImageForPhoto:photo completedHandler:^(UIImage *result) {
            cell.image = result;
        }];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == ((NSIndexPath *)[[collectionView indexPathsForVisibleItems] lastObject]).row && !_didScrollToTargetPosition) {
        if (self.index == 0) {
            [self scrollViewDidScroll:collectionView];
        } else {
            [collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.index inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        }
    }
    PBPhotoDetailCollectionViewCell *scaleDidChangeCell = (PBPhotoDetailCollectionViewCell *)cell;
    if (scaleDidChangeCell.scrollView.zoomScale != 1) {
        [scaleDidChangeCell.scrollView setZoomScale:1 animated:NO];        
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger index = (NSInteger)((self.collectionView.contentOffset.x + ([UIScreen mainScreen].bounds.size.width / 2) + 8) / ([UIScreen mainScreen].bounds.size.width + 20));
    if (index != self.index || !_didScrollToTargetPosition) {
        self.index = index;
        PBPhoto *photo = self.imageArray[self.index];
        BOOL isContains = [PBDataHandler photoArray:self.selectedImages ContainsAsset:photo.phAsset];
        if (isContains) {
            self.numberLabel.hidden = NO;
            self.numberLabel.text = [NSString stringWithFormat:@"%lu", [self.selectedImages indexOfObject:photo] + 1];
        } else {
            self.numberLabel.hidden = YES;
            self.numberLabel.text = nil;
        }
        if (self.isPreview || self.selectedImages.count) {
            if (self.currentDisplayButton) {
                [self setLayerWithButton:self.currentDisplayButton borderType:0];
            }
            UIButton *newButton = nil;
            if (self.isPreview) {
                newButton = [self.displayScrollView viewWithTag:self.index + 1];
            } else if (isContains) {
                newButton = [self.displayScrollView viewWithTag:[self.selectedImages indexOfObject:photo] + 1];
            }
            if (newButton) {
                [self setLayerWithButton:newButton borderType:1];
                self.currentDisplayButton = newButton;
                [self setDisplayScrollViewOffsetWithButton:newButton animated:_didScrollToTargetPosition];
            }
        }
        if (self.footerView.leftButton.selected) {
            [self showOriginalImageSizeWithPhoto:photo];
        }
        _didScrollToTargetPosition = YES;
    }
}

- (void)setDisplayScrollViewOffsetWithButton:(UIButton *)button animated:(BOOL)animated {
    CGFloat maxOffset = self.displayScrollView.contentSize.width - self.displayScrollView.frame.size.width - 0.3;
    if (maxOffset > 0) {
        CGFloat offset = button.frame.origin.x - (self.displayScrollView.frame.size.width / 2 - 28);
        offset = fmax(offset, 0);
        offset = fmin(offset, maxOffset);
        [self.displayScrollView setContentOffset:CGPointMake(offset, self.displayScrollView.contentOffset.y) animated:animated];
    }
}

- (void)setLayerWithButton:(UIButton *)button borderType:(NSInteger)type {
    if (type == 0) {
        button.layer.borderColor = nil;
        button.layer.borderWidth = 0;
    } else {
        button.layer.borderColor = [UIColor colorWithRed:64 / 255.0 green:174 / 255.0 blue:252 / 255.0 alpha:1].CGColor;
        button.layer.borderWidth = 2;
    }
}

- (void)didClickCellImage {
    self.isHidden = !self.isHidden;
}

- (void)setIsHidden:(BOOL)isHidden {
    _isHidden = isHidden;
    self.navigationController.navigationBar.hidden = _isHidden;
    self.footerView.hidden = _isHidden;
    _displayScrollView.hidden = _isHidden;
}

- (PHImageManager *)imageManager {
    if (!_imageManager) {
        _imageManager = [PHImageManager defaultManager];
    }
    return _imageManager;
}

- (PHImageRequestOptions *)requestOptions {
    if (!_requestOptions) {
        _requestOptions = [[PHImageRequestOptions alloc] init];
        _requestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
        _requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    }
    return _requestOptions;
}

- (NSMutableArray *)selectedImages {
    if (!_selectedImages) {
        _selectedImages = [NSMutableArray array];
    }
    return _selectedImages;
}

- (NSMutableArray *)imageArray {
    if (!_imageArray) {
        _imageArray = [NSMutableArray array];
    }
    return _imageArray;
}

- (UILabel *)numberLabel {
    if (!_numberLabel) {
        _numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.rightButton.imageView.frame.size.width, self.rightButton.imageView.frame.size.height)];
        _numberLabel.textColor = [UIColor whiteColor];
        _numberLabel.font = [UIFont systemFontOfSize:18];
        _numberLabel.backgroundColor = [UIColor colorWithRed:64 / 255.0 green:174 / 255.0 blue:252 / 255.0 alpha:1];
        _numberLabel.layer.cornerRadius = self.rightButton.imageView.layer.cornerRadius;
        _numberLabel.layer.masksToBounds = YES;
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        [self.rightButton.imageView addSubview:_numberLabel];
    }
    return _numberLabel;
}

- (UIScrollView *)displayScrollView {
    if (!_displayScrollView) {
        _displayScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.footerView.frame.origin.y - 80, [UIScreen mainScreen].bounds.size.width, 80)];
        _displayScrollView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        _displayScrollView.bounces = YES;
        _displayScrollView.showsHorizontalScrollIndicator = NO;
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, _displayScrollView.frame.size.height - 0.5, _displayScrollView.frame.size.width, 0.5)];
        line.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
        [_displayScrollView addSubview:line];
        [self.view addSubview:self.displayScrollView];
    }
    return _displayScrollView;;
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
