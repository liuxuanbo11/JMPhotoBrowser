//
//  PBAlbumsViewController.m
//  ControlTest
//
//  Created by print on 2018/10/17.
//  Copyright © 2018年 liuxuanbo. All rights reserved.
//

#import "PBAlbumsViewController.h"
#import <Photos/Photos.h>
#import "JMPhotoBrowser.h"
#import "PBAlbum.h"
#import "PBPhoto.h"
#import "PBPhotosViewController.h"
#import "PBAlbumTableViewCell.h"

@interface PBAlbumsViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation PBAlbumsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self addRightButtonWithTitle:@"取消"];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] init];
    if (@available(iOS 11.0, *)) {
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
    }
    [self.view addSubview:_tableView];

}

- (UIButton *)addRightButtonWithTitle:(NSString *)buttonTitle {
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 44, 44);
    [rightButton setTitle:buttonTitle forState:UIControlStateNormal];
    [rightButton setTitleColor:self.photoBrowser.themeColor ? self.photoBrowser.themeColor : [UIColor blackColor] forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [rightButton setTitleEdgeInsets:UIEdgeInsetsMake(0, CGRectGetWidth(rightButton.frame) - rightButton.titleLabel.intrinsicContentSize.width, 0, 0)];
    UIView *backView = [[UIView alloc] initWithFrame:rightButton.frame];
    [backView addSubview:rightButton];
    [rightButton addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backView];
    return rightButton;
}

#pragma mark - tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    PBAlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[PBAlbumTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    PBAlbum *album = self.datasource[indexPath.row];
    cell.imgView.image = ((PBPhoto *)[album.photos lastObject]).smallImage;
    cell.titleLabel.text = album.collection.localizedTitle;
    cell.subTitleLabel.text = [NSString stringWithFormat:@"%ld", album.photos.count];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PBPhotosViewController *photosVC = [[PBPhotosViewController alloc] init];
    photosVC.photoBrowser = self.photoBrowser;
    [self.navigationController pushViewController:photosVC animated:YES];
    [photosVC.photoArray addObjectsFromArray:((PBAlbum *)self.datasource[indexPath.row]).photos];
    [photosVC reloadPhotos];
}

- (void)rightButtonAction:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:CancelNotificationName object:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
