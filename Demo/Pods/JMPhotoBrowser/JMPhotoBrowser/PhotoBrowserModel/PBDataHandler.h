//
//  PBDataHandler.h
//  ControlTest
//
//  Created by print on 2019/1/3.
//  Copyright © 2019年 liuxuanbo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PHAsset;
@interface PBDataHandler : NSObject

+ (BOOL)photoArray:(NSArray *)photoArray ContainsAsset:(PHAsset *)phAsset;


@end

NS_ASSUME_NONNULL_END
