Shader "Hidden/ConstructMinMaxTree"
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
			#pragma multi_compile __ _INIT
			
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
			
			Texture2D tex2DShadowmapCopy;
			SamplerState samplertex2DShadowmapCopy;

			sampler2D _MainTex;			
			sampler2D tex2DminmaxSource;
			sampler2D tex2DSliceUVDirAndOrigin;
			int _SrcXOffset;
			int _DstXOffset;

			//target : sm_res * sm_res
			fixed4 Init (v2f i)
			{
				float sliceInd = i.uv.y;
				float4 sliceUVAndOrigin = tex2D(tex2DSliceUVDirAndOrigin, float2(sliceInd, 0.5));
				float2 currUV = sliceUVAndOrigin.xy + sliceUVAndOrigin.zw * floor(i.uv.x) * 2.0;
				float4 minDepth = 1;
				float4 maxDepth = 0;

				float4 depths = tex2DShadowmapCopy.Gather(samplertex2DShadowmapCopy, currUV);
				minDepth = min(minDepth, depths);
				maxDepth = max(maxDepth, depths);

				minDepth.xy = min(minDepth.xy, minDepth.zw);
				minDepth.x = min(minDepth.x, minDepth.y);

				maxDepth.xy = max(maxDepth.xy, maxDepth.zw);
				maxDepth.x = max(maxDepth.x, maxDepth.y);				
				
				return float4(minDepth.x, maxDepth.x, 0, 0);
			}

			fixed4 ComputeMinMaxLevel(v2f i)
			{

			}

			fixed4 frag(v2f i) : SV_Target
			{
				#if _INIT
					return Init(i);
				#else
					return ComputeMinMaxLevel(i);
				#endif
				return 0;
			}
			ENDCG
		}
	}
}
