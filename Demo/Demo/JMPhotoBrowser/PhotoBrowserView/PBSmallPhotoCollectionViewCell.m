//
//  PBSmallPhotoCollectionViewCell.m
//  ControlTest
//
//  Created by print on 2018/10/22.
//  Copyright © 2018年 liuxuanbo. All rights reserved.
//

#import "PBSmallPhotoCollectionViewCell.h"

@interface PBSmallPhotoCollectionViewCell ()

@property (nonatomic, strong) UIButton *selectButton;

@property (nonatomic, strong) UIView *whiteMaskView;

@end

@implementation PBSmallPhotoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imgView = [[UIImageView alloc] init];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.layer.masksToBounds = YES;
        [self.contentView addSubview:_imgView];
        
        self.selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_selectButton addTarget:self action:@selector(selectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_selectButton];
        
        self.checkImageView = [[UIImageView alloc] init];
        _checkImageView.contentMode = UIViewContentModeScaleAspectFit;
        _checkImageView.image = [UIImage imageNamed:@"check"];
        _checkImageView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
        _checkImageView.layer.cornerRadius = 11;
        _checkImageView.layer.masksToBounds = YES;
        [self.selectButton addSubview:_checkImageView];
        
        self.numberLabel = [[UILabel alloc] init];
        _numberLabel.textColor = [UIColor whiteColor];
        _numberLabel.font = [UIFont systemFontOfSize:16];
        _numberLabel.backgroundColor = [UIColor colorWithRed:64 / 255.0 green:174 / 255.0 blue:252 / 255.0 alpha:1];
        _numberLabel.layer.cornerRadius = _checkImageView.layer.cornerRadius;
        _numberLabel.layer.masksToBounds = YES;
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        [self.checkImageView addSubview:_numberLabel];

        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imgView.frame = self.bounds;
    self.selectButton.frame = CGRectMake(self.imgView.frame.size.width / 2, 0, self.imgView.frame.size.width / 2, self.imgView.frame.size.width / 2);
    self.checkImageView.frame = CGRectMake(self.selectButton.frame.size.width - 2 - 22, 2, 22, 22);
    self.numberLabel.frame = self.checkImageView.bounds;
}

- (void)selectButtonAction:(UIButton *)sender {
    if (self.didSelectImageBlock) {
        self.didSelectImageBlock();
    }
}

- (void)showMaskView {
    if (!_whiteMaskView) {
        [self.contentView insertSubview:self.whiteMaskView belowSubview:self.selectButton];
    }
}

- (void)removeMaskView {
    if (_whiteMaskView) {
        [_whiteMaskView removeFromSuperview];
        _whiteMaskView = nil;
    }
}

- (UIView *)whiteMaskView {
    if (!_whiteMaskView) {
        _whiteMaskView = [[UIView alloc] initWithFrame:self.bounds];
        _whiteMaskView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
    }
    return _whiteMaskView;
}

@end
