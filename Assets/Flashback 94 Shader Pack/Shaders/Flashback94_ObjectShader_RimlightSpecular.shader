
//////////////////////////////////////////////////////////////////////////////////////////
//																						//
// Flashback '94 Shader Pack for Unity 3D												//
// © 2018 George Kokoris          														//
//																						//
// Shader for opaque objects with specular lighting and a rim light effect				//
//																						//
//////////////////////////////////////////////////////////////////////////////////////////

Shader "Flashback 94/Object Shader/Rimlight Specular"
{
	Properties
	{
		_MainTex ("Main Texture (RGB)", 2D) = "white" {}
		_DiffColor ("Diffuse Color", Color) = (1, 1, 1, 1)
		_Emissive ("Emissive Color", Color) = (0, 0, 0, 0)
		_SpecColor ("Specular Color", Color) = (1, 1, 1, 1)
		_Shininess ("Shininess", Range (0.1, 1)) = 0.75
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

		UsePass "Flashback 94/Object Shader/Opaque Specular/SPECULAR"

		UsePass "Flashback 94/Object Shader/Opaque Diffuse/LIGHTMAP_RGBM"
		UsePass "Flashback 94/Object Shader/Opaque Diffuse/LIGHTMAP_DLDR"

		UsePass "Flashback 94/Object Shader/Rimlight Unlit/RIMLIGHT"
	}
}
