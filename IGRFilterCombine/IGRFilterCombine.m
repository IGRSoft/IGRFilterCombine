//
//  IGRFilterCombine.m
//  IGRFilterCombine
//
//  Created by Vitalii Parovishnyk on 12/29/16.
//  Copyright © 2016 IGR Software. All rights reserved.
//

#import "IGRFilterCombine.h"
#import "IGRBaseShaderFilter.h"
#import "UIImage+IGRFilterCombine.h"
#import "NSBundle+IGRFilterCombine.h"

const NSUInteger kOriginalImageIndex = 100000;

@interface IGRFilterCombine ()

@property (nonatomic, strong) UIImage *originalImage;

@property (nonatomic, weak ) id<IGRFilterCombineDelegate> delegate;

@property (nonatomic, strong) NSArray <IGRBaseShaderFilter *> *processedImagesFilters;
@property (nonatomic, strong) NSArray <IGRBaseShaderFilter *> *processedPreviewImagesFilters;

@property (nonatomic, strong) NSMutableArray <IGRBaseShaderFilterCancelBlock> *cancelBlocks;
@property (nonatomic, strong) NSMutableArray <NSString *> *processedImages;
@property (nonatomic, strong) NSMutableArray <UIImage *> *processedPreviewImages;

@property (nonatomic, copy) IGRFilterCombineImageCompletion processedImagesCompletion;
@property (nonatomic, copy) IGRFilterCombineImageCompletion processedPreviewImagesCompletion;

@property (nonatomic, copy) IGRBaseShaderFilterCancelBlock cancelFilterProcess;

@property (nonatomic, strong) NSArray <IGRBaseShaderFilter *> *cachedFilters;
@property (nonatomic, strong) NSMutableArray <IGRBaseShaderFilterCancelBlock> *dummyCancelBlocks;

@end

@implementation IGRFilterCombine

- (instancetype)initWithDelegate:(id<IGRFilterCombineDelegate>)delegate
{
    if (self = [super init])
    {
        self.delegate = delegate;
    }
    
    return self;
}

- (void)setDelegate:(id<IGRFilterCombineDelegate>)delegate
{
    _delegate = delegate;
    _cachedFilters = [NSBundle getFilters];
    
    UIImage *image = [UIImage new];
    NSString *imageName = [self imagePathAtIndex:kOriginalImageIndex];
    IGRBaseShaderFilterCancelBlock cancelBlock = ^{};
    NSMutableArray <NSString *> *imagesName = [NSMutableArray array];
    NSMutableArray <UIImage *> *images = [NSMutableArray array];
    _dummyCancelBlocks = [NSMutableArray array];
    
    __weak typeof(self) weak = self;
    [self.cachedFilters enumerateObjectsUsingBlock:^(IGRBaseShaderFilter *filter, NSUInteger idx, BOOL * _Nonnull stop) {
        [imagesName addObject:imageName];
        [images addObject:image];
        [weak.dummyCancelBlocks addObject:cancelBlock];
    }];
    
    _processedImages = [imagesName mutableCopy];
    _processedPreviewImages = [images mutableCopy];
    _cancelBlocks = [_dummyCancelBlocks mutableCopy];
}

