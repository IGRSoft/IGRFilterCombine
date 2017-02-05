//
//  IGRBaseShaderFilter.m
//  IGRFilterCombineFramework
//
//  Created by Vitalii Parovishnyk on 12/29/16.
//  Copyright © 2016 IGR Software. All rights reserved.
//

#import "IGRBaseShaderFilter.h"
#import "IGRBaseShaderFilterConstants.h"
#import "NSBundle+IGRFilterCombine.h"

@interface IGRBaseShaderFilter () {
    BOOL hasSetTexture1;
    
    GPUImageFramebuffer *inputFramebuffer2;
    GLint textureCoordinateAttribute2;
    GLint inputTextureUniform2;
    BOOL hasSetTexture2;
    
    GPUImageFramebuffer *inputFramebuffer3;
    GLint textureCoordinateAttribute3;
    GLint inputTextureUniform3;
    BOOL hasSetTexture3;
    
    GPUImageFramebuffer *inputFramebuffer4;
    GLint textureCoordinateAttribute4;
    GLint inputTextureUniform4;
    BOOL hasSetTexture4;
    
    GPUImageFramebuffer *inputFramebuffer5;
    GLint textureCoordinateAttribute5;
    GLint inputTextureUniform5;
    BOOL hasSetTexture5;
    
    GPUImageFramebuffer *inputFramebuffer6;
    GLint textureCoordinateAttribute6;
    GLint inputTextureUniform6;
    BOOL hasSetTexture6;
}

@property (nonatomic, copy  ) NSString *shaderName;

@property (nonatomic, strong) NSArray <GPUImagePicture *> *resources;
@property (nonatomic, strong) NSOperationQueue *drawQueue;

@end

@implementation IGRBaseShaderFilter

- (instancetype)initWithDictionary:(NSDictionary *)aDictionary
{
    Class className = NSClassFromString(aDictionary[kSFXBaseShaderClassKey]);
    NSAssert(className, @"Class has not setuped for Filter Tool");
    
    NSString *shaderName = aDictionary[kSFXBaseShaderShaderNameKey];
    NSString *shader = [NSBundle shaderForName:shaderName] ;
    NSAssert(shader, @"Can't setup Filter Tool with shader - %@", shaderName);
    
    self = [[className alloc] initWithVertexShaderFromString:kSFXBaseShaderFilterVertexShaderString
                                    fragmentShaderFromString:shader];
    if (self)
    {
        _shaderName = shaderName;
        _displayName = aDictionary[kSFXBaseShaderNameKey];
        _resources = [self resourcesForFiles:aDictionary[kSFXBaseShaderResourceKey]];
        
        static NSOperationQueue *filterQueue;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            filterQueue = [NSOperationQueue new];
            filterQueue.maxConcurrentOperationCount = 1;
        });
        
        _drawQueue = filterQueue;
    }
    
    return self;
}

