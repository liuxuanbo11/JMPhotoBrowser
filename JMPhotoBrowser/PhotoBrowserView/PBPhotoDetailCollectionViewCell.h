//
//  PBPhotoDetailCollectionViewCell.h
//  ControlTest
//
//  Created by print on 2018/10/22.
//  Copyright © 2018年 liuxuanbo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PBPhotoDetailCollectionViewCellDelegate <NSObject>

- (void)didClickCellImage;

@end


@interface PBPhotoDetailCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, weak) id<PBPhotoDetailCollectionViewCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
