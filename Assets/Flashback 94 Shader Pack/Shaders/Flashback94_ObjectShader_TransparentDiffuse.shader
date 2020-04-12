
//////////////////////////////////////////////////////////////////////////////////////////
//																						//
// Flashback '94 Shader Pack for Unity 3D												//
// © 2018 George Kokoris          														//
//																						//
// Shader for transparent objects with diffuse lighting									//
//																						//
//////////////////////////////////////////////////////////////////////////////////////////

Shader "Flashback 94/Object Shader/Transparent Diffuse"
{
	Properties
	{
		_MainTex ("Main Texture (RGB) Alpha (A)", 2D) = "white" {}
		_DiffColor ("Diffuse Color", Color) = (1, 1, 1, 1)
		_Emissive ("Emissive Color", Color) = (0, 0, 0, 0)
		_Snapping ("Vertex Snapping", Range (1, 100)) = 10

		[Toggle(AFFINE_TEXTURE)]
		_AffineTexture ("Affine Texture", Float) = 1
	}

	SubShader
	{
		Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }

		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask RGB

		Pass
		{
			Tags { "LightMode" = "Vertex" }

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog

			#pragma shader_feature AFFINE_TEXTURE

			#include "Flashback94_ShaderFunctions.cginc"

			fixed4 _DiffColor;
			fixed4 _Emissive;
			half _Snapping;

			sampler2D _MainTex;
			float4 _MainTex_ST;

			fb94_v2f vert(appdata_full v)
			{
				// Snap vertex position based on snapping amount
				float4 viewPos = FB94_ViewPos(v.vertex, _Snapping);
				fb94_v2f o = FB94_NewStruct(viewPos);

			    // Save position to texture coordinate to undo perspective correction
			    o.uv = FB94_AffineUV(v.texcoord, _MainTex_ST, o.pos);

			    // Calculate vertex lighting
			    return FB94_VertDiffuse(v, o, viewPos);
			}
			
			fixed4 frag(fb94_v2f i) : SV_Target
			{
				return FB94_FragAlpha(i, _MainTex, _DiffColor, _Emissive);
			}

			ENDCG
		}

		Pass
		{
			Name "LIGHTMAP_RGBM"

			Tags { "LightMode" = "VertexLMRGBM" }

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog

			#pragma shader_feature AFFINE_TEXTURE

			#include "Flashback94_ShaderFunctions.cginc"

			fixed4 _DiffColor;
			fixed4 _Emissive;
			half _Snapping;

			sampler2D _MainTex;
			float4 _MainTex_ST;

			fb94_v2f vert(appdata_full v)
			{
				// Snap vertex position based on snapping amount
				float4 viewPos = FB94_ViewPos(v.vertex, _Snapping);
				fb94_v2f o = FB94_NewStruct(viewPos);

			    // Save position to texture coordinate to undo perspective correction
			    o.uv = FB94_AffineUV(v.texcoord, _MainTex_ST, o.pos);
			    o.lm = FB94_AffineUV(v.texcoord1, unity_LightmapST, o.pos);

			    // Calculate vertex lighting
			    return FB94_VertUnlit(o);
			}
			
			fixed4 frag(fb94_v2f i) : SV_Target
			{
				// Get diffuse lighting from lightmap
				i.diff = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lm.xy / i.lm.z)) * LIGHTMAP_POWER;

				return FB94_FragAlpha(i, _MainTex, _DiffColor, _Emissive);
			}

			ENDCG
		}

		Pass
		{
			Name "LIGHTMAP_DLDR"

			Tags { "LightMode" = "VertexLM" }

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog

			#pragma shader_feature AFFINE_TEXTURE

			#include "Flashback94_ShaderFunctions.cginc"

			fixed4 _DiffColor;
			fixed4 _Emissive;
			half _Snapping;

			sampler2D _MainTex;
			float4 _MainTex_ST;

			fb94_v2f vert(appdata_full v)
			{
				// Snap vertex position based on snapping amount
				float4 viewPos = FB94_ViewPos(v.vertex, _Snapping);
				fb94_v2f o = FB94_NewStruct(viewPos);

			    // Save position to texture coordinate to undo perspective correction
			    o.uv = FB94_AffineUV(v.texcoord, _MainTex_ST, o.pos);
			    o.lm = FB94_AffineUV(v.texcoord1, unity_LightmapST, o.pos);

			    // Calculate vertex lighting
			    return FB94_VertUnlit(o);
			}
			
			fixed4 frag(fb94_v2f i) : SV_Target
			{
				// Get diffuse lighting from lightmap
				i.diff = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lm.xy / i.lm.z)) * LIGHTMAP_POWER;

				return FB94_FragAlpha(i, _MainTex, _DiffColor, _Emissive);
			}

			ENDCG
		}
	}
}
