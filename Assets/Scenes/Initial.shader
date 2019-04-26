Shader "Unlit/Initial"
{
    Properties
    {
		_gradiantTex("gradient",2D) = "white" {}
		_textureSize("Texture Size", Int) = 64
		_initialSpeed("initial speed", Float) = 0.3
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

            sampler2D _gradiantTex;
			float _textureSize;
			float _initialSpeed;
			float2 gradient(float2 uv)
			{

				float2 puv = uv - 0.5;
				//float x = puv.x;
				//float y = puv.y;
				//float2 dir = float2(x*x-y*y,2*x*y);
				//return (float2(-puv.y,puv.x));
				float2 xx = float2(1, 0) / _textureSize;
				float2 yy = float2(0, 1) / _textureSize;
				float v = tex2D(_gradiantTex, uv).x;
				float vx = tex2D(_gradiantTex, uv + xx).x;
				float vy = tex2D(_gradiantTex, uv + yy).x;
				return float2(-(vy - v), vx - v);
			}
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

			uint UV2VertIndex(float uv)
			{
				int x = (uv * _textureSize).x;
				int y = (uv * _textureSize).y;
				return x + y * _textureSize;
			}



            float4 frag (v2f i) : SV_Target
            {
				
                return  float4(i.uv,_initialSpeed,0);
            }
            ENDCG
        }
    }
}
