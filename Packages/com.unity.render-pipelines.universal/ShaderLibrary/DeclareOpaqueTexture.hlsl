#ifndef UNITY_DECLARE_OPAQUE_TEXTURE_INCLUDED
#define UNITY_DECLARE_OPAQUE_TEXTURE_INCLUDED
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DynamicScalingClamping.hlsl"

TEXTURE2D_X(_CameraOpaqueTexture);
SAMPLER(sampler_CameraOpaqueTexture);
float4 _CameraOpaqueTexture_TexelSize;

float3 SampleSceneColor(float2 uv)
{
    uv = ClampAndScaleUV(UnityStereoTransformScreenSpaceTex(uv), _CameraOpaqueTexture_TexelSize.xy, _RTHandleScale.xy);
    return SAMPLE_TEXTURE2D_X(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, uv).rgb;
}

float3 LoadSceneColor(uint2 uv)
{
    return LOAD_TEXTURE2D_X(_CameraOpaqueTexture, uv).rgb;
}
#endif
