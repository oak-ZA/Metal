//
//  ZAShaders.metal
//  Metal
//
//  Created by 张奥 on 2019/11/11.
//  Copyright © 2019 张奥. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex{
    //顶点
    float4 position [[position]];
    //颜色
    float4 color;
};
/*****
 
 第一个关键字是function qualifier(函数限定符)，只能具有vertex(顶点)，fragment(片段)或kernel(内核)的值。 下一个关键字是return type(返回类型)。 接下来是function name(函数名称)，后面是括号内的function arguments(函数参数)。 Metal shading language（Metal着色语言）限制指针的使用，除非参数是用device(设备)，threadgroup(线程组)或constant(常量)地址空间限定符声明的，该设备，线程组或常量地址空间限定符指定分配函数变量或参数的内存区域。[[...]]语法用于声明属性，如资源位置，着色器输入以及在着色器和CPU之间来回传递的内置变量。
 
 vertex shader(顶点着色器)将指向顶点列表的指针作为第一个参数。 我们可以使用由vertex_id归属的第二参数vid来索引vertices(顶点)，告诉Metal将当前正在处理的顶点索引作为此参数插入。 然后，我们简单地传递每个顶点（以及它的位置和颜色）以供fragment shader(片段着色器)消耗。 所有fragment shader(片段着色器)的作用是从顶点着色器传递顶点，并通过每个像素的颜色，而不改变任何输入数据。 vertex shader(顶点着色器)很少运行（在这种情况下只有3次 - 对于每个顶点），而fragment shader(片段着色器)运行数千次 - 对于需要绘制的每个像素。
 
 所以你可能还在问：“好的，但是颜色渐变怎么样”？ 那么，现在你已经理解了每个着色器的功能以及它们运行的频率，你可以将任何给定像素处的颜色视为其邻居的average(平均)颜色值。 例如，红色和绿色像素之间的中间颜色将是黄色的，因为片段着色器通过对它们进行平均来插值两种颜色：0.5 *红色+ 0.5 *绿色。 红色和蓝色产生的洋红色之间的中间颜色，以及蓝色和绿色之间的中途产生的青色也会发生同样的情况。 从这里开始，剩下的像素将被插入不同的原色，从而产生您所看到的梯度范围。
 
 *******/
vertex Vertex vertex_func(constant Vertex *vertices[[buffer(0)]], uint vid [[vertex_id]]){
    return vertices[vid];
}

fragment float4 fragment_func(Vertex vert [[stage_in]]){
    return vert.color;
}

