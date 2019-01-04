//
//  JMPhotoRequest.h
//  ControlTest
//
//  Created by print on 2019/1/3.
//  Copyright © 2019年 liuxuanbo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class PBAlbum;
NS_ASSUME_NONNULL_BEGIN

@interface JMPhotoRequest : NSObject

- (void)fetchPhotoSourceWithAssetSize:(CGSize)assetSize completion:(void (^)(NSArray<PBAlbum *> *datasources))completion;


@end

NS_ASSUME_NONNULL_END
