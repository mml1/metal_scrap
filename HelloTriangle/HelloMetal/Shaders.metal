//
//  Shaders.metal
//  HelloMetal
//
//  Created by Warren Moore on 9/24/16.
//  Copyright (c) 2016 Warren Moore. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

struct FragmentParameters
{
    float4  position [[position]];
    float4  normal;
    float2  texCoords;
};

struct InputVertex
{
    packed_float3 position;
    packed_float3 normal;
    packed_float2 texCoords;
};

//vertex FragmentParameters passThroughVertex(uint vid [[ vertex_id ]],
//                                            constant float4* position  [[ buffer(0) ]],
//                                            constant float4* color    [[ buffer(1) ]],
//                                            constant float4x4 &modelMatrix [[buffer(3)]],
//                                            constant packed_float2* texCoords [[buffer(2)]])
vertex FragmentParameters passThroughVertex(uint vid [[ vertex_id ]],
                                            constant InputVertex* vertices  [[ buffer(0) ]],
                                            constant float4x4 &modelMatrix [[buffer(3)]])
{
    InputVertex vert = vertices[vid]; // fetching all of the vertex properties with this call
    
    FragmentParameters out;
    //passing into fragment buffer
    out.position = modelMatrix * float4(float3(vert.position),1); // adds the w
    out.normal    = float4(float3(vert.normal),0);
    out.texCoords = vert.texCoords;
    
    return out;
};

fragment half4 passThroughFragment(FragmentParameters inFrag [[stage_in]],
                                   texture2d<float, access::sample> tex2d [[texture(0)]])
{
    float3 lightDir = normalize(float3(1,-1,-1)); // from right and above light
    float ambient = 0.2;
    
    float3 normal = normalize(inFrag.normal.xyz);
    float diffuse = saturate(dot(-lightDir, normal)); // diffused intensity
    

    constexpr sampler sampler2d(coord::normalized, filter::linear, mip_filter::linear, address::repeat);
    return half4( (ambient + diffuse)* tex2d.sample(sampler2d, inFrag.texCoords));
    
//    return half4(tex2d.sample(sampler2d, inFrag.texCoords));
    //sample fxn if I look up at that coordinate what value do i get, return as float4 cast to half4 due to obligations
//    return half4(inFrag.color);
};
