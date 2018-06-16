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

@interface IGRBaseShaderFilter ()

@property (nonatomic, assign) BOOL hasSetTexture1;

@property (nonatomic, strong) GPUImageFramebuffer *inputFramebuffer2;
@property (nonatomic, assign) GLint textureCoordinateAttribute2;
@property (nonatomic, assign) GLint inputTextureUniform2;
@property (nonatomic, assign) BOOL hasSetTexture2;

@property (nonatomic, strong) GPUImageFramebuffer *inputFramebuffer3;
@property (nonatomic, assign) GLint textureCoordinateAttribute3;
@property (nonatomic, assign) GLint inputTextureUniform3;
@property (nonatomic, assign) BOOL hasSetTexture3;

@property (nonatomic, strong) GPUImageFramebuffer *inputFramebuffer4;
@property (nonatomic, assign) GLint textureCoordinateAttribute4;
@property (nonatomic, assign) GLint inputTextureUniform4;
@property (nonatomic, assign) BOOL hasSetTexture4;

@property (nonatomic, strong) GPUImageFramebuffer *inputFramebuffer5;
@property (nonatomic, assign) GLint textureCoordinateAttribute5;
@property (nonatomic, assign) GLint inputTextureUniform5;
@property (nonatomic, assign) BOOL hasSetTexture5;

@property (nonatomic, strong) GPUImageFramebuffer *inputFramebuffer6;
@property (nonatomic, assign) GLint textureCoordinateAttribute6;
@property (nonatomic, assign) GLint inputTextureUniform6;
@property (nonatomic, assign) BOOL hasSetTexture6;

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
    
    __weak typeof(self) weak = self;
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        
        weak.textureCoordinateAttribute2 = [weak.internalFilterProgram attributeIndex:@"inputTextureCoordinate2"];
        weak.inputTextureUniform2 = [weak.internalFilterProgram uniformIndex:@"inputImageTexture2"];
        glEnableVertexAttribArray(weak.textureCoordinateAttribute2);
        
        weak.textureCoordinateAttribute3 = [weak.internalFilterProgram attributeIndex:@"inputTextureCoordinate3"];
        weak.inputTextureUniform3 = [weak.internalFilterProgram uniformIndex:@"inputImageTexture3"];
        glEnableVertexAttribArray(weak.textureCoordinateAttribute3);
        
        weak.textureCoordinateAttribute4 = [weak.internalFilterProgram attributeIndex:@"inputTextureCoordinate4"];
        weak.inputTextureUniform4 = [weak.internalFilterProgram uniformIndex:@"inputImageTexture4"];
        glEnableVertexAttribArray(weak.textureCoordinateAttribute4);
        
        weak.textureCoordinateAttribute5 = [weak.internalFilterProgram attributeIndex:@"inputTextureCoordinate5"];
        weak.inputTextureUniform5 = [weak.internalFilterProgram uniformIndex:@"inputImageTexture5"];
        glEnableVertexAttribArray(weak.textureCoordinateAttribute5);
        
        weak.textureCoordinateAttribute6 = [weak.internalFilterProgram attributeIndex:@"inputTextureCoordinate6"];
        weak.inputTextureUniform6 = [weak.internalFilterProgram uniformIndex:@"inputImageTexture6"];
        glEnableVertexAttribArray(weak.textureCoordinateAttribute6);
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
    
    __weak typeof(self) weak = self;
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext setActiveShaderProgram:weak.internalFilterProgram];
        self->outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO]
                                                                               textureOptions:self.outputTextureOptions
                                                                                  onlyTexture:NO];
        [self->outputFramebuffer activateFramebuffer];
        
        if (self->usingNextFrameForImageCapture)
        {
            [self->outputFramebuffer lock];
        }
    });
    
    [self setUniformsForProgramAtIndex:0];
    
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform, 2);
    
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, [self.inputFramebuffer2 texture]);
    glUniform1i(self.inputTextureUniform2, 3);
    
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, [self.inputFramebuffer3 texture]);
    glUniform1i(self.inputTextureUniform3, 4);
    
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, [self.inputFramebuffer4 texture]);
    glUniform1i(self.inputTextureUniform4, 5);
    
    glActiveTexture(GL_TEXTURE6);
    glBindTexture(GL_TEXTURE_2D, [self.inputFramebuffer5 texture]);
    glUniform1i(self.inputTextureUniform5, 6);
    
    glActiveTexture(GL_TEXTURE7);
    glBindTexture(GL_TEXTURE_2D, [self.inputFramebuffer6 texture]);
    glUniform1i(self.inputTextureUniform6, 7);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    const GLvoid* textureCoordinatesForRotation = [[self class] textureCoordinatesForRotation:inputRotation];
    glVertexAttribPointer(self.textureCoordinateAttribute2, 2, GL_FLOAT, 0, 0, textureCoordinatesForRotation);
    glVertexAttribPointer(self.textureCoordinateAttribute3, 2, GL_FLOAT, 0, 0, textureCoordinatesForRotation);
    glVertexAttribPointer(self.textureCoordinateAttribute4, 2, GL_FLOAT, 0, 0, textureCoordinatesForRotation);
    glVertexAttribPointer(self.textureCoordinateAttribute5, 2, GL_FLOAT, 0, 0, textureCoordinatesForRotation);
    glVertexAttribPointer(self.textureCoordinateAttribute6, 2, GL_FLOAT, 0, 0, textureCoordinatesForRotation);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [self clearTextures];
    
    if (usingNextFrameForImageCapture) {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}

