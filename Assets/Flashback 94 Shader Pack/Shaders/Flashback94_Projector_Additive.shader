
//////////////////////////////////////////////////////////////////////////////////////////
//																						//
// Flashback '94 Shader Pack for Unity 3D												//
// © 2018 George Kokoris          														//
//																						//
// Additive projector shader for casting light on surfaces								//
// '_Snapping' attribute must match the target surface to prevent z-fighting			//
//																						//
//////////////////////////////////////////////////////////////////////////////////////////

Shader "Flashback 94/Projector/Additive (Lights)"
{
	Properties
	{
		_ShadowTex ("Projected Texture", 2D) = "black" {}
		_FalloffTex ("Falloff Texture", 2D) = "white" {}
		_Color ("Tint Color", Color) = (1, 1, 1, 1)
		_Snapping ("Vertex Snapping", Range(1, 100)) = 10
	}

	Subshader
	{
		Tags { "Queue" = "Transparent" }

		Pass
		{
			Blend DstColor One
			ColorMask RGB
			
			ZWrite Off
			Offset -1, -1
			
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog

			#include "Flashback94_ShaderFunctions.cginc"
			
			uniform float4x4 unity_Projector;
			uniform float4x4 unity_ProjectorClip;
			
			sampler2D _ShadowTex;
			float4 _ShadowTex_ST;

			sampler2D _FalloffTex;

			fixed4 _Color;
			half _Snapping;
			
			proj_v2f vert(appdata_full v)
			{
				proj_v2f o;

				float4 viewPos = FB94_ViewPos(v.vertex, _Snapping);
				o.pos = mul(UNITY_MATRIX_P, viewPos);

				o.uvShadow = mul(unity_Projector, v.vertex);
				o.uvShadow.xy = o.uvShadow.xy * _ShadowTex_ST.xy + _ShadowTex_ST.zw;

				o.uvFalloff = mul(unity_ProjectorClip, v.vertex);

				UNITY_TRANSFER_FOG(o, o.pos);

				return o;
			}
			
			fixed4 frag (proj_v2f i) : SV_Target
			{
				if (i.uvShadow.w < 0) discard;

				fixed4 col = tex2D(_ShadowTex, i.uvShadow.xy / i.uvShadow.w);
				fixed lum = Luminance(tex2D(_FalloffTex, i.uvFalloff.xy / i.uvFalloff.w).rgb);
				
				col = fixed4(col.rgb * _Color.rgb * lum, 0);

				UNITY_APPLY_FOG_COLOR(i.fogCoord, col, fixed4(0, 0, 0, 0));

				return col;
			}

			ENDCG
		}
	}
}
