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

@interface IGRFilterCombine ()
{
    NSArray <IGRBaseShaderFilter *> *_cachedFilters;
    NSMutableArray <IGRBaseShaderFilterCancelBlock> *_dummyCancelBlocks;
}

@property (nonatomic, strong) UIImage *originalImage;

@property (nonatomic, weak ) id<IGRFilterCombineDelegate> delegate;

@property (nonatomic, strong) NSArray <IGRBaseShaderFilter *> *processedImagesFilters;
@property (nonatomic, strong) NSArray <IGRBaseShaderFilter *> *processedPreviewImagesFilters;

@property (nonatomic, copy) NSMutableArray <IGRBaseShaderFilterCancelBlock> *cancelBlocks;
@property (nonatomic, copy) NSMutableArray <UIImage *> *processedImages;
@property (nonatomic, copy) NSMutableArray <UIImage *> *processedPreviewImages;

@property (nonatomic, copy) IGRFilterCombineImageCompletion processedImagesCompletion;
@property (nonatomic, copy) IGRFilterCombineImageCompletion processedPreviewImagesCompletion;

@property (strong, nonatomic) dispatch_queue_t processedImagesQueue;
@property (strong, nonatomic) dispatch_queue_t cancelBlocksQueue;

@property (nonatomic, copy  ) IGRBaseShaderFilterCancelBlock cancelFilterProcess;

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
    IGRBaseShaderFilterCancelBlock cancelBlock = ^{};
    NSMutableArray <UIImage *> *images = [NSMutableArray arrayWithCapacity:self.count];
    _dummyCancelBlocks = [NSMutableArray arrayWithCapacity:self.count];
    [_cachedFilters enumerateObjectsUsingBlock:^(IGRBaseShaderFilter *filter, NSUInteger idx, BOOL * _Nonnull stop) {
        [images addObject:image];
        [_dummyCancelBlocks addObject:cancelBlock];
    }];
    
    _processedImages = images;
    _processedPreviewImages = images;
    _cancelBlocks = [_dummyCancelBlocks mutableCopy];
    
    _processedImagesQueue = dispatch_queue_create("com.igrsoft.IGRFilterCombine.processedImagesQueue", DISPATCH_QUEUE_CONCURRENT);
    _cancelBlocksQueue = dispatch_queue_create("com.igrsoft.IGRFilterCombine.cancelBlocksQueue", DISPATCH_QUEUE_CONCURRENT);
}

- (void)setOriginalImage:(UIImage *)originalImage
{
    _originalImage = originalImage;
    UIImage *thumbImage = [originalImage igr_aspectFillImageWithSize:[self.delegate previewSize]];
    
    [_cancelBlocks enumerateObjectsUsingBlock:^(IGRBaseShaderFilterCancelBlock  _Nonnull cancelBlock, NSUInteger idx, BOOL * _Nonnull stop) {
        cancelBlock();
    }];
    _cancelBlocks = [_dummyCancelBlocks mutableCopy];
    
    __weak typeof(self) weak = self;
    
    //Cleean and Setup preview image
    [_processedPreviewImagesFilters enumerateObjectsUsingBlock:^(IGRBaseShaderFilter *filter, NSUInteger idx, BOOL * _Nonnull stop) {
        [filter removeAllTargets];
        [filter removeOutputFramebuffer];
    }];
    _processedPreviewImagesFilters = [_cachedFilters copy];
    [_processedPreviewImagesFilters enumerateObjectsUsingBlock:^(IGRBaseShaderFilter *filter, NSUInteger idx, BOOL * _Nonnull stop) {
        [weak setFilteredPreviewImage:thumbImage toIndex:idx];
        [filter processImage:thumbImage
               completeBlock:^(UIImage * _Nullable processedImage) {
                   [weak setFilteredPreviewImage:processedImage toIndex:idx];
                   weak.processedPreviewImagesCompletion(processedImage, idx);
               }];
    }];
    
    //Cleean and Setup original image
    [_processedImagesFilters enumerateObjectsUsingBlock:^(IGRBaseShaderFilter *filter, NSUInteger idx, BOOL * _Nonnull stop) {
        [filter removeAllTargets];
        [filter removeOutputFramebuffer];
    }];
    _processedImagesFilters = [_cachedFilters copy];
    [_processedImagesFilters enumerateObjectsUsingBlock:^(IGRBaseShaderFilter *filter, NSUInteger idx, BOOL * _Nonnull stop) {
        [weak setFilteredImage:originalImage toIndex:idx];
        IGRBaseShaderFilterCancelBlock cancelBlock = [filter processImage:originalImage
                                                            completeBlock:^(UIImage * _Nullable processedImage) {
                                                                [weak setFilteredPreviewImage:processedImage toIndex:idx];
                                                                weak.processedImagesCompletion(processedImage, idx);
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
    UIImage *filteredImage = [image copy];
    dispatch_barrier_async(self.processedImagesQueue, ^{
        self.processedImages[imageIndex] = filteredImage;
    });
}

- (UIImage *)filteredImageAtIndex:(NSUInteger)imageIndex
{
    __block UIImage *filteredImage;
    dispatch_sync(self.processedImagesQueue, ^{
        filteredImage = self.processedImages[imageIndex];
    });
    
    return filteredImage;
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
    IGRBaseShaderFilterCancelBlock cancelBlock = [block copy];
    dispatch_barrier_async(self.cancelBlocksQueue, ^{
        self.cancelBlocks[imageIndex] = cancelBlock;
    });
}

- (void)cancelImageAtIndex:(NSUInteger)imageIndex
{
    __block IGRBaseShaderFilterCancelBlock cancelBlock;
    dispatch_sync(self.cancelBlocksQueue, ^{
        cancelBlock = self.cancelBlocks[imageIndex];
    });
    
    cancelBlock();
}

- (NSUInteger)count
{
    return _cachedFilters.count;
}


@end