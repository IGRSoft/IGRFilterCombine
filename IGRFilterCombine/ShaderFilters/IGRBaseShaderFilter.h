//
//  IGRBaseShaderFilter.h
//  IGRFilterCombineFramework
//
//  Created by Vitalii Parovishnyk on 12/29/16.
//  Copyright © 2016 IGR Software. All rights reserved.
//

@import GPUImage;

NS_ASSUME_NONNULL_BEGIN

typedef void(^IGRBaseShaderFilterCompletionBlock)(UIImage * _Nullable processedImage);
typedef void(^IGRBaseShaderFilterCancelBlock)(void);

@interface IGRBaseShaderFilter : GPUImageFilter

- (instancetype)initWithDictionary:(NSDictionary *)aDictionary;

@property (nonatomic, copy  , nullable) NSString *displayName;

- (IGRBaseShaderFilterCancelBlock)processImage:(UIImage *)image
                                 completeBlock:(IGRBaseShaderFilterCompletionBlock)completeBlock;

@end

NS_ASSUME_NONNULL_END
