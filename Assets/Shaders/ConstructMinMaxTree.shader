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
			#pragma target 5.0
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
			float4 _viewPortParams;

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
				//return i.uv.x;				
				float2 uv = i.uv * _viewPortParams.xy;
				float2 sample0Ind = float2(_SrcXOffset + uv.x * 2, uv.y);
				float2 sample1Ind = sample0Ind + float2(1,0);
				float2 minmax0 = tex2D(tex2DminmaxSource, sample0Ind * _viewPortParams.zw);
				float2 minmax1 = tex2D(tex2DminmaxSource, sample1Ind * _viewPortParams.zw);

				float2 minmax;
				minmax.x = min(minmax0.x, minmax1.x);
				minmax.y = max(minmax0.y, minmax1.y);
				return float4(minmax, 0, 0);
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
