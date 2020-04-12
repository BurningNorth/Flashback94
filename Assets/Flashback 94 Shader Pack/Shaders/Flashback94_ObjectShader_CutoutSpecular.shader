
//////////////////////////////////////////////////////////////////////////////////////////
//																						//
// Flashback '94 Shader Pack for Unity 3D												//
// © 2018 George Kokoris          														//
//																						//
// Shader for cutout objects with specular lighting										//
//																						//
//////////////////////////////////////////////////////////////////////////////////////////

Shader "Flashback 94/Object Shader/Cutout Specular"
{
	Properties
	{
		_MainTex ("Main Texture (RGB) Alpha (A)", 2D) = "white" {}
		_DiffColor ("Diffuse Color", Color) = (1, 1, 1, 1)
		_Emissive ("Emissive Color", Color) = (0, 0, 0, 0)
		_SpecColor ("Specular Color", Color) = (1, 1, 1, 1)
		_Shininess ("Shininess", Range (0.1, 1)) = 0.75
		_Cutoff ("Alpha Cutoff", Range (0, 1)) = 0.5
		_Snapping ("Vertex Snapping", Range (1, 100)) = 10

		[Toggle(AFFINE_TEXTURE)]
		_AffineTexture ("Affine Texture", Float) = 1
	}

	SubShader
	{
		Tags { "Queue" = "AlphaTest" "RenderType" = "TransparentCutout" }

		ZWrite On
		Cull Off

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
			fixed4 _SpecColor;
			half _Shininess;
			half _Cutoff;
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

				// Flip normals on back faces
				float3 normalDirection = mul(float4(v.normal, 0), unity_WorldToObject).xyz;
				float3 viewDirection = _WorldSpaceCameraPos - mul(unity_ObjectToWorld, v.vertex).xyz;
				if (dot(normalDirection, viewDirection) < 0) v.normal *= -1;

			    // Calculate vertex lighting
			    return FB94_VertSpecular(v, o, viewPos, _SpecColor, _Shininess);
			}
			
			fixed4 frag(fb94_v2f i) : SV_Target
			{
				fixed4 c = FB94_FragAlpha(i, _MainTex, _DiffColor, _Emissive);

				if (c.a < _Cutoff) discard;

				return fixed4(c.rgb, 1);
			}

			ENDCG
		}

		UsePass "Flashback 94/Object Shader/Cutout Diffuse/LIGHTMAP_RGBM"
		UsePass "Flashback 94/Object Shader/Cutout Diffuse/LIGHTMAP_DLDR"
	}
}
