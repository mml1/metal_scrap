
//
//  Shaders.metal
//  MetalScrap
//
//  Created by Warren Moore and Mari Lliguicota on 9/24/16.
//  Copyright (c) 2016 Warren Moore and Mari Lliguicota. All rights reserved.
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


vertex FragmentParameters passThroughVertex(uint vid [[ vertex_id ]],
                                            uint instance [[instance_id]],
                                            device InputVertex* vertices  [[ buffer(0) ]],
                                            constant float4x4 * instanceModelMatrices [[ buffer(1)]], 
                                            constant float4x4 &viewProjectionMatrix [[buffer(3)]])
{
    InputVertex vert = vertices[vid];
    
    FragmentParameters out;
    out.position = viewProjectionMatrix * instanceModelMatrices[instance] * float4(float3(vert.position),1);
    out.normal    = float4(float3(vert.normal),0);
    out.texCoords = vert.texCoords;
    
    return out;
};

fragment half4 passThroughFragment(FragmentParameters inFrag [[stage_in]],
                                   texture2d<float, access::sample> tex2d [[texture(0)]])
{
    float3 lightDir = normalize(float3(1,-1,-1));
    float  ambient = 0.2;
    
    float3 normal = normalize(inFrag.normal.xyz);
    float  diffuse = saturate(dot(-lightDir, normal));
    
    float3 cameraDir = normalize(float3(0,0,0) - inFrag.position.xyz);
    
    float3 halfVector = normalize(lightDir+ cameraDir);
    float  specularFactor = 10;
    float  specular = pow((dot(normal, halfVector)),specularFactor);
    
    
    constexpr sampler sampler2d(coord::normalized, filter::linear, mip_filter::linear, address::repeat);

    return half4((ambient + diffuse + specular) * tex2d.sample(sampler2d, inFrag.texCoords));

};
