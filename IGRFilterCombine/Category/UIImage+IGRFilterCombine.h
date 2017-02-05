//
//  UIImage+Extension.h
//  IGRFilterCombineFramework
//
//  Created by Vitalii Parovishnyk on 12/29/16.
//  Copyright © 2016 IGR Software. All rights reserved.
//

@import UIKit;
@import CoreGraphics;

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (IGRFilterCombines)

- (UIImage *)igr_imageWithDefaultOrientation;
- (UIImage *)igr_aspectFillImageWithSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
