
//////////////////////////////////////////////////////////////////////////////////////////
//																						//
// Flashback '94 Shader Pack for Unity 3D												//
// © 2018 George Kokoris          														//
//																						//
// Multiplicative projector shader for casting shadows on surfaces						//
// '_Snapping' attribute must match the target surface to prevent z-fighting			//
//																						//
//////////////////////////////////////////////////////////////////////////////////////////

Shader "Flashback 94/Projector/Multiply (Shadows)"
{
	Properties
	{
		_ShadowTex ("Projected Texture", 2D) = "white" {}
		_FalloffTex ("Falloff Texture", 2D) = "white" {}
		_Snapping ("Vertex Snapping", Range(1, 100)) = 10
	}

	Subshader
	{
		Tags { "Queue" = "Transparent" }

		Pass
		{
			Blend DstColor Zero
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
				
				col = lerp(fixed4(1, 1, 1, 1), fixed4(col.rgb, 1), lum);

				UNITY_APPLY_FOG_COLOR(i.fogCoord, col, fixed4(1, 1, 1, 1));

				return col;
			}

			ENDCG
		}
	}
}
