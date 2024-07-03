Shader "Unlit/08_Bloom"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "black" {}
	}
	SubShader
	{
		CGINCLUDE
		struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};
	
		struct v2f
		{
			float2 uv : TEXCOORD0;
			float4 vertex : SV_POSITION;
		};
	
		// 元画像
		sampler2D _MainTex;
		float4 _MainTex_ST;
		// 高輝度ぼかし画像
		sampler2D _BlurTex;
		float4 _BlurTex_ST;
		
		// 角度をつけたぼかし
		float _AngleDeg;

		#pragma vertex vert
		#pragma fragment frag
	
		#include "UnityCG.cginc"
		v2f vert (appdata v)
		{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.uv = TRANSFORM_TEX(v.uv, _MainTex);
			UNITY_TRANSFER_FOG(o,o.vertex);
			return o;
		}

		// ガウシアン
		fixed Gaussian(float2 drawUV, float2 pickUV, float sigma)
		{
			float d = distance(drawUV, pickUV);
			return exp(-(d * d) / (2 * sigma * sigma));
		}

		// ガウシアンブラー
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

			col = col / totalWeight;
			//col.rgb = col.rgb / totalWeight;
			//col.a = 1;
			return col;
		}
		// 直線的なぼかし
		fixed4 AngleBlur(v2f i)
		{
			float totalWeight = 0, _Sigma = 0.005, _StepWidth = 0.001;
			float4 col = fixed4(0, 0, 0, 0);
			// 取得座標
			float2 pickUV = float2(0, 0);
			// シグマ
			float pickRange = 0.06;
			// ぼかす角度(radian)
			float angleRad = _AngleDeg * 3.14159 / 180;

			[loop]
			for(float j = -pickRange; j <= pickRange; j += 0.005)
			{
				float x = cos(angleRad) * j;
				float y = sin(angleRad) * j;
				float2 pickUV = i.uv + float2(x, y);
				// 重み
				fixed weight = Gaussian(i.uv, pickUV, pickRange);
				col += tex2D(_MainTex, pickUV) * weight;
				totalWeight += weight;
			}

			col = col / totalWeight;
			return col;
		}
		ENDCG

		// 0 高輝度抽出
		Pass
		{
			CGPROGRAM
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed grayScale = col.r * 0.299 + col.g * 0.587 + col.b * 0.114;
				fixed extract = smoothstep(0.6, 0.9, grayScale);
				return col * extract;
			}
			ENDCG
		}

		// 1 テクスチャ合成
		Pass
		{
			CGPROGRAM
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 blurCol = tex2D(_BlurTex, i.uv);
				return col + blurCol;
			}
			ENDCG
		}
		// 2 テクスチャ乗算
		Pass
		{
			CGPROGRAM
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 blurCol = tex2D(_BlurTex, i.uv);
				return col * blurCol;
			}
			ENDCG
		}

		// 3 高輝度ガウシアンブラー
		Pass
		{
			CGPROGRAM
			fixed4 frag (v2f i) : SV_Target
			{
				return GaussianBlur(i);
			}
			ENDCG
		}

		// 4 直線的なぼかし
		Pass
		{
			CGPROGRAM
			fixed4 frag (v2f i) : SV_Target
			{
				return AngleBlur(i);
			}
			ENDCG
		}

		// 5 ドット柄フィルター
		Pass
		{
			CGPROGRAM
			fixed4 frag (v2f i) : SV_Target
			{
				fixed2 st = i.uv / _ScreenParams.x * 20;
				st = frac(st * _ScreenParams.xy);
				fixed l = distance(st, fixed2(0.5, 0.5));
				return fixed4(1, 1, 1, 1) * 1 - step(0.3, l);
			}
			ENDCG
		}
	}
}
