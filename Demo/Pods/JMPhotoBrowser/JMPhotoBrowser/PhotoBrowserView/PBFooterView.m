//
//  PBFooterView.m
//  ControlTest
//
//  Created by print on 2018/10/25.
//  Copyright © 2018年 liuxuanbo. All rights reserved.
//

#import "PBFooterView.h"

@interface PBFooterView ()

@property (nonatomic, assign) NSInteger type;

@property (nonatomic, strong) UILabel *leftButtonTitle;

@property (nonatomic, assign) BOOL leftButtonSelected;

@end

@implementation PBFooterView

- (instancetype)initWithFrame:(CGRect)frame type:(NSInteger)type
{
    self = [super initWithFrame:frame];
    if (self) {
        self.type = type;
        self.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        [self createView];
    }
    return self;
}

- (void)createView {
    self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftButton.frame = CGRectMake(0, 0, 60, self.frame.size.height);
    [_leftButton setTitleColor:[UIColor colorWithRed:64 / 255.0 green:174 / 255.0 blue:252 / 255.0 alpha:1] forState:UIControlStateNormal];
    [_leftButton setTitleColor:[UIColor colorWithWhite:0.6 alpha:1] forState:UIControlStateDisabled];
    _leftButton.titleLabel.font = [UIFont systemFontOfSize:15];
    _leftButton.tag = 1;
    [_leftButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_leftButton];
    if (self.type == 1) {
        _leftButton.frame = CGRectMake(0, 0, 150, self.frame.size.height);
        [_leftButton setImage:[UIImage imageNamed:@"pb_weixuanzhong"] forState:UIControlStateNormal];
        [_leftButton setImage:[UIImage imageNamed:@"pb_xuanzhong"] forState:UIControlStateSelected];
        [_leftButton setImage:[UIImage imageNamed:@"pb_weixuanzhong"] forState:UIControlStateHighlighted];
        _leftButton.adjustsImageWhenHighlighted = NO;
        [_leftButton setImageEdgeInsets:UIEdgeInsetsMake((CGRectGetHeight(_leftButton.frame) - 18) / 2, 12, (CGRectGetHeight(_leftButton.frame) - 18) / 2, CGRectGetWidth(_leftButton.frame) - 30)];
        
        self.leftButtonTitle = [[UILabel alloc] initWithFrame:CGRectMake(33, 0, CGRectGetWidth(_leftButton.frame) - 33, CGRectGetHeight(_leftButton.frame))];
        _leftButtonTitle.textColor = [self.leftButton titleColorForState:UIControlStateDisabled];
        _leftButtonTitle.font = _leftButton.titleLabel.font;
        [_leftButton addSubview:_leftButtonTitle];
    }
    self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightButton.frame = CGRectMake(self.frame.size.width - 60 - 12, 7, 60, self.frame.size.height - 14);
    [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _rightButton.adjustsImageWhenDisabled = NO;
    _rightButton.titleLabel.font = [UIFont systemFontOfSize:13];
    _rightButton.backgroundColor = [UIColor colorWithRed:64 / 255.0 green:174 / 255.0 blue:252 / 255.0 alpha:1];
    _rightButton.layer.masksToBounds = YES;
    _rightButton.layer.cornerRadius = 5;
    _rightButton.tag = 2;
    [_rightButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_rightButton];
}

- (void)buttonAction:(UIButton *)sender {
    if (self.type == 1 && [sender isEqual:self.leftButton]) {
        self.leftButtonSelected = !self.leftButtonSelected;
    }
    if ([self.delegate respondsToSelector:@selector(pbFooterViewDidSelectButton:)]) {
        [self.delegate pbFooterViewDidSelectButton:sender.tag];
    }
}

- (void)setLeftButtonSelected:(BOOL)leftButtonSelected {
    _leftButtonSelected = leftButtonSelected;
    self.leftButton.selected = _leftButtonSelected;
    self.leftButtonTitle.textColor = _leftButtonSelected ? [UIColor colorWithWhite:0.15 alpha:1] : [self.leftButton titleColorForState:UIControlStateDisabled];
}

- (void)setLeftButtonText:(NSString *)text {
    if (self.type == 1) {
        self.leftButtonTitle.text = text;
    } else {
        [self.leftButton setTitle:text forState:UIControlStateNormal];
    }
}

- (void)setThemeColor:(UIColor *)themeColor {
    if (!themeColor) {
        return;
    }
    _themeColor = themeColor;
    [_leftButton setTitleColor:themeColor forState:UIControlStateNormal];
    _rightButton.backgroundColor = themeColor;
}

- (void)setDisableColor:(UIColor *)disableColor {
    if (!disableColor) {
        return;
    }
    _disableColor = disableColor;
    [_leftButton setTitleColor:disableColor forState:UIControlStateDisabled];
    _leftButtonTitle.textColor = disableColor;
}

@end
