//
//  JMPhotoBrowser.h
//  ControlTest
//
//  Created by print on 2018/10/18.
//  Copyright © 2018年 liuxuanbo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

#define SelectNotificationName @"DidSelectedImagesNotificationName"
#define CancelNotificationName @"CancelSelectedImagesNotificationName"

@class PHAsset, JMPhotoBrowser;
@protocol JMPhotoBrowserDelegate <NSObject>

@optional
- (void)photoBrowser:(JMPhotoBrowser *)photoBrowser didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info;

- (void)photoBrowser:(JMPhotoBrowser *)photoBrowser didSelectedImages:(NSArray *)selectedImages;

- (void)photoBrowserDidDismissed;

@end

@interface JMPhotoBrowser : NSObject

/// 照片是否是单选, 默认为YES
@property (nonatomic, assign) BOOL singleSelect;
/// 多选最大限制, 默认为9张
@property (nonatomic, assign) NSInteger maxSelectedCount;

@property (nonatomic, strong) UIColor *footerViewBackgroundColor;

@property (nonatomic, strong) UIColor *themeColor;

@property (nonatomic, strong) UIColor *disableColor;

@property (nonatomic, strong) UIImage *footerCheckImage;

@property (nonatomic, strong) UIImage *footerNotCheckImage;

@property (nonatomic, weak) id<JMPhotoBrowserDelegate> delegate;


+ (JMPhotoBrowser *)browserWithDelegate:(id)delegate presentController:(UIViewController *)presentController;

- (void)showActionSheet;

- (void)showPhotoSelectView;

@end

NS_ASSUME_NONNULL_END
