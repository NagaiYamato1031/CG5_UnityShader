Shader "Unlit/05_Texture"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color("Color",Color) = (1,0,0,1)
		_Ambient("Ambient",Float) = 0.3
		_Specular("Specular",Float) = 20
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};
			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
				float3 worldPosition : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			// Phong 反射
			fixed4 _Color;
			Float _Ambient;
			Float _Specular;

			fixed4 Ambient(fixed4 color, fixed4 lightcolor)
			{
				fixed4 ambient = color * _Ambient * lightcolor;
				return ambient;
			}

			float Intensity(float3 normal, float4 lightpos)
			{
				float intensity = saturate(dot(normalize(normal), lightpos));
				return intensity;
			}

			fixed4 Diffues(fixed4 color, float intensity, fixed4 lightcolor)
			{
				fixed4 diffues = color	* intensity * lightcolor;
				return diffues;
			}

			float3 Refrection(float3 lightDir, float3 normal)
			{
				float3 reflectDir = -lightDir + 2 * normal * dot(normal, lightDir);
				return reflectDir;
			}

			float4 Specular(float3 reflectDir, float3 eyeDir, fixed4 lightcolor)
			{
				float luster = pow(saturate(dot(reflectDir, eyeDir)), _Specular);
				float4 specular = luster * lightcolor;
				return specular;
			}

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float4 output;
				float2 tiling = _MainTex_ST.xy;
				float2 offset = _MainTex_ST.zw;
				fixed4 col;
				col = tex2D(_MainTex, i.uv * tiling + offset);
				// 透明削除
				// if(col.w < 0.2){
				// 	discard;
				// }
				
				// 反射無し
				//return col;

				//Phong 反射
				fixed4 color = col * _Color;

				fixed4 ambient = Ambient(color, _LightColor0);
				
				float intensity = Intensity(i.normal, _WorldSpaceLightPos0);
				fixed4 diffues = Diffues(color, intensity, _LightColor0);
				
				float3 eyeDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPosition);
				float3 lightDir = normalize(_WorldSpaceLightPos0);
				i.normal = normalize(i.normal);
				float3 reflectDir = Refrection(lightDir, i.normal);
				float4 specular = Specular(reflectDir, eyeDir, _LightColor0);

				output = ambient + diffues + specular;

				return output;

			}
			ENDCG
		}
	}
}
