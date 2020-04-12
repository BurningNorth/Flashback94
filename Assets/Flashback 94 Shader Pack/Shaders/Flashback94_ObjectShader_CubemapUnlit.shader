
//////////////////////////////////////////////////////////////////////////////////////////
//																						//
// Flashback '94 Shader Pack for Unity 3D												//
// © 2018 George Kokoris          														//
//																						//
// Shader for cubemapped objects with no lighting										//
//																						//
//////////////////////////////////////////////////////////////////////////////////////////

Shader "Flashback 94/Object Shader/Cubemap Unlit"
{
	Properties
	{
		_MainTex ("Main Texture (RGB)", 2D) = "white" {}
		_DiffColor ("Diffuse Color", Color) = (1, 1, 1, 1)
		_Emissive ("Emissive Color", Color) = (0, 0, 0, 0)
		_Cube ("Reflection Map", Cube) = "" {}
		_Reflect ("Reflection Strength", Range (0, 1)) = 0.25
		_Snapping ("Vertex Snapping", Range (1, 100)) = 10

		[Toggle(AFFINE_TEXTURE)]
		_AffineTexture ("Affine Texture", Float) = 1
	}

	SubShader
	{
		Tags { "Queue" = "Geometry" "RenderType" = "Opaque" }

		ZWrite On

		Pass
		{
			Tags { "LightMode" = "Always" }

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog

			#pragma shader_feature AFFINE_TEXTURE

			#include "Flashback94_ShaderFunctions.cginc"

			fixed4 _DiffColor;
			fixed4 _Emissive;
			half _Reflect;
			half _Snapping;

			sampler2D _MainTex;
			float4 _MainTex_ST;

			samplerCUBE _Cube;

			fb94_v2f vert(appdata_full v)
			{
				// Snap vertex position based on snapping amount
				float4 viewPos = FB94_ViewPos(v.vertex, _Snapping);
				fb94_v2f o = FB94_NewStruct(viewPos);

			    // Save position to texture coordinate to undo perspective correction
			    o.uv = FB94_AffineUV(v.texcoord, _MainTex_ST, o.pos);

			    // Calculate reflection vector for cubemap
			    float3 view = mul((float3x3)unity_ObjectToWorld, v.vertex.xyz) - _WorldSpaceCameraPos;
			    float3 norm = mul(v.normal, (float3x3)unity_WorldToObject);
			    o.ref = reflect(view, norm);

			    // Calculate vertex lighting
			    return FB94_VertUnlit(o);
			}
			
			fixed4 frag(fb94_v2f i) : SV_Target
			{
				fixed4 c = FB94_FragOpaque(i, _MainTex, _DiffColor, _Emissive);

				c.rgb += texCUBE(_Cube, i.ref).rgb * _Reflect;

				return c;
			}

			ENDCG
		}
	}
}
