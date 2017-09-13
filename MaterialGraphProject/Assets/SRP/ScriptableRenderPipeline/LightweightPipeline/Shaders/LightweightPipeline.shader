// Shader targeted for low end devices. Single Pass Forward Rendering. Shader Model 2
Shader "ScriptableRenderPipeline/LightweightPipeline/NonPBR"
{
    // Keep properties of StandardSpecular shader for upgrade reasons.
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("Base (RGB) Glossiness / Alpha (A)", 2D) = "white" {}

        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

        _Shininess("Shininess", Range(0.01, 1.0)) = 1.0
        _GlossMapScale("Smoothness Factor", Range(0.0, 1.0)) = 1.0

        _Glossiness("Glossiness", Range(0.0, 1.0)) = 0.5
        [Enum(Specular Alpha,0,Albedo Alpha,1)] _SmoothnessTextureChannel("Smoothness texture channel", Float) = 0

        _Cube ("Reflection Cubemap", CUBE) = "" {}
        _ReflectionSource("Reflection Source", Float) = 0

        [HideInInspector] _SpecSource("Specular Color Source", Float) = 0.0
        _SpecColor("Specular", Color) = (1.0, 1.0, 1.0)
        _SpecGlossMap("Specular", 2D) = "white" {}
        [HideInInspector] _GlossinessSource("Glossiness Source", Float) = 0.0
        [ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
        [ToggleOff] _GlossyReflections("Glossy Reflections", Float) = 1.0

        [HideInInspector] _BumpScale("Scale", Float) = 1.0
        [NoScaleOffset] _BumpMap("Normal Map", 2D) = "bump" {}

        _Parallax("Height Scale", Range(0.005, 0.08)) = 0.02
        _ParallaxMap("Height Map", 2D) = "black" {}

        _EmissionColor("Emission Color", Color) = (0,0,0)
        _EmissionMap("Emission", 2D) = "white" {}

        _DetailMask("Detail Mask", 2D) = "white" {}

        _DetailAlbedoMap("Detail Albedo x2", 2D) = "grey" {}
        _DetailNormalMapScale("Scale", Float) = 1.0
        _DetailNormalMap("Normal Map", 2D) = "bump" {}

        [Enum(UV0,0,UV1,1)] _UVSec("UV Set for secondary textures", Float) = 0

            // Blending state
            [HideInInspector] _Mode("__mode", Float) = 0.0
            [HideInInspector] _SrcBlend("__src", Float) = 1.0
            [HideInInspector] _DstBlend("__dst", Float) = 0.0
            [HideInInspector] _ZWrite("__zw", Float) = 1.0
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "LightweightPipeline" }
        LOD 300

        Pass
        {
            Tags { "LightMode" = "LightweightForward" }

            // Use same blending / depth states as Standard shader
            Blend[_SrcBlend][_DstBlend]
            ZWrite[_ZWrite]

            CGPROGRAM
            #pragma target 3.0
            
            #pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON
            #pragma shader_feature _ _SPECGLOSSMAP _SPECGLOSSMAP_BASE_ALPHA _SPECULAR_COLOR
            #pragma shader_feature _NORMALMAP
            #pragma shader_feature _EMISSION
            #pragma shader_feature _ _REFLECTION_CUBEMAP _REFLECTION_PROBE

            #pragma multi_compile _ LIGHTWEIGHT_LINEAR
            #pragma multi_compile _ UNITY_SINGLE_PASS_STEREO STEREO_INSTANCING_ON STEREO_MULTIVIEW_ON
            #pragma multi_compile _ _SINGLE_DIRECTIONAL_LIGHT _SINGLE_SPOT_LIGHT _SINGLE_POINT_LIGHT
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ _LIGHT_PROBES_ON
            #pragma multi_compile _ _HARD_SHADOWS _SOFT_SHADOWS _HARD_SHADOWS_CASCADES _SOFT_SHADOWS_CASCADES
            #pragma multi_compile _ _VERTEX_LIGHTS
            #pragma multi_compile _ _ATTENUATION_TEXTURE
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"
            #include "UnityStandardInput.cginc"
            #include "LightweightPipelineCore.cginc"
            //#include "LightweightPipelineLighting.cginc"    

			#pragma vertex LightweightVertex
            #pragma fragment LightweightFragmentLegacy

            ENDCG
        }

        Pass
        {
            Tags { "Lightmode" = "ShadowCaster" }
            ZWrite On ZTest LEqual

            CGPROGRAM
            #pragma target 2.0
            #include "UnityCG.cginc"
			#include "LightweightPipelinePass.cginc"
            #pragma vertex shadowVert
            #pragma fragment shadowFrag
            ENDCG
        }

        Pass
        {
            Tags{"Lightmode" = "DepthOnly"}
            ZWrite On

            CGPROGRAM
            #pragma target 2.0
			#include "LightweightPipelinePass.cginc"
            #pragma vertex depthVert
            #pragma fragment depthFrag
            ENDCG
        }

        // This pass it not used during regular rendering, only for lightmap baking.
        Pass
        {
            Tags{ "LightMode" = "Meta" }

            Cull Off

            CGPROGRAM
            #define UNITY_SETUP_BRDF_INPUT SpecularSetup

			#pragma shader_feature _EMISSION
            #pragma shader_feature _SPECGLOSSMAP
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature ___ _DETAIL_MULX2
            #pragma shader_feature EDITOR_VISUALIZATION
			
			#include "UnityCG.cginc"
			#include "LightweightPipelinePass.cginc"
            #pragma vertex vert_meta
            #pragma fragment frag_meta_ld            
            ENDCG
        }
    }
    Fallback "Standard (Specular setup)"
    CustomEditor "LightweightPipelineMaterialEditor"
}