- (instancetype)initWithVertexShaderFromString:(NSString *)vertexShaderString
                      fragmentShaderFromString:(NSString *)fragmentShaderString
{
    if (!(self = [super initWithVertexShaderFromString:vertexShaderString
                              fragmentShaderFromString:fragmentShaderString])) {
        return nil;
    }
    
    inputRotation = kGPUImageNoRotation;
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        
        textureCoordinateAttribute2 = [filterProgram attributeIndex:@"inputTextureCoordinate2"];
        inputTextureUniform2 = [filterProgram uniformIndex:@"inputImageTexture2"];
        glEnableVertexAttribArray(textureCoordinateAttribute2);
        
        textureCoordinateAttribute3 = [filterProgram attributeIndex:@"inputTextureCoordinate3"];
        inputTextureUniform3 = [filterProgram uniformIndex:@"inputImageTexture3"];
        glEnableVertexAttribArray(textureCoordinateAttribute3);
        
        textureCoordinateAttribute4 = [filterProgram attributeIndex:@"inputTextureCoordinate4"];
        inputTextureUniform4 = [filterProgram uniformIndex:@"inputImageTexture4"];
        glEnableVertexAttribArray(textureCoordinateAttribute4);
        
        textureCoordinateAttribute5 = [filterProgram attributeIndex:@"inputTextureCoordinate5"];
        inputTextureUniform5 = [filterProgram uniformIndex:@"inputImageTexture5"];
        glEnableVertexAttribArray(textureCoordinateAttribute5);
        
        textureCoordinateAttribute6 = [filterProgram attributeIndex:@"inputTextureCoordinate6"];
        inputTextureUniform6 = [filterProgram uniformIndex:@"inputImageTexture6"];
        glEnableVertexAttribArray(textureCoordinateAttribute6);
    });
    
    return self;
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices
                 textureCoordinates:(const GLfloat *)textureCoordinates
{
    if (self.preventRendering)
    {
        [self clearTextures];
        
        return;
    }
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext setActiveShaderProgram:filterProgram];
        outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO]
                                                                               textureOptions:self.outputTextureOptions
                                                                                  onlyTexture:NO];
        [outputFramebuffer activateFramebuffer];
        
        if (usingNextFrameForImageCapture)
        {
            [outputFramebuffer lock];
        }
    });
    
    [self setUniformsForProgramAtIndex:0];
    
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform, 2);
    
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, [inputFramebuffer2 texture]);
    glUniform1i(inputTextureUniform2, 3);
    
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, [inputFramebuffer3 texture]);
    glUniform1i(inputTextureUniform3, 4);
    
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, [inputFramebuffer4 texture]);
    glUniform1i(inputTextureUniform4, 5);
    
    glActiveTexture(GL_TEXTURE6);
    glBindTexture(GL_TEXTURE_2D, [inputFramebuffer5 texture]);
    glUniform1i(inputTextureUniform5, 6);
    
    glActiveTexture(GL_TEXTURE7);
    glBindTexture(GL_TEXTURE_2D, [inputFramebuffer6 texture]);
    glUniform1i(inputTextureUniform6, 7);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    const GLvoid* textureCoordinatesForRotation = [[self class] textureCoordinatesForRotation:inputRotation];
    glVertexAttribPointer(textureCoordinateAttribute2, 2, GL_FLOAT, 0, 0, textureCoordinatesForRotation);
    glVertexAttribPointer(textureCoordinateAttribute3, 2, GL_FLOAT, 0, 0, textureCoordinatesForRotation);
    glVertexAttribPointer(textureCoordinateAttribute4, 2, GL_FLOAT, 0, 0, textureCoordinatesForRotation);
    glVertexAttribPointer(textureCoordinateAttribute5, 2, GL_FLOAT, 0, 0, textureCoordinatesForRotation);
    glVertexAttribPointer(textureCoordinateAttribute6, 2, GL_FLOAT, 0, 0, textureCoordinatesForRotation);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [self clearTextures];
    
    if (usingNextFrameForImageCapture) {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}

- (void)clearTextures
{
    if (hasSetTexture1)
    {
        [firstInputFramebuffer unlock];
        hasSetTexture1 = NO;
    }
    
    if (hasSetTexture2)
    {
        [inputFramebuffer2 unlock];
        hasSetTexture2 = NO;
    }
    
    if (hasSetTexture3)
    {
        [inputFramebuffer3 unlock];
        hasSetTexture3 = NO;
    }
    
    if (hasSetTexture4)
    {
        [inputFramebuffer4 unlock];
        hasSetTexture4 = NO;
    }
    
    if (hasSetTexture5)
    {
        [inputFramebuffer5 unlock];
        hasSetTexture5 = NO;
    }
    
    if (hasSetTexture6)
    {
        [inputFramebuffer6 unlock];
        hasSetTexture6 = NO;
    }
}

#pragma mark -
#pragma mark GPUImageInput