- (void)setOriginalImage:(UIImage *)originalImage
{
    _originalImage = originalImage;
    NSData *imageData = UIImagePNGRepresentation(originalImage);
    NSString *imagePath = [self imagePathAtIndex:kOriginalImageIndex];
    [imageData writeToFile:imagePath atomically:YES];
    
    UIImage *thumbImage = [originalImage igr_aspectFillImageWithSize:[self.delegate previewSize]];
    
    [_cancelBlocks enumerateObjectsUsingBlock:^(IGRBaseShaderFilterCancelBlock  _Nonnull cancelBlock, NSUInteger idx, BOOL * _Nonnull stop) {
        cancelBlock();
    }];
    _cancelBlocks = [_dummyCancelBlocks mutableCopy];
    
    //Cleean and Setup preview image
    __weak typeof(self) weak = self;
    [_processedPreviewImagesFilters enumerateObjectsUsingBlock:^(IGRBaseShaderFilter *filter, NSUInteger idx, BOOL * _Nonnull stop) {
        [filter removeAllTargets];
        [filter removeOutputFramebuffer];
    }];
    _processedPreviewImagesFilters = [self.cachedFilters copy];
    [_processedPreviewImagesFilters enumerateObjectsUsingBlock:^(IGRBaseShaderFilter *filter, NSUInteger idx, BOOL * _Nonnull stop) {
        [weak setFilteredPreviewImage:thumbImage toIndex:idx];
        [filter processImage:thumbImage
               completeBlock:^(UIImage * _Nullable processedImage) {
                   __strong __typeof(weak) strongSelf = weak;
                   if (strongSelf != nil) {
                       [strongSelf setFilteredPreviewImage:processedImage toIndex:idx];
                       strongSelf.processedPreviewImagesCompletion(processedImage, idx);
                   }
               }];
    }];
    
    //Cleean and Setup original image
    [_processedImagesFilters enumerateObjectsUsingBlock:^(IGRBaseShaderFilter *filter, NSUInteger idx, BOOL * _Nonnull stop) {
        [filter removeAllTargets];
        [filter removeOutputFramebuffer];
    }];
    _processedImagesFilters = [self.cachedFilters copy];
    [_processedImagesFilters enumerateObjectsUsingBlock:^(IGRBaseShaderFilter *filter, NSUInteger idx, BOOL * _Nonnull stop) {
        [weak setFilteredImage:originalImage toIndex:idx];
        IGRBaseShaderFilterCancelBlock cancelBlock = [filter processImage:originalImage
                                                            completeBlock:^(UIImage * _Nullable processedImage) {
                                                                __strong __typeof(weak) strongSelf = weak;
                                                                if (strongSelf != nil) {
                                                                    [strongSelf setFilteredImage:processedImage toIndex:idx];
                                                                    strongSelf.processedImagesCompletion(processedImage, idx);
                                                                }
                                                            }];
        [weak setCancelBlock:cancelBlock toIndex:idx];
    }];
}

- (void)setImage:(UIImage *)image
      completion:(IGRFilterCombineImageCompletion)completion
         preview:(IGRFilterCombineImageCompletion)preview
{
    self.processedImagesCompletion = [completion copy];
    self.processedPreviewImagesCompletion = [preview copy];
    
    UIImage *fixedImage = [image igr_imageWithDefaultOrientation];
    self.originalImage = fixedImage;
}

- (NSString *)filtereNameAtIndex:(NSUInteger)imageIndex
{
    return _cachedFilters[imageIndex].displayName;
}

- (void)setFilteredImage:(UIImage *)image toIndex:(NSUInteger)imageIndex
{
    NSString *imagePath = [self imagePathAtIndex:imageIndex];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = UIImagePNGRepresentation(image);

        [imageData writeToFile:imagePath atomically:YES];
    });
    
    self.processedImages[imageIndex] = [imagePath copy];
}

- (UIImage *)filteredImageAtIndex:(NSUInteger)imageIndex
{
    NSString *imagePath = self.processedImages[imageIndex];
    return [[UIImage alloc] initWithContentsOfFile:imagePath];
}

- (void)setFilteredPreviewImage:(UIImage *)image toIndex:(NSUInteger)imageIndex
{
    self.processedPreviewImages[imageIndex] = image;
}

- (UIImage *)filteredPreviewImageAtIndex:(NSUInteger)imageIndex
{
    return self.processedPreviewImages[imageIndex];
}

- (void)setCancelBlock:(IGRBaseShaderFilterCancelBlock)block toIndex:(NSUInteger)imageIndex
{
    self.cancelBlocks[imageIndex] = block;
}

- (void)cancelImageAtIndex:(NSUInteger)imageIndex
{
    IGRBaseShaderFilterCancelBlock cancelBlock = self.cancelBlocks[imageIndex];
    cancelBlock();
}

- (NSUInteger)count
{
    return _cachedFilters.count;
}

- (NSString *)imagePathAtIndex:(NSUInteger)imageIndex {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = paths.firstObject;
    return [NSString stringWithFormat:@"%@/%@.png", cacheDirectory, @(kOriginalImageIndex + imageIndex)];
}

@end
