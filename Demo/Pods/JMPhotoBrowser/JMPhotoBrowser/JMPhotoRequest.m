//
//  JMPhotoRequest.m
//  ControlTest
//
//  Created by print on 2019/1/3.
//  Copyright © 2019年 liuxuanbo. All rights reserved.
//

#import "JMPhotoRequest.h"
#import <Photos/Photos.h>
#import "PBAlbum.h"
#import "PBPhoto.h"

@interface JMPhotoRequest ()

@property (nonatomic, strong) PHImageRequestOptions *requestOptions;

@property (nonatomic, strong) PHFetchOptions *fetchOptions;

@end

@implementation JMPhotoRequest

- (void)fetchPhotoSourceWithAssetSize:(CGSize)assetSize completion:(void (^)(NSArray<PBAlbum *> *datasources))completion {
    // 获取照片资源
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray<PHAssetCollection *> *collections = [NSMutableArray array];

        PHFetchResult<PHAssetCollection *> *smallCollectionAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        [smallCollectionAlbum enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.assetCollectionSubtype != 1000000201) {
                [collections addObject:obj];
            }
        }];

        PHFetchResult<PHAssetCollection *> *collectionAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        [collectionAlbum enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.assetCollectionSubtype != 1000000201) {
                [collections addObject:obj];
            }
        }];
        // 获得所有相册后, 遍历相册获得图片
        NSMutableArray *availableCollections = [NSMutableArray array];
        for (PHAssetCollection *collection in collections) {
            PHFetchResult<PHAsset *> *phAssetResult = [PHAsset fetchAssetsInAssetCollection:collection options:self.fetchOptions];
            if (phAssetResult.count) {
                [availableCollections addObject:@{@"collection" : collection, @"phAssetResult" : phAssetResult}];
            }
        }
        NSMutableArray *datasources = [NSMutableArray array];
        __block int count = 0;
        for (NSDictionary *collectionDic in availableCollections) {
            PBAlbum *album = [[PBAlbum alloc] init];
            album.collection = collectionDic[@"collection"];
            [datasources addObject:album];
            PHFetchResult<PHAsset *> *phAssetResult = collectionDic[@"phAssetResult"];
            [self fetchImageWithPhAssetResult:phAssetResult assetSize:assetSize completion:^(NSArray *imageResults) {
                album.photos = imageResults;
                count++;
                if (count == availableCollections.count) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(datasources);                        
                    });
                }
            }];
        }
    });
}

- (void)fetchImageWithPhAssetResult:(PHFetchResult<PHAsset *> *)phAssetResult assetSize:(CGSize)assetSize completion:(void (^)(NSArray *imageResults))completion {
    // 下载图片
    NSMutableArray *imageResults = [NSMutableArray array];
    for (PHAsset *phAsset in phAssetResult) {
        [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:assetSize contentMode:PHImageContentModeAspectFit options:self.requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result) {
                [imageResults addObject:[PBPhoto photoWithAsset:phAsset smallImage:result]];
            }
            if (imageResults.count == phAssetResult.count) {
                // 按时间排序
                for (int i = 0; i < imageResults.count - 1; i++) {
                    for (int j = 0; j < imageResults.count - i - 1; j++) {
                        PBPhoto *photo1 = imageResults[j];
                        PBPhoto *photo2 = imageResults[j + 1];
                        if ([photo1.phAsset.creationDate compare:photo2.phAsset.creationDate] == NSOrderedDescending) {
                            [imageResults exchangeObjectAtIndex:j withObjectAtIndex:j + 1];
                        }
                    }
                }
                completion(imageResults);
            }
        }];
    }
}

- (PHFetchOptions *)fetchOptions {
    if (!_fetchOptions) {
        _fetchOptions = [[PHFetchOptions alloc] init];
        _fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    }
    return _fetchOptions;
}

- (PHImageRequestOptions *)requestOptions {
    if (!_requestOptions) {
        _requestOptions = [[PHImageRequestOptions alloc] init];
        _requestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
        _requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    }
    return _requestOptions;
}

@end
