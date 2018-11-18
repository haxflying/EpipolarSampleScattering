Shader "Hidden/SamplerCoords"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Common.cginc"

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

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
			//slices * 1
			sampler2D tex2DSliceEndPoints;
 			//target : samples * slices
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 startEnd = tex2D(tex2DSliceEndPoints, float2(i.uv.y, 1));
				float posOnEpopolarLine = i.uv.x - 0.5/SamplerNum;
				posOnEpopolarLine *= SamplerNum/(SamplerNum - 1);
				posOnEpopolarLine = saturate(posOnEpopolarLine);
				float2 coord = lerp(startEnd.xy, startEnd.zw, posOnEpopolarLine);
				float camZ = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, coord);
				return float4(coord, camZ, 0);
			}
			ENDCG
		}
	}
}
