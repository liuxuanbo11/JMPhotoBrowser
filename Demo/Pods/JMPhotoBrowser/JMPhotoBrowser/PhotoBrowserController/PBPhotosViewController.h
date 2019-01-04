//
//  PBPhotosViewController.h
//  ControlTest
//
//  Created by print on 2018/10/17.
//  Copyright © 2018年 liuxuanbo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class JMPhotoBrowser;
@class PBPhoto;
@interface PBPhotosViewController : UIViewController

@property (nonatomic, strong) NSMutableArray<PBPhoto *> *photoArray;

@property (nonatomic, strong) JMPhotoBrowser *photoBrowser;

- (void)reloadPhotos;


@end

NS_ASSUME_NONNULL_END
