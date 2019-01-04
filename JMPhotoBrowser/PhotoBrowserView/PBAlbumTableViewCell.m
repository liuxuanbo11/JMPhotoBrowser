//
//  PBAlbumTableViewCell.m
//  ControlTest
//
//  Created by print on 2018/10/22.
//  Copyright © 2018年 liuxuanbo. All rights reserved.
//

#import "PBAlbumTableViewCell.h"
#import "Masonry.h"
@implementation PBAlbumTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.imgView = [[UIImageView alloc] init];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.clipsToBounds = YES;
        [self.contentView addSubview:_imgView];
        [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(15);
            make.top.offset(10);
            make.bottom.offset(-10);
            make.width.equalTo(self.imgView.mas_height);
        }];
        
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.imgView.mas_right).offset(15);
            make.bottom.equalTo(self.imgView.mas_centerY).offset(-4);
        }];
        
        self.subTitleLabel = [[UILabel alloc] init];
        _subTitleLabel.textColor = [UIColor blackColor];
        _subTitleLabel.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:_subTitleLabel];
        [_subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.imgView.mas_right).offset(15);
            make.top.equalTo(self.imgView.mas_centerY).offset(4);
        }];


    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
