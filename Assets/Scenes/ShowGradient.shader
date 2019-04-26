Shader "Unlit/ShowGradient"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

			float2 gradient(float2 uv)
			{

				float2 puv = uv - 0.5;
				//float x = puv.x;
				//float y = puv.y;
				//float2 dir = float2(x*x-y*y,2*x*y);
				//return (float2(-puv.y,puv.x));
				float2 xx = float2(1, 0) / 128.0;
				float2 yy = float2(0, 1) / 128.0;
				float v = tex2D(_MainTex, uv);
				float vx = tex2D(_MainTex, uv + xx);
				float vy = tex2D(_MainTex, uv + yy);
				float x = vx - v;
				float y = vy - v;
				return float2(-y,x);
			}
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = pow(float4((gradient(i.uv))*110,0,0),2);
                // apply fog
                
                return col;
            }
            ENDCG
        }
    }
}
