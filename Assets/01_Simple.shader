Shader "Unlit/01_Simple"
{
	// 外部から決める
	Properties
	{
		_Color("Color",Color) = (1,0,0,1)
	}

	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			// 外部から受け取った色
			fixed4 _Color;

			float4 vert(float4 v:POSITION):SV_POSITION
			{
				float4 o;
				o = UnityObjectToClipPos(v);
				return o;
			}

			fixed4 frag(float4 i:SV_POSITION):SV_TARGET
			{
				fixed4 o = _Color;
				return o;
			}
			ENDCG
		}
	}
}