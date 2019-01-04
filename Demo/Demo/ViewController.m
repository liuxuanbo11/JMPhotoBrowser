//
//  ViewController.m
//  Demo
//
//  Created by print on 2019/1/3.
//  Copyright © 2019年 liuxuanbo. All rights reserved.
//

#import "ViewController.h"
#import "JMPhotoBrowser.h"
@interface ViewController ()<JMPhotoBrowserDelegate>

@property (nonatomic, strong) NSArray *cellArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.cellArray = @[@"单选", @"多选"];
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    button1.frame = CGRectMake(100, 100, 100, 50);
    [button1 setTitle:@"单选图片" forState:UIControlStateNormal];
    [button1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button1.titleLabel.font = [UIFont systemFontOfSize:16];
    button1.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    [button1 addTarget:self action:@selector(radioAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];

    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.frame = CGRectMake(100, 200, 100, 50);
    [button2 setTitle:@"多选图片" forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button2.titleLabel.font = [UIFont systemFontOfSize:16];
    button2.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    [button2 addTarget:self action:@selector(checkAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];

    
}

- (void)radioAction {
    JMPhotoBrowser *photoBrowser = [JMPhotoBrowser browserWithDelegate:self presentController:self];
    [photoBrowser showActionSheet];

}

- (void)checkAction {
    JMPhotoBrowser *photoBrowser = [JMPhotoBrowser browserWithDelegate:self presentController:self];
    photoBrowser.singleSelect = NO;
    [photoBrowser showActionSheet];

}

// 单选回调
- (void)photoBrowser:(JMPhotoBrowser *)photoBrowser didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    NSLog(@"单选图片info: %@", info);
}
// 多选回调
- (void)photoBrowser:(JMPhotoBrowser *)photoBrowser didSelectedImages:(NSArray *)selectedImages {
    NSLog(@"多选图片: %@", selectedImages);
}
// dismissed
- (void)photoBrowserDidDismissed {
    NSLog(@"dismissed");
}


@end
