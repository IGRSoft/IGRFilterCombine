//
//  IGRFilterCombines.m
//  IGRFilterCombineFramework
//
//  Created by Vitalii Parovishnyk on 12/29/16.
//  Copyright © 2016 IGR Software. All rights reserved.
//

#import "UIImage+IGRFilterCombine.h"

@implementation UIImage (IGRFilterCombine)

- (UIImage *)igr_imageWithDefaultOrientation
{
    CGFloat radian = 0;
    CGSize rotatedSize = self.size;
    if (self.imageOrientation == UIImageOrientationUp)
    {
        return self;
    }
    else if (self.imageOrientation == UIImageOrientationLeft)
    {
        radian = -M_PI_2;
        rotatedSize = CGSizeMake(rotatedSize.height, rotatedSize.width);
    }
    else if (self.imageOrientation == UIImageOrientationRight)
    {
        radian = M_PI_2;
        rotatedSize = CGSizeMake(rotatedSize.height, rotatedSize.width);
    }
    else if (self.imageOrientation == UIImageOrientationDown)
    {
        radian = M_PI;
    }
    
    // Create the bitmap context
    CGSize selfSize = self.size;
    UIGraphicsBeginImageContext(selfSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, selfSize.width * 0.5, selfSize.height * 0.5);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, radian);
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGRect processRect = CGRectMake(-rotatedSize.width * 0.5,
                                    -rotatedSize.height * 0.5,
                                    rotatedSize.width,
                                    rotatedSize.height);
    
    CGContextDrawImage(bitmap, processRect, [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)igr_aspectFillImageWithSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    CGSize selfSize = self.size;
    CGFloat scale = MAX(size.width / selfSize.width, size.height / selfSize.height);
    CGSize newSize = CGSizeMake(ceil(selfSize.width * scale), ceil(selfSize.height * scale));
    CGRect frame = CGRectMake(ceil((size.width - newSize.width) * 0.5),
                              ceil((size.height - newSize.height) * 0.5),
                              newSize.width,
                              newSize.height);
    [self drawInRect:frame];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
