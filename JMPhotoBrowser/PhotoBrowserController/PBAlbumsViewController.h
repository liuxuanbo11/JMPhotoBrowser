//
//  PBAlbumsViewController.h
//  ControlTest
//
//  Created by print on 2018/10/17.
//  Copyright © 2018年 liuxuanbo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class JMPhotoBrowser;
@interface PBAlbumsViewController : UIViewController

@property (nonatomic, strong) NSArray *datasource;

@property (nonatomic, strong) JMPhotoBrowser *photoBrowser;


@end

NS_ASSUME_NONNULL_END
