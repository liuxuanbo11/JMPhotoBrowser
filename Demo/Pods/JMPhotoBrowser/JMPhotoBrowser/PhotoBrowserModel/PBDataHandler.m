//
//  PBDataHandler.m
//  ControlTest
//
//  Created by print on 2019/1/3.
//  Copyright © 2019年 liuxuanbo. All rights reserved.
//

#import "PBDataHandler.h"
#import "PBPhoto.h"
#import <Photos/Photos.h>
@implementation PBDataHandler

+ (BOOL)photoArray:(NSArray *)photoArray ContainsAsset:(PHAsset *)phAsset {
    for (PBPhoto *photo in photoArray) {
        if ([photo.phAsset isEqual:phAsset]) {
            return YES;
        }
    }
    return NO;
}

@end
