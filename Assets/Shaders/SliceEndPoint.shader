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

				float k = lightDir.y/lightDir.x;
				float4 intesectOnBound = 0;
				intesectOnBound.x = k * (1 - intsectOnCrossLine.x) + intsectOnCrossLine.y;
				intesectOnBound.y = k * (0 - intsectOnCrossLine.x) + intsectOnCrossLine.y;
				intesectOnBound.z = 1/k * (1 - intsectOnCrossLine.y) + intsectOnCrossLine.x;
				intesectOnBound.w = 1/k * (0 - intsectOnCrossLine.y) + intsectOnCrossLine.x;

				fixed4 isValidIntsect = (intesectOnBound >= 0 && intesectOnBound <= 1);
				intesectOnBound *= isValidIntsect; //与0，0点相交的就不要啦

				float4 startPoint = float4(1, intesectOnBound.x, intesectOnBound.z, 1) * isValidIntsect.xxzz;
				float4 endPoint = float4(0, intesectOnBound.y, intesectOnBound.w, 0) * isValidIntsect.yyww;

				float2 start, end;
				start = startPoint.x > 0 ? startPoint.xy : startPoint.zw;
				end = endPoint.y > 0 ? endPoint.xy : endPoint.zw;

				return float4(start, end);
			}
			ENDCG
		}
	}
}
