Shader "Unlit/04_Phong"
{
	Properties
	{
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

			fixed4 _Color;
			Float _Ambient;
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
				fixed4 color = _Color;

				fixed4 ambient = color * _Ambient * _LightColor0;
				
				float intensity = saturate(dot(normalize(i.normal), _WorldSpaceLightPos0));
				fixed4 diffues = color	* intensity * _LightColor0;
				
				float3 eyeDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPosition);
				float3 lightDir = normalize(_WorldSpaceLightPos0);
				i.normal = normalize(i.normal);
				float3 reflectDir = -lightDir + 2 * i.normal * dot(i.normal, lightDir);
				float luster = pow(saturate(dot(reflectDir,eyeDir)),_Specular);
				float4 specular = luster * _LightColor0;

				output = ambient + diffues + specular;

				return output;
			}

			ENDCG
		}
	}
}