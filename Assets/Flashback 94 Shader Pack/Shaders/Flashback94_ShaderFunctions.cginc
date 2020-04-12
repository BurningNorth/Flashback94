
//////////////////////////////////////////////////////////////////////////////////////////
//																						//
// Flashback '94 Shader Pack for Unity 3D												//
// © 2018 George Kokoris          														//
//																						//
// CG includes for all Flashback '94 object and projector shaders						//
//																						//
//////////////////////////////////////////////////////////////////////////////////////////

#include "UnityCG.cginc"

#define VERTEX_RESOLUTION 2500
#define FOV_FACTOR 75

#define LIGHT_COUNT 8
#define ATTENUATION_OFFSET 0.0333
#define SPECULAR_POWER 128
#define LIGHTMAP_POWER 0.5

#define RIMLIGHT_MAGNITUDE 0.25
#define RIMLIGHT_DEPTHOFFSET -0.01

struct fb94_v2f
{
	float4 pos : SV_POSITION;
	float3 uv : TEXCOORD0;
	float3 lm : TEXCOORD1;
	float3 ref : TEXCOORD2;
	fixed3 spec : TEXCOORD3;
	fixed3 diff : COLOR;

	UNITY_FOG_COORDS(4)
};

struct proj_v2f
{
	float4 pos : SV_POSITION;
	float4 uvShadow : TEXCOORD0;
	float4 uvFalloff : TEXCOORD1;

	UNITY_FOG_COORDS(2)
};

float4 FB94_ViewPos(float4 vert, half snapping)
{
	half fov = atan(1 / unity_CameraProjection[1].y) * (360 / UNITY_PI);
	half dist = distance(_WorldSpaceCameraPos, mul(unity_ObjectToWorld, vert));

	half stepValue = (snapping / VERTEX_RESOLUTION) * (fov / FOV_FACTOR) * dist;

	float4 viewPos = mul(UNITY_MATRIX_MV, vert);
	viewPos.xyz = floor(viewPos.xyz / stepValue + 0.5) * stepValue;

	return viewPos;
}

fb94_v2f FB94_NewStruct(float4 viewPos)
{
	fb94_v2f o;

	o.pos = mul(UNITY_MATRIX_P, viewPos);
	o.uv = float3(0, 0, 0);
	o.lm = float3(0, 0, 0);
	o.ref = float3(0, 0, 0);
	o.spec = fixed3(0, 0, 0);
	o.diff = fixed3(1, 1, 1);

	return o;
}

float3 FB94_AffineUV(float4 coord, float4 st, float4 pos)
{
	#ifdef AFFINE_TEXTURE
		return float3((coord.xy * st.xy + st.zw) * pos.w, pos.w);
	#else
		return float3((coord.xy * st.xy + st.zw), 1);
	#endif
}

fb94_v2f FB94_VertUnlit(fb94_v2f o)
{
	UNITY_TRANSFER_FOG(o, o.pos);
	return o;
}

fb94_v2f FB94_VertSpecular(appdata_full v, fb94_v2f o, float4 viewPos, fixed4 specColor, half shine)
{
	o.diff = UNITY_LIGHTMODEL_AMBIENT.rgb;

	float3 viewDirObj = normalize(ObjSpaceViewDir(v.vertex));

	for (int i = 0; i < LIGHT_COUNT; ++i)
	{
		// Default to directional light
		float3 toLight = unity_LightPosition[i].xyz - viewPos.xyz * unity_LightPosition[i].w;
		float atten = 1;

		// Modify attenuation if point or spot light
		if (unity_LightPosition[i].w == 1)
		{
			float lengthSq = dot(toLight, toLight);
			toLight *= rsqrt(lengthSq);

			atten = 1 / (1 + lengthSq * unity_LightAtten[i].z);

			float rho = max(0, dot(toLight, unity_SpotDirection[i].xyz));
			float spotAtten = (rho - unity_LightAtten[i].x) * unity_LightAtten[i].y;

			atten = max(0, atten * saturate(spotAtten) - ATTENUATION_OFFSET);
		}

		float3 lightDirObj = mul((float3x3)UNITY_MATRIX_T_MV, toLight);

		// Calculate diffuse light
		float diff = max(0, dot(v.normal, lightDirObj));
		o.diff += unity_LightColor[i].rgb * diff * atten;

		if (shine > 0)
		{
			// Calculate specular reflection
			float3 h = normalize(viewDirObj + lightDirObj);
			float nh = max(0, dot(v.normal, h));
			float spec = pow(nh, shine * SPECULAR_POWER);
			o.spec += unity_LightColor[i].rgb * spec * atten;
		}
	}

	o.spec *= specColor.rgb * shine * 2;

	return FB94_VertUnlit(o);
}

fb94_v2f FB94_VertDiffuse(appdata_full v, fb94_v2f o, float4 viewPos)
{
	return FB94_VertSpecular(v, o, viewPos, 0, 0);
}

fixed4 FB94_GetRGBA(fb94_v2f i, sampler2D mainTex, fixed4 diffColor, fixed4 emissive)
{
	// Undo perspective correction
	fixed4 col = tex2D(mainTex, i.uv.xy / i.uv.z);

	col *= fixed4(i.diff, 1) * diffColor;
	col += fixed4(i.spec + emissive.rgb, 0);

	UNITY_APPLY_FOG(i.fogCoord, col);

	return col;
}

fixed4 FB94_FragOpaque(fb94_v2f i, sampler2D mainTex, fixed4 diffColor, fixed4 emissive)
{
	return fixed4(FB94_GetRGBA(i, mainTex, diffColor, emissive).rgb, 1);
}

fixed4 FB94_FragAlpha(fb94_v2f i, sampler2D mainTex, fixed4 diffColor, fixed4 emissive)
{
	return FB94_GetRGBA(i, mainTex, diffColor, emissive);
}
