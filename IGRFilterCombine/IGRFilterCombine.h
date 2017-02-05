//
//  IGRFilterCombine.h
//  IGRFilterCombine
//
//  Created by Vitalii Parovishnyk on 12/29/16.
//  Copyright © 2016 IGR Software. All rights reserved.
//

@import UIKit;

@class IGRBaseShaderFilter;

typedef void(^IGRFilterCombineImageCompletion)(UIImage * _Nullable processedImage, NSUInteger idx);

@protocol IGRFilterCombineDelegate <NSObject>

- (CGSize)previewSize;

@end

NS_ASSUME_NONNULL_BEGIN

@interface IGRFilterCombine : NSObject

- (instancetype)initWithDelegate:(id<IGRFilterCombineDelegate>)delegate NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (void)setImage:(UIImage *)image
      completion:(IGRFilterCombineImageCompletion)completion
         preview:(IGRFilterCombineImageCompletion)preview;

- (NSString *)filtereNameAtIndex:(NSUInteger)imageIndex;
- (UIImage *)filteredImageAtIndex:(NSUInteger)imageIndex;
- (UIImage *)filteredPreviewImageAtIndex:(NSUInteger)imageIndex;

- (NSUInteger)count;

@end

NS_ASSUME_NONNULL_END
