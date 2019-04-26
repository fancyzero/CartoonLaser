// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/LaserBeam"
{
	Properties
	{
		_psize("particle size", Float) = 0.02
		_offsetScale("offset scale", Float) = 1

		_MainTex("Texture", 2D) = "white" {}
		_Gray("Texture", 2D) = "white" {}
	}
		SubShader
	{
		Tags{ "RenderType" = "Transparent" }
		LOD 100
		CULL OFF
		blend one one
		Pass
		{

		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
		// make fog work
#pragma multi_compile_fog

#include "UnityCG.cginc"

		struct appdata
		{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
		float2 uv2 : TEXCOORD1;
		float2 uv3 : TEXCOORD2;



	};

	struct v2f
	{
		float2 uv : TEXCOORD0;
		float4 vertex : SV_POSITION;
		float2 localPos:TEXCOORD1;
		float4 an:TEXCOORD2;

	};

	sampler2D _MainTex;
	sampler2D _Gray;
	
	float4 _MainTex_ST;
	float _psize;
	float _offsetScale;


	v2f vert(appdata v)
	{
		v2f o;
		float2 p = float2(0, 1 / 128.0);
		float2 posOffset0 = float3(tex2Dlod(_MainTex, float4(v.uv - p, 0, 0)).rg, 0);
		float2 posOffset1 = float3(tex2Dlod(_MainTex, float4(v.uv, 0, 0)).rg, 0);
		float2 posOffset2 = float3(tex2Dlod(_MainTex, float4(v.uv + p, 0, 0)).rg,0);
		float2 dirback = normalize(posOffset0 - posOffset1);
		float2 dirfwd = normalize(posOffset1 - posOffset2);

		dirback = float2(-dirback.y, dirback.x);
		dirfwd = float2(-dirfwd.y, dirfwd.x);
		float2 extent = normalize(dirback + dirfwd);
		o.vertex = UnityObjectToClipPos( float3(-1 * v.uv2.x*extent*_psize + (posOffset1 * _offsetScale), 0));//+ 
		o.uv = TRANSFORM_TEX(v.uv, _MainTex);

		float2 posOffsetA = float3(tex2Dlod(_MainTex, float4(v.uv3 + p, 0, 0)).rg, 0);
		float2 posOffsetB = float3(tex2Dlod(_MainTex, float4(v.uv3, 0, 0)).rg, 0);

		o.localPos =  v.vertex + float3(-1 * v.uv2.x*extent*_psize + (posOffset1 * _offsetScale), 0).xy;
		o.an.xy = posOffsetB;
		o.an.zw = normalize(posOffsetA - posOffsetB);
		return o;
	}
	float distanceToLine(float2 a, float2 n, float2 p)
	{
		return length(a - p - dot(a - p, n)*n);
	}
	fixed4 frag(v2f i) : SV_Target
	{
		float d = distanceToLine(i.an.xy, i.an.zw, i.localPos);
		d = saturate(1 - d / _psize);
		//return  float4(d,d,d,1);
		float g= tex2D(_Gray,i.uv).x;
		float r = d - g;
		return float4(r,r,r,1);
	}
		ENDCG
	}
	}
}
