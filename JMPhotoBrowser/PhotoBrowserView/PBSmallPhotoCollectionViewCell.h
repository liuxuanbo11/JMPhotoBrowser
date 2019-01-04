//
//  PBSmallPhotoCollectionViewCell.h
//  ControlTest
//
//  Created by print on 2018/10/22.
//  Copyright © 2018年 liuxuanbo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PBSmallPhotoCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imgView;

@property (nonatomic, strong) UIImageView *checkImageView;

@property (nonatomic, strong) UILabel *numberLabel;

@property (nonatomic, copy) void (^didSelectImageBlock)(void);

- (void)showMaskView;

- (void)removeMaskView;


@end

NS_ASSUME_NONNULL_END
