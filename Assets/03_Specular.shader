Shader "Unlit/03_Lambert"
{
	Properties
	{
		_Color("Color",Color) = (1,0,0,1)
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

			fixed4 _Color;
			Float _Specular;

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
				float3 worldPosition : TEXCOORD1;
			};

			// バーテックスシェーダ
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}

			// ピクセルシェーダー
			fixed4 frag(v2f i) : SV_Target
			{
				float4 output;
				float3 eyeDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPosition);
				float3 lightDir = normalize(_WorldSpaceLightPos0);
				i.normal = normalize(i.normal);
				float3 reflectDir = -lightDir + 2 * i.normal * dot(i.normal, lightDir);
				float luster = pow(saturate(dot(reflectDir,eyeDir)),_Specular);
				float4 specular = luster * _LightColor0;
				fixed4 color = _Color;
				output = color + specular;

				// // Lambert も追加
				// float intensity = saturate(dot(normalize(i.normal), _WorldSpaceLightPos0)) * _LightColor0;
				// intensity = pow(intensity * 0.5 + 0.5,2);
				// output += specular;
				
				return output;
			}

			ENDCG
		}
	}
}