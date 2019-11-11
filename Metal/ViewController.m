//
//  ViewController.m
//  Metal
//
//  Created by 张奥 on 2019/10/23.
//  Copyright © 2019 张奥. All rights reserved.
//
@import MetalKit;
#import "ViewController.h"
#import "LYShaderTypes.h"
#import "MetalView.h"
#import "MetalViewTwo.h"
@interface ViewController ()<MTKViewDelegate>
@property (nonatomic, strong) MTKView *mtkView;

@property (nonatomic, assign) vector_uint2 viewportSize;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) id<MTLTexture> texture;
@property (nonatomic, strong) id<MTLBuffer> vertives;
@property (nonatomic, assign) NSUInteger numVertices;

@property (nonatomic, strong) MetalViewTwo *metalView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.metalView = [[MetalViewTwo alloc] init];
    self.metalView.frame = self.view.bounds;
    self.view = self.metalView;
    
//    [self customInit];
    
}

-(void)customInit{
    MTKView *mtkView = [[MTKView alloc] initWithFrame:self.view.bounds];
    self.mtkView = mtkView;
    mtkView.device = MTLCreateSystemDefaultDevice();
    mtkView.delegate = self;
    self.view = mtkView;
    self.viewportSize = (vector_uint2){mtkView.drawableSize.width,mtkView.drawableSize.height
    };
    [self setupPipeline];
    [self setupVertex];
    [self setupTexure];
}

-(void)setupPipeline{
    
    id<MTLLibrary> defaultLibrary = [self.mtkView.device newDefaultLibrary];
    id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"];
    id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"samplingShader"];
    
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.vertexFunction = vertexFunction;
    pipelineStateDescriptor.fragmentFunction = fragmentFunction;
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = self.mtkView.colorPixelFormat;
    self.pipelineState = [self.mtkView.device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:NULL];
    
    self.commandQueue = [self.mtkView.device newCommandQueue];
}

-(void)setupVertex{
    
    static const LYVertex quadVertices[] = {
        
        { {  0.5, -0.5, 0.0, 1.0 },  { 1.f, 1.f } },
        { { -0.5, -0.5, 0.0, 1.0 },  { 0.f, 1.f } },
        { { -0.5,  0.5, 0.0, 1.0 },  { 0.f, 0.f } },
        
        { {  0.5, -0.5, 0.0, 1.0 },  { 1.f, 1.f } },
        { { -0.5,  0.5, 0.0, 1.0 },  { 0.f, 0.f } },
        { {  0.5,  0.5, 0.0, 1.0 },  { 1.f, 0.f } },
    };
    self.vertives = [self.mtkView.device newBufferWithBytes:quadVertices length:sizeof(quadVertices) options:MTLResourceStorageModeShared];
    self.numVertices = sizeof(quadVertices) / sizeof(LYVertex);
    
}

-(void)setupTexure{
    UIImage *image = [UIImage imageNamed:@"abc"];
    
    MTLTextureDescriptor *textureDescriptor = [[MTLTextureDescriptor alloc] init];
    textureDescriptor.pixelFormat = MTLPixelFormatRGBA8Unorm;
    textureDescriptor.width = image.size.width;
    textureDescriptor.height = image.size.height;
    self.texture = [self.mtkView.device newTextureWithDescriptor:textureDescriptor];
    MTLRegion region = {{0,0,0},{image.size.width,image.size.height,1}};
    Byte *imageBytes = [self loadImage:image];
    if (imageBytes) {
        [self.texture replaceRegion:region mipmapLevel:0 withBytes:imageBytes bytesPerRow:4*image.size.width];
        free(imageBytes);
        imageBytes = NULL;
    }
}

//图片转成二进制数据
-(Byte *)loadImage:(UIImage*)image{
    CGImageRef spriteImage = image.CGImage;
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    Byte *spriteData = (Byte *)calloc(width*height*4, sizeof(Byte));
    CGContextRef spriteContex = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(spriteContex, CGRectMake(0, 0, width, height), spriteImage);
    CGContextRelease(spriteContex);
    return spriteData;
}

-(void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size{
    self.viewportSize = (vector_uint2){
      size.width,
        size.height
    };
}

-(void)drawInMTKView:(MTKView *)view{
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    if (renderPassDescriptor != nil) {
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0.5, 0.5, 1.0);
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        [renderEncoder setViewport:(MTLViewport){0,0,self.viewportSize.x,self.viewportSize.y,-1.0,1.0}];
        [renderEncoder setRenderPipelineState:self.pipelineState];
        [renderEncoder setVertexBuffer:self.vertives offset:0 atIndex:0];
        [renderEncoder setFragmentTexture:self.texture atIndex:0];
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:self.numVertices];
        [renderEncoder endEncoding];
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    [commandBuffer commit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
