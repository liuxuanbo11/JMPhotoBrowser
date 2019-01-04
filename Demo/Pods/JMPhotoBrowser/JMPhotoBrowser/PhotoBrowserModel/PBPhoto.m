//
//  PBPhoto.m
//  ControlTest
//
//  Created by print on 2018/10/25.
//  Copyright © 2018年 liuxuanbo. All rights reserved.
//

#import "PBPhoto.h"

@implementation PBPhoto

+ (PBPhoto *)photoWithAsset:(PHAsset *)phAsset smallImage:(UIImage *)smallImage {
    PBPhoto *photo = [[PBPhoto alloc] initWithAsset:phAsset smallImage:smallImage];
    return photo;
}

- (instancetype)initWithAsset:(PHAsset *)phAsset smallImage:(UIImage *)smallImage
{
    self = [super init];
    if (self) {
        self.smallImage = smallImage;
        self.phAsset = phAsset;
    }
    return self;
}

@end
