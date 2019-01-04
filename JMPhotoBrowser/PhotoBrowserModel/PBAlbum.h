//
//  PBAlbum.h
//  ControlTest
//
//  Created by print on 2019/1/3.
//  Copyright © 2019年 liuxuanbo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBPhoto.h"
@class PHAssetCollection;
NS_ASSUME_NONNULL_BEGIN

@interface PBAlbum : NSObject

@property (nonatomic, strong) PHAssetCollection *collection;

@property (nonatomic, strong) NSArray<PBPhoto *> *photos;

@end

NS_ASSUME_NONNULL_END
