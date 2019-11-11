//
//  MetalViewTwo.m
//  Metal
//
//  Created by 张奥 on 2019/11/11.
//  Copyright © 2019 张奥. All rights reserved.
//

#import "MetalViewTwo.h"
@interface MetalViewTwo()
@property (nonatomic, strong) id<MTLCommandQueue>commandQueue;
@property (nonatomic, strong) id <MTLRenderPipelineState> pipelineState;
@property (nonatomic, strong) id<MTLBuffer> vertices;
@end

typedef struct {
    
    vector_float4 position;
    vector_float4 color;
    
}ZAVertexTwo;

@implementation MetalViewTwo

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)init{
    self = [super init];
    if (self) {

        [self render];
        
    }
    return self;
}

-(void)render{
    
    //获取GPU设备(真机)
    self.device = MTLCreateSystemDefaultDevice();
    //渲染指令队列,保证渲染指令有序的提交到GPU
    self.commandQueue = [self.device newCommandQueue];
    
    [self createBuffer];
    [self registerShaders];
    
    
}

-(void)createBuffer{
    //顶点
    static const ZAVertexTwo triangleVertices[] =
    {
        { .position = { -1.0, -1.0, 0.0, 1.0},.color = {1,0,0,1}},
        { .position = { 1.0,-1.0, 0.0, 1.0}, .color = {0,1,0,1}},
        { .position = { 0.0, 1.0, 0.0, 1.0 }, .color = {0,0,1,1}},
    };
    //设置缓存
    self.vertices = [self.device newBufferWithBytes:triangleVertices length:sizeof(triangleVertices)*3 options:MTLResourceStorageModeShared];
}
-(void)registerShaders{
    //metal文件
    id <MTLLibrary> library = [self.device newDefaultLibrary];
    //metal文件里的C++函数 vertex_func是函数名, 顶点着色器shader
    id <MTLFunction> vertexFunction = [library newFunctionWithName:@"vertex_func"];
    //fragment_func是函数名, 片元着色器shader
    id <MTLFunction> fragmentFunction = [library newFunctionWithName:@"fragment_func"];
    //轨道
    MTLRenderPipelineDescriptor *piplelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    piplelineDescriptor.vertexFunction = vertexFunction;
    piplelineDescriptor.fragmentFunction = fragmentFunction;
    piplelineDescriptor.colorAttachments[0].pixelFormat = self.colorPixelFormat;
    self.pipelineState = [self.device newRenderPipelineStateWithDescriptor:piplelineDescriptor error:nil];
}

-(void)sendToGPU{
    id <CAMetalDrawable> currentDrawable =  self.currentDrawable;
    
    MTLRenderPassDescriptor *currentRenderPassDescriptor = self.currentRenderPassDescriptor;
    currentRenderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0.5, 0.5, 1.0);
    //    currentRenderPassDescriptor.colorAttachments[0].loadAction = 2;
    
    id <MTLCommandBuffer> commandBuffer = self.commandQueue.commandBuffer;
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:currentRenderPassDescriptor];
    [renderEncoder setRenderPipelineState:self.pipelineState];
    [renderEncoder setVertexBuffer:self.vertices offset:0 atIndex:0];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3 instanceCount:1];
    [renderEncoder endEncoding];
    [commandBuffer presentDrawable:currentDrawable];
    [commandBuffer commit];
}
-(void)drawRect:(CGRect)rect{
    
    [self sendToGPU];
}



@end
