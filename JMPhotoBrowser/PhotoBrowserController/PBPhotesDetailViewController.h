//
//  PBPhotesDetailViewController.h
//  ControlTest
//
//  Created by print on 2018/10/17.
//  Copyright © 2018年 liuxuanbo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class JMPhotoBrowser;
@interface PBPhotesDetailViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *imageArray;

@property (nonatomic, strong) NSMutableArray *selectedImages;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) JMPhotoBrowser *photoBrowser;
/// 是否是预览
@property (nonatomic, assign) BOOL isPreview;

@property (nonatomic, copy) void (^didChangeSelectedPhotoBlock)(void);


@end

NS_ASSUME_NONNULL_END