- (GLProgram *)internalFilterProgram {
    return filterProgram;
}

- (void)clearTextures
{
    if (self.hasSetTexture1)
    {
        [firstInputFramebuffer unlock];
        self.hasSetTexture1 = NO;
    }
    
    if (self.hasSetTexture2)
    {
        [self.inputFramebuffer2 unlock];
        self.hasSetTexture2 = NO;
    }
    
    if (self.hasSetTexture3)
    {
        [self.inputFramebuffer3 unlock];
        self.hasSetTexture3 = NO;
    }
    
    if (self.hasSetTexture4)
    {
        [self.inputFramebuffer4 unlock];
        self.hasSetTexture4 = NO;
    }
    
    if (self.hasSetTexture5)
    {
        [self.inputFramebuffer5 unlock];
        self.hasSetTexture5 = NO;
    }
    
    if (self.hasSetTexture6)
    {
        [self.inputFramebuffer6 unlock];
        self.hasSetTexture6 = NO;
    }
}

#pragma mark -
#pragma mark GPUImageInput

- (void)setInputFramebuffer:(GPUImageFramebuffer *)newInputFramebuffer
                    atIndex:(NSInteger)textureIndex
{
    if (textureIndex == 0)
    {
        firstInputFramebuffer = newInputFramebuffer;
        self.hasSetTexture1 = YES;
        [firstInputFramebuffer lock];
    }
    else if (textureIndex == 1)
    {
        self.inputFramebuffer2 = newInputFramebuffer;
        self.hasSetTexture2 = YES;
        [self.inputFramebuffer2 lock];
    }
    else if (textureIndex == 2)
    {
        self.inputFramebuffer3 = newInputFramebuffer;
        self.hasSetTexture3 = YES;
        [self.inputFramebuffer3 lock];
    }
    else if (textureIndex == 3)
    {
        self.inputFramebuffer4 = newInputFramebuffer;
        self.hasSetTexture4 = YES;
        [self.inputFramebuffer4 lock];
    }
    else if (textureIndex == 4)
    {
        self.inputFramebuffer5 = newInputFramebuffer;
        self.hasSetTexture5 = YES;
        [self.inputFramebuffer5 lock];
    }
    else
    {
        self.inputFramebuffer6 = newInputFramebuffer;
        self.hasSetTexture6 = YES;
        [self.inputFramebuffer6 lock];
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
    NSMutableArray *resources = [NSMutableArray array];
    
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
