//
//  PBPhoto.h
//  ControlTest
//
//  Created by print on 2018/10/25.
//  Copyright © 2018年 liuxuanbo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class PHAsset;
NS_ASSUME_NONNULL_BEGIN

@interface PBPhoto : NSObject

@property (nonatomic, strong) PHAsset *phAsset;
// 小图
@property (nonatomic, strong) UIImage *smallImage;
// 全屏清晰图
@property (nonatomic, strong) UIImage *clearlyImage;
// 原图
@property (nonatomic, strong) UIImage *originalImage;
// 原图大小
@property (nonatomic, strong) NSString *sizeFormat;


+ (PBPhoto *)photoWithAsset:(PHAsset *)phAsset smallImage:(UIImage *)smallImage;


@end

NS_ASSUME_NONNULL_END
