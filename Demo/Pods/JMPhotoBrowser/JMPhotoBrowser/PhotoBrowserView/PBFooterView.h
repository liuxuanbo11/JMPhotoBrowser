//
//  PBFooterView.h
//  ControlTest
//
//  Created by print on 2018/10/25.
//  Copyright © 2018年 liuxuanbo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PBFooterViewDelegate <NSObject>

- (void)pbFooterViewDidSelectButton:(NSInteger)buttonIndex;

@end

@interface PBFooterView : UIView

@property (nonatomic, strong) UIButton *leftButton;

@property (nonatomic, strong) UIButton *rightButton;

@property (nonatomic, weak) id<PBFooterViewDelegate> delegate;

@property (nonatomic, strong) UIColor *themeColor;

@property (nonatomic, strong) UIColor *disableColor;


- (instancetype)initWithFrame:(CGRect)frame type:(NSInteger)type;

- (void)setLeftButtonText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