- (void)setInputFramebuffer:(GPUImageFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex
{
    if (textureIndex == 0)
    {
        firstInputFramebuffer = newInputFramebuffer;
        hasSetTexture1 = YES;
        [firstInputFramebuffer lock];
    }
    else if (textureIndex == 1)
    {
        inputFramebuffer2 = newInputFramebuffer;
        hasSetTexture2 = YES;
        [inputFramebuffer2 lock];
    }
    else if (textureIndex == 2)
    {
        inputFramebuffer3 = newInputFramebuffer;
        hasSetTexture3 = YES;
        [inputFramebuffer3 lock];
    }
    else if (textureIndex == 3)
    {
        inputFramebuffer4 = newInputFramebuffer;
        hasSetTexture4 = YES;
        [inputFramebuffer4 lock];
    }
    else if (textureIndex == 4)
    {
        inputFramebuffer5 = newInputFramebuffer;
        hasSetTexture5 = YES;
        [inputFramebuffer5 lock];
    }
    else
    {
        inputFramebuffer6 = newInputFramebuffer;
        hasSetTexture6 = YES;
        [inputFramebuffer6 lock];
    }
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex
{
    if (textureIndex == 0)
    {
        [super setInputSize:newSize atIndex:textureIndex];
    }
}

- (void)setInputRotation:(GPUImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex
{
    //Skip!
}

- (CGSize)rotatedSize:(CGSize)sizeToRotate forIndex:(NSInteger)textureIndex
{
    CGSize rotatedSize = sizeToRotate;
    
    if (GPUImageRotationSwapsWidthAndHeight(inputRotation))
    {
        rotatedSize.width = sizeToRotate.height;
        rotatedSize.height = sizeToRotate.width;
    }
    
    return rotatedSize;
}

- (NSArray <GPUImagePicture *> *)resourcesForFiles:(NSArray <NSString *> *)files
{
    NSMutableArray *resources = [NSMutableArray arrayWithCapacity:files.count];
    
    for (NSString *file in files)
    {
        UIImage *img = [NSBundle imageForName:file forShaderName:self.shaderName];
        NSAssert(img, @"Can't load image - %@ for %@ shader", file, NSStringFromClass([self class]));
        GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:img];
        [resources addObject:picture];
    }
    
    return resources;
}

- (IGRBaseShaderFilterCancelBlock)processImage:(UIImage *)image
                                 completeBlock:(IGRBaseShaderFilterCompletionBlock)completeBlock
{
    __weak typeof(self) weak = self;
    __block IGRBaseShaderFilterCancelBlock innerCancel = nil;
    __block BOOL isCanceled = false;
    
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        if (isCanceled)
        {
            return;
        }
        
        NSUInteger location = 0;
        GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:image];
        [picture addTarget:weak atTextureLocation:location++];
        [picture processImage];
        
        NSArray *resources = [weak.resources copy];
        for (GPUImagePicture *p in resources)
        {
            [p addTarget:weak atTextureLocation:location++];
            [p processImage];
        }
        
        [weak useNextFrameForImageCapture];
        UIImage *resultImage = nil;
        
        @try {
            resultImage = [weak imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp];
        } @catch (NSException *exception) {
            
        } @finally {
            [weak removeAllTargets];
            [weak removeOutputFramebuffer];
            
            if (isCanceled)
            {
                return;
            }
            
            if (!resultImage || CGSizeEqualToSize(resultImage.size, CGSizeZero)) {
                
                innerCancel = [weak processImage:image completeBlock:completeBlock];
                
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completeBlock(resultImage);
            });
        }
    }];
    
    __weak typeof(operation) weakOperation = operation;
    [self.drawQueue addOperation:operation];
    
    return ^{
        isCanceled = YES;
        [weakOperation cancel];
        
        if (innerCancel)
        {
            innerCancel();
        }
    };
}

- (void)reset
{
    [self.drawQueue cancelAllOperations];
    [self removeAllTargets];
}

@end
