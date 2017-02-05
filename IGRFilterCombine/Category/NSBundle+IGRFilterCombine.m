//
//  NSBundle+IGRFilterCombines.m
//  IGRFilterCombineFramework
//
//  Created by Vitalii Parovishnyk on 12/29/16.
//  Copyright © 2016 IGR Software. All rights reserved.
//

#import "NSBundle+IGRFilterCombine.h"
#import "IGRFilterCombine.h"
#import "IGRBaseShaderFilter.h"

@implementation NSBundle (IGRFilterCombine)

+ (instancetype)igr_filtersResourceBundle
{
    static NSBundle *resourceBundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *bundle = [NSBundle bundleForClass:[IGRFilterCombine class]];
        NSString *resourceBundlePath = [bundle pathForResource:@"IGRFilterCombineResources" ofType:@"bundle"];
        
        resourceBundle = [self bundleWithPath:resourceBundlePath];
    });
    
    return resourceBundle;
}

+ (NSString *)shaderForName:(NSString *)name
{
    NSString *path = [[NSBundle igr_filtersResourceBundle] pathForResource:name
                                                                    ofType:@"glsl"
                                                               inDirectory:@"Shaders"];
    return [[NSString alloc] initWithContentsOfFile:path
                                                       encoding:NSUTF8StringEncoding
                                                          error:nil];
}

+ (UIImage *)imageForName:(NSString *)name forShaderName:(NSString *)shaderName
{
    NSString *dir = [NSString stringWithFormat:@"Images/%@", shaderName];
    NSString *path = [[NSBundle igr_filtersResourceBundle] pathForResource:name
                                                                    ofType:@"png"
                                                               inDirectory:dir];
    return [[UIImage alloc] initWithContentsOfFile:path];
}

+ (NSArray <IGRBaseShaderFilter *> *)getFilters
{
    static NSArray *filters = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *path = [[NSBundle igr_filtersResourceBundle] pathForResource:@"filters"
                                                                        ofType:@"plist"
                                                                   inDirectory:@"Configs"];
        NSArray *toolbarElements = [NSArray arrayWithContentsOfFile:path];
        
        NSMutableArray *_filters = [NSMutableArray arrayWithCapacity:toolbarElements.count];
        [toolbarElements enumerateObjectsUsingBlock:^(NSDictionary *shaderInfo, NSUInteger idx, BOOL * _Nonnull stop) {
            
            IGRBaseShaderFilter *filter = [[IGRBaseShaderFilter alloc] initWithDictionary:shaderInfo];
            [_filters addObject:filter];
        }];
        
        filters = [_filters copy];
    });
    
    return [filters copy];
}

@end
