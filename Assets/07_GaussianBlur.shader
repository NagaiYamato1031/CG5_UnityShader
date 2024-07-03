Shader "Unlit/07_GaussianBlur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_ShiftWidth ("ShiftWidth", float) = 0.005
		_ShiftNum ("ShiftNum", float) = 3
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

			// 外部からの設定
			float _ShiftWidth;
			float _ShiftNum;


			fixed4 Smoothing(v2f i, fixed4 col)
			{
				//float _ShiftWidth = 0.005;
				//float _ShiftNum = 3;

				float num = 0;
				[loop]
				for(fixed py = _ShiftNum / 2; py <= _ShiftNum / 2; py++)
				{
					[loop]
					for(fixed px = _ShiftNum / 2; px <= _ShiftNum / 2; px++)
					{
						col += tex2D(_MainTex, i.uv + float2(px, py) * _ShiftWidth);
						num++;
					}
				}

				col.rgb = col.rgb / num;
				col.a = 1;
				return col;
			}

			fixed Gaussian(float2 drawUV, float2 pickUV, float sigma)
			{
				float d = distance(drawUV, pickUV);
				return exp(-(d * d) / (2 * sigma * sigma));
			}

			fixed4 GaussianBlur(v2f i)
			{
				float totalWeight = 0, _Sigma = 0.005, _StepWidth = 0.001;
				float4 col = fixed4(0, 0, 0, 0);

				for(float py = -_Sigma * 2; py <= _Sigma * 2; py += _StepWidth)
				{
					for(float px = -_Sigma * 2; px <= _Sigma * 2; px += _StepWidth)
					{
						float2 pickUV = i.uv + float2(px, py);
						fixed weight = Gaussian(i.uv, pickUV, _Sigma);
						col += tex2D(_MainTex, pickUV) * weight;
						totalWeight += weight;
					}
				}

				col.rgb = col.rgb / totalWeight;
				col.a = 1;
				return col;
			}

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col;
				//float2 tiling = _MainTex_ST.xy;
				//float2 offset = _MainTex_ST.zw;
				//col = tex2D(_MainTex, i.uv * tiling + offset);

				col = GaussianBlur(i);

				return col;
			}
			ENDCG
		}
	}
}
