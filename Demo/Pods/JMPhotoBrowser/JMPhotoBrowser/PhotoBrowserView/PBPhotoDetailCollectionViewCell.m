//
//  PBPhotoDetailCollectionViewCell.m
//  ControlTest
//
//  Created by print on 2018/10/22.
//  Copyright © 2018年 liuxuanbo. All rights reserved.
//

#import "PBPhotoDetailCollectionViewCell.h"

@interface PBPhotoDetailCollectionViewCell ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *imgView;

@end

@implementation PBPhotoDetailCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {        
        self.scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
        _scrollView.maximumZoomScale = 5;
        _scrollView.minimumZoomScale = 1;
        if (@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self.contentView addSubview:_scrollView];
        
        self.imgView = [[UIImageView alloc] init];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
        _imgView.userInteractionEnabled = YES;
        [self.scrollView addSubview:_imgView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        tapGesture.numberOfTapsRequired = 1;
        [self.imgView addGestureRecognizer:tapGesture];
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
        doubleTapGesture.numberOfTapsRequired = 2;
        [self.imgView addGestureRecognizer:doubleTapGesture];
        [tapGesture requireGestureRecognizerToFail:doubleTapGesture];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.scrollView.frame = self.bounds;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    if (_image && _image.size.width > 0) {
        CGFloat scale = _image.size.height / _image.size.width;
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = width * scale;
        self.imgView.frame = CGRectMake(0, height > [UIScreen mainScreen].bounds.size.height ? 0 : ([UIScreen mainScreen].bounds.size.height - height) / 2, width, height);
        self.scrollView.contentSize = CGSizeMake(self.imgView.frame.size.width, self.imgView.frame.size.height);
        self.imgView.image = _image;

    }
}

// 单击
- (void)tapAction:(UIGestureRecognizer *)rec {
    if ([self.delegate respondsToSelector:@selector(didClickCellImage)]) {
        [self.delegate didClickCellImage];
    }
}

// 双击
- (void)doubleTapAction:(UIGestureRecognizer *)rec {
    if (self.scrollView.zoomScale > 1) {
        [self.scrollView setZoomScale:1 animated:YES];
    } else {
        CGPoint touchPoint = [rec locationInView:_imgView];
        CGFloat newZoomScale = 2.5;
        CGFloat xsize = self.scrollView.frame.size.width/newZoomScale;
        CGFloat ysize = self.scrollView.frame.size.height/newZoomScale;
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x - xsize / 2, touchPoint.y, xsize, ysize) animated:YES];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imgView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (_imgView.frame.size.width <= [UIScreen mainScreen].bounds.size.width) {
        _imgView.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height / 2);
    } else {
        if (_imgView.frame.size.height <= [UIScreen mainScreen].bounds.size.height) {
            _imgView.center = CGPointMake(_imgView.center.x, [UIScreen mainScreen].bounds.size.height / 2);
        } else {
            _imgView.center = CGPointMake(_imgView.center.x, _imgView.frame.size.height / 2);
        }
    }
}


@end
