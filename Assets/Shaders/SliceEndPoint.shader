Shader "Hidden/SliceEndPoint"
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
			
			sampler2D _MainTex;
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 lightDir = ComputeScreenPos(_WorldSpaceLightPos0);
				lightDir = normalize(lightDir);

				fixed isLightDirLeft = dot(lightDir, float2(1,0)) < 0;
				float4 outmost = GetOutermostScreenPixelCoords();
				//float4 crossLine = outmost.xwzw - outmost.zyxy; 				
				float2 intsectOnCrossLine;
				if(isLightDirLeft > 0)
					intsectOnCrossLine = lerp(outmost.xw, outmost.zy, i.uv.x);
				else
					intsectOnCrossLine = lerp(outmost.xy, outmost.zw, i.uv.x);

				fixed4 col = 0;
				if(length(i.uv - intsectOnCrossLine) < 0.02)
					col = fixed4(1,1,0,0);
				return col;
			}
			ENDCG
		}
	}
}
