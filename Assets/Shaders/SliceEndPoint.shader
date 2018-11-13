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

			float4 GetOutermostScreenPixelCoords()
			{
				return float4(-1,-1,1,1) + float4(1,1,-1,-1) / _ScreenParams.xyxy;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float2 lightPos = ComputeScreenPos(_WorldSpaceLightPos0);
				float2 uv = i.uv;
				float epipolarSlice = saturate(uv.x - 0.5f/256);
				uint uiBoundary = clamp(floor(epipolarSlice * 4), 0, 3);
				float posOnBoundary = frac(epipolarSlice * 4);
				fixed4 bBoundaryFlags = fixed4(uiBoundary.x == 0, uiBoundary.x == 1, uiBoundary.x == 2, uiBoundary.x == 3);
				float4 outermostScreenPixelCoords = GetOutermostScreenPixelCoords();
				fixed4 isInvalidBoundary = fixed4((lightPos.xyxy - outermostScreenPixelCoords.xyzw) * float4(1,1,-1,-1) <= 0);

				if(dot(isInvalidBoundary, bBoundaryFlags))
					return 0;

				float4 boundaryXPos = float4(0, posOnBoundary, 1, 1 - posOnBoundary);
				float4 boundaryYPos = float4(1 - posOnBoundary, 0, posOnBoundary, 1);

				float2 exitPointPosOnBnd = float2(dot(boundaryXPos, bBoundaryFlags), dot(boundaryYPos, bBoundaryFlags));
				float2 exitPoint = lerp(outermostScreenPixelCoords.xy, outermostScreenPixelCoords.zw, exitPointPosOnBnd);

				fixed4 col = 1; 
				return col;
			}
			ENDCG
		}
	}
}
