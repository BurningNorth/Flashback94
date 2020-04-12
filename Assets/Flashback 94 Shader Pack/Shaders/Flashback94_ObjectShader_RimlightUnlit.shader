
//////////////////////////////////////////////////////////////////////////////////////////
//																						//
// Flashback '94 Shader Pack for Unity 3D												//
// © 2018 George Kokoris          														//
//																						//
// Shader for opaque objects with no lighting and a rim light effect					//
//																						//
//////////////////////////////////////////////////////////////////////////////////////////

Shader "Flashback 94/Object Shader/Rimlight Unlit"
{
	Properties
	{
		_MainTex ("Main Texture (RGB)", 2D) = "white" {}
		_DiffColor ("Diffuse Color", Color) = (1, 1, 1, 1)
		_Emissive ("Emissive Color", Color) = (0, 0, 0, 0)
		_RimColor ("Rimlight Color", Color) = (1, 0.75, 0.5, 1)
		_RimScale ("Rimlight Scale", Range (0, 1)) = 0
		_RimOffsetX ("Rimlight Offset X", Range (-1, 1)) = -0.1
		_RimOffsetY ("Rimlight Offset Y", Range (-1, 1)) = 0.1
		_Snapping ("Vertex Snapping", Range (1, 100)) = 10

		[Toggle(AFFINE_TEXTURE)]
		_AffineTexture ("Affine Texture", Float) = 1
	}

	SubShader
	{
		Tags { "Queue" = "Geometry" "RenderType" = "Opaque" }

		ZWrite On

		UsePass "Flashback 94/Object Shader/Opaque Unlit/UNLIT"

		Pass
		{
			Name "RIMLIGHT"

			Tags { "LightMode" = "Always" }

			Cull Front

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog

			#pragma shader_feature AFFINE_TEXTURE

			#include "Flashback94_ShaderFunctions.cginc"

			fixed4 _DiffColor;
			fixed4 _RimColor;
			half _RimScale;
			half _RimOffsetX;
			half _RimOffsetY;
			half _Snapping;

			sampler2D _MainTex;
			float4 _MainTex_ST;

			fb94_v2f vert(appdata_full v)
			{
				// Scale vertex before projection
				v.vertex.xyz += v.normal * RIMLIGHT_MAGNITUDE * _RimScale;

				// Snap vertex position based on snapping amount
				float4 viewPos = FB94_ViewPos(v.vertex, _Snapping);
				fb94_v2f o = FB94_NewStruct(viewPos);

				// Offset vertex
			    o.pos.x += RIMLIGHT_MAGNITUDE * _RimOffsetX;
			    o.pos.y += RIMLIGHT_MAGNITUDE * _RimOffsetY;
			    o.pos.z += RIMLIGHT_DEPTHOFFSET;

			    // Save position to texture coordinate to undo perspective correction
			    o.uv = FB94_AffineUV(v.texcoord, _MainTex_ST, o.pos);

			    // Calculate vertex lighting
			    return FB94_VertUnlit(o);
			}
			
			fixed4 frag(fb94_v2f i) : SV_Target
			{
				return FB94_FragOpaque(i, _MainTex, _DiffColor, _RimColor);
			}

			ENDCG
		}
	}
}
