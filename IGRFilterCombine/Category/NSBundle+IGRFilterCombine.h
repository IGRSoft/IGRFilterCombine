//
//  NSBundle+IGRFilterCombines.h
//  IGRFilterCombineFramework
//
//  Created by Vitalii Parovishnyk on 12/29/16.
//  Copyright © 2016 IGR Software. All rights reserved.
//

@import Foundation;
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@class IGRBaseShaderFilter;

@interface NSBundle (IGRFilterCombine)

+ (NSString *)shaderForName:(NSString *)name;
+ (UIImage *)imageForName:(NSString *)name forShaderName:(NSString *)shaderName;

+ ( NSArray <IGRBaseShaderFilter *> *)getFilters;

@end

NS_ASSUME_NONNULL_END
